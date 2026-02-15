# REST API Design Conventions

## URL Structure

Use plural nouns for resource collections. Nest sub-resources under their parent with a maximum depth of two levels.

```
GET    /api/v1/users
GET    /api/v1/users/{user_id}
POST   /api/v1/users
PATCH  /api/v1/users/{user_id}
DELETE /api/v1/users/{user_id}
GET    /api/v1/users/{user_id}/orders
```

Never use verbs in URLs. The HTTP method conveys the action. Use query parameters for filtering, sorting, and pagination on collection endpoints.

```
GET /api/v1/orders?status=pending&sort=-created_at&page=1&per_page=25
```

## Request and Response Format

Use camelCase for JSON keys in responses. Accept snake_case from Python internals and convert at the serialization boundary using Pydantic's `alias_generator` or equivalent.

Wrap collection responses in an object with `data` and `meta` keys. Never return a bare array at the top level.

```json
{
  "data": [
    {"id": "abc123", "userName": "alice", "createdAt": "2025-01-15T10:30:00Z"}
  ],
  "meta": {
    "page": 1,
    "perPage": 25,
    "totalCount": 142,
    "totalPages": 6
  }
}
```

Single resource responses return the object directly without a `data` wrapper.

## Error Handling

Return consistent error responses across all endpoints. Use a standard error envelope with `error` containing `code`, `message`, and optional `details`.

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Request validation failed",
    "details": [
      {"field": "email", "message": "Must be a valid email address"},
      {"field": "age", "message": "Must be a positive integer"}
    ]
  }
}
```

Map error codes to HTTP status codes consistently:
- 400: Validation errors, malformed requests
- 401: Missing or invalid authentication
- 403: Authenticated but insufficient permissions
- 404: Resource not found
- 409: Conflict (duplicate resource, state conflict)
- 422: Semantically invalid (valid syntax, invalid business logic)
- 429: Rate limit exceeded
- 500: Unexpected server errors (never expose internal details)

## Versioning

Version the API in the URL path (`/api/v1/`). Increment the major version only for breaking changes. Maintain the previous version for at least 6 months after deprecation notice.

Document breaking changes in a changelog. Add a `Sunset` header to deprecated endpoints with the retirement date.

## Authentication and Authorization

Use Bearer tokens in the Authorization header. Never pass tokens in query parameters or request bodies.

Validate authentication before authorization. Return 401 for missing/invalid tokens and 403 for insufficient permissions. Never reveal whether a resource exists to unauthorized users -- return 403 instead of 404 when the user lacks access.

## Pagination

Use cursor-based pagination for large or frequently updated datasets. Use offset-based pagination only for simple, stable datasets.

Always include pagination metadata in collection responses. Provide `next` and `previous` cursor values or page numbers.

## Rate Limiting

Include rate limit headers in all responses:

```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1700000000
```

Return 429 with a `Retry-After` header when the limit is exceeded.

## Idempotency

Support an `Idempotency-Key` header for POST requests that create resources or trigger side effects. Store the key and response for at least 24 hours to allow safe retries.

PUT and DELETE operations must be naturally idempotent. Repeated calls with the same input must produce the same result.

## Input Validation

Validate all input at the API boundary using Pydantic models or equivalent schema validation. Reject requests that contain unknown fields (use strict mode). Validate field types, ranges, string lengths, and patterns. Return all validation errors at once rather than failing on the first error.
