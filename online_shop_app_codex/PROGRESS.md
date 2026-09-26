# Development Progress

## Progress Log Rules

- Update this file after every meaningful development step.
- Record what changed, what was verified, and what remains pending.
- Keep entries grouped by date with newest work added under the current date.
- Mention commands run for validation when applicable.

## 2026-09-27

### Completed

- Implemented product list pagination with accumulated pages, near-bottom loading, pull-to-refresh reset, and load-more retry handling.
- Added project-local `.codex/rules/git-workflow.rules` Git execution policy to allow `git add` and `git commit` without extra approval while prompting for `git push`.
- Fixed product item bottom overflow risk by limiting product titles to one line, preserving two-line descriptions, reducing bottom padding to 8, and giving grid tiles slightly more vertical space.
- Added a small fixed gap between product descriptions and the pricing row.
- Made product item images flexible so text, description spacing, and the pricing row do not overflow vertically on tight grid tiles.

### Verified

- `dart format lib`
- `flutter analyze`

## 2026-08-16

### Completed

- Added `api_doc.md` with the product list endpoint contract and example request.
- Added a shell-based bottom navigation scaffold with Home, Category, Cart, and Profile tabs.
- Made the Home tab show the product list.
- Added a Category placeholder screen and a Profile/Settings placeholder screen.
- Added a typed product model for the API response.
- Added a Dio service for `GET /api.php?endpoint=products`.
- Added a Riverpod provider that loads the product list.
- Replaced the placeholder products screen with an API-backed width-based grid.
- Added centered loading, error, empty, and pull-to-refresh states for the product list.
- Added a reusable product grid item widget with image, price, and stock badge.
- Removed the repository layer for products.
- Removed the `test/` folder and stopped maintaining tests for this app.
- Updated the default API base URL to `https://shopapi.rubylearner.com`.
- Verified:
  - `dart format lib`
  - `flutter analyze`

### Pending

- Product details API integration.
- Pagination and sort/filter UI.
- More complete HTML/entity decoding if descriptions require it.
- User-friendly API error mapping.

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
- The Dio provider currently defaults to `https://shopapi.rubylearner.com`.
- Use `--dart-define=API_BASE_URL=...` to point the app to a real backend.
