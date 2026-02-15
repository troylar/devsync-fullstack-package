# Database Patterns -- Migrations, Queries, and ORM Conventions

## Migration Workflow

Every schema change requires a migration file. Never modify the database schema manually in any environment, including development.

Use Alembic (SQLAlchemy) or a framework-equivalent migration tool. Generate migrations from model changes rather than writing raw SQL migrations by hand, but always review the generated SQL before applying.

```bash
# Generate a migration from model changes
alembic revision --autogenerate -m "add_orders_table"

# Review the generated migration before applying
# Then apply
alembic upgrade head
```

Name migrations descriptively: `add_orders_table`, `add_index_on_users_email`, `remove_legacy_status_column`. Avoid generic names like `update_models` or `schema_change`.

Every migration must include a downgrade path. Test both upgrade and downgrade in development before merging. Migrations that cannot be reversed (data deletions, column type changes with data loss) must be documented clearly.

Never modify a migration that has been applied to any shared environment (staging, production). Create a new migration to correct mistakes.

## ORM Usage

Define models with explicit column types, constraints, and indexes. Never rely on ORM defaults for column sizes or nullability.

```python
class Order(Base):
    __tablename__ = "orders"

    id: Mapped[uuid.UUID] = mapped_column(primary_key=True, default=uuid.uuid4)
    user_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("users.id"), index=True)
    status: Mapped[str] = mapped_column(String(20), nullable=False, default="pending")
    total_cents: Mapped[int] = mapped_column(Integer, nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), onupdate=func.now())
```

Use relationship loading strategies intentionally. Default to `lazy="select"` and switch to `joinedload()` or `selectinload()` in queries where you know related data is needed. Avoid `lazy="joined"` on the model definition -- it forces a join on every query.

## Query Patterns

Use the ORM for standard CRUD operations. Drop to raw SQL or Core expressions for complex reporting queries, bulk operations, or performance-critical paths.

Always use parameterized queries. Never interpolate user input into SQL strings, even in raw queries.

```python
# Correct: parameterized
session.execute(text("SELECT * FROM users WHERE email = :email"), {"email": user_email})

# Incorrect: string interpolation -- SQL injection risk
session.execute(text(f"SELECT * FROM users WHERE email = '{user_email}'"))
```

Prefer `.scalars()` over `.execute()` when fetching ORM model instances. Use `.one()` when exactly one result is expected, `.first()` when zero or one is acceptable, and `.all()` for collections.

## Indexing Strategy

Add indexes for columns used in WHERE clauses, JOIN conditions, and ORDER BY expressions. Create composite indexes for queries that filter on multiple columns together.

```python
__table_args__ = (
    Index("ix_orders_user_status", "user_id", "status"),
)
```

Column order in composite indexes matters. Place the most selective column first, or the column used in equality conditions before range conditions.

Review query plans with `EXPLAIN ANALYZE` for slow queries before adding indexes blindly. An unused index wastes write performance and storage.

## Connection Management

Use connection pooling in all environments. Configure pool size based on the application's concurrency model and the database's max connections.

```python
engine = create_engine(
    database_url,
    pool_size=10,
    max_overflow=20,
    pool_timeout=30,
    pool_recycle=1800,
)
```

Always use context managers or framework-provided session lifecycle management. Never leave sessions or connections open across request boundaries.

## Transactions

Use explicit transaction boundaries for operations that span multiple writes. The ORM session's default autocommit behavior varies by framework -- understand and configure it explicitly.

For operations that must be atomic, wrap them in a single transaction. If any step fails, the entire operation rolls back.

Keep transactions short. Do not perform external API calls, file I/O, or other slow operations inside a transaction. Fetch external data first, then write to the database.

## Data Integrity

Enforce constraints at the database level, not just in application code. Use NOT NULL, UNIQUE, FOREIGN KEY, and CHECK constraints. The database is the last line of defense against invalid data.

Use soft deletes (a `deleted_at` timestamp) for data that may need recovery. Hard delete only when required by data retention policies or regulations.
