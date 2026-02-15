# React Patterns -- TypeScript + Functional Components

## Component Structure

Always use functional components with TypeScript. Never use class components.

Define component props as a dedicated interface or type above the component. Export the props type alongside the component so consumers can extend or reference it.

```tsx
export interface UserCardProps {
  user: User;
  onSelect: (userId: string) => void;
  variant?: "compact" | "detailed";
}

export function UserCard({ user, onSelect, variant = "detailed" }: UserCardProps) {
  // component body
}
```

Use named exports exclusively. Default exports make refactoring harder and reduce IDE auto-import reliability.

## Early Returns

Reduce nesting by returning early for loading, error, and empty states. Place guard clauses at the top of the component before the main render logic.

```tsx
export function OrderList({ orders, isLoading, error }: OrderListProps) {
  if (isLoading) return <Skeleton count={5} />;
  if (error) return <ErrorBanner message={error.message} />;
  if (orders.length === 0) return <EmptyState entity="orders" />;

  return (
    <ul>
      {orders.map((order) => (
        <OrderItem key={order.id} order={order} />
      ))}
    </ul>
  );
}
```

## Hooks

Keep hooks at the top of the component, before any conditional logic. Extract complex hook logic into custom hooks prefixed with `use`.

Custom hooks should have a single responsibility. If a hook manages both fetching and caching, split it into `useFetch` and `useCache`.

For data fetching, prefer React Query (TanStack Query) or SWR over raw useEffect. These libraries handle caching, deduplication, and background refetching.

```tsx
function useUserOrders(userId: string) {
  return useQuery({
    queryKey: ["orders", userId],
    queryFn: () => api.orders.listByUser(userId),
    staleTime: 5 * 60 * 1000,
  });
}
```

## State Management

Use local state (useState) by default. Lift state up only when sibling components need access. Reach for context or external stores (Zustand, Jotai) only when prop drilling spans more than two levels.

Never store derived data in state. Compute it during render or use useMemo for expensive calculations.

```tsx
// Correct: derive filtered list from state
const activeUsers = useMemo(
  () => users.filter((u) => u.isActive),
  [users]
);

// Incorrect: storing filtered list as separate state
const [activeUsers, setActiveUsers] = useState<User[]>([]);
```

## Event Handlers

Prefix event handler props with `on` (onSubmit, onClick, onChange). Prefix handler implementations with `handle` (handleSubmit, handleClick, handleChange).

Type event handlers explicitly rather than relying on inference for complex events.

## Forms

Use controlled components with a form library (React Hook Form or Formik). Validate with Zod schemas shared between frontend and backend when possible.

Define validation schemas outside the component to keep them testable and reusable.

## Testing

Test behavior, not implementation. Use React Testing Library. Query by role, label, or text content -- never by test IDs unless no semantic alternative exists.

Structure tests as: arrange (render with props), act (user interactions), assert (visible outcomes).

Mock API calls at the network level (MSW) rather than mocking hooks or modules directly. This tests the full integration path.

## File Organization

One component per file. Co-locate tests, styles, and types alongside the component.

```
components/
  UserCard/
    UserCard.tsx
    UserCard.test.tsx
    UserCard.module.css
    index.ts
```

The index.ts re-exports the component for clean import paths. Keep utility functions used by multiple components in a shared `utils/` directory.
