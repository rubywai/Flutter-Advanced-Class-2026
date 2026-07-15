# Development Progress

## Progress Log Rules

- Update this file after every meaningful development step.
- Record what changed, what was verified, and what remains pending.
- Keep entries grouped by date with newest work added under the current date.
- Mention commands run for validation when applicable.

## 2026-07-15

### Completed

- Created the initial Flutter online shop foundation.
- Added core dependencies:
  - `flutter_riverpod`
  - `dio`
  - `go_router`
- Replaced the default counter app with `OnlineShopApp`.
- Added `ProviderScope` at app startup.
- Added centralized app routing with `GoRouter`.
- Added core route constants.
- Added shared app theme.
- Added centralized Dio provider with configurable `API_BASE_URL`.
- Added feature-first folders for:
  - `home`
  - `products`
  - `cart`
  - `profile`
- Added placeholder screens for home, product list, product details, cart, and profile.
- Added platform custom-scheme deep-link setup:
  - Android intent filter for `online-shop://app/...`
  - iOS URL scheme for `online-shop`
- Updated widget smoke test for the new app shell.
- Added project architecture guidance in `AGENTS.md`.
- Added this progress log in `PROGRESS.md`.
- Added rule to keep `PROGRESS.md` updated after every meaningful development step.
- Verified:
  - `flutter analyze`
  - `flutter test`

### Current Routes

- `/`
- `/products`
- `/products/:productId`
- `/cart`
- `/profile`

### Current Deep-Link Example

```text
online-shop://app/products/product-1
```

### Pending

- API documentation from the user.
- Product API models, repositories, and providers.
- Auth flow and secure token storage.
- Cart state and persistence strategy.
- Checkout/order flow.
- Production HTTPS deep-link domain.
- Error, loading, and empty states for API-backed screens.

### Notes

- The current UI uses placeholder data until the API contract is available.
- The Dio provider currently defaults to `https://api.example.com`.
- Use `--dart-define=API_BASE_URL=...` to point the app to a real backend.
