# Development Progress

## Progress Log Rules

- Update this file after every meaningful development step.
- Record what changed, what was verified, and what remains pending.
- Keep entries grouped by date with newest work added under the current date.
- Mention commands run for validation when applicable.

## 2026-10-02

### Category Products, Search, And SQLite Cart

- Implemented in parallel by Galileo (category products), Copernicus (search), and Maxwell (local cart), with shared query, routing, and integration work in the main thread.
- Category rows now open paginated product results; Home has an app-bar search icon opening global search with 400 ms debounce, immediate submission, clear, and empty-query handling.
- Shared query-keyed results preserve separate Home/category/search state, cancel disposed requests, ignore stale page responses after refresh, deduplicate products, and retain results for load-more retries.
- Added Android/iOS SQLite cart storage using `sqflite`, serialized transactional writes, exact decimal totals, quantity controls, removal, and persisted price/stock snapshots.
- Product details offer quantity selection and add-to-cart for simple products and selected variable-product options; the already-loaded price/stock snapshot and existing cart quantities are checked locally before insertion. Cart rows distinguish product variations and preserve their selected options.
- Added generated native plugin setup and documented category/search API parameters in `api_doc.md`.
- Verified: `dart format lib`, `flutter analyze` (no issues), `git diff --check`, and `flutter build apk --debug`.
- Installed the debug APK on the Android emulator; confirmed search results, category navigation/results/images, cart empty state, and creation of `shop_cart.db`.
- Live API checks returned category results and distinct search pages. The current 88-product catalog returned only variable products, so real simple-product add/update/restart persistence verification remains pending.
- Pending: iOS runtime checks, populated-cart failure/restart checks with a simple product, and narrow-width/increased-text-scale visual coverage.
- Build warnings: existing Gradle/AGP/Kotlin versions will need a future upgrade; the current debug build succeeds.
- Follow-up: kept Add to cart visible in a fixed bottom area on product details; variable products display the disabled action and availability reason. Rebuilt, reinstalled, and confirmed it is visible on the first screen of the emulator detail view.
- Follow-up: variable-product options resolve against the product's listed variation IDs; selected variation price and stock govern add-to-cart, which only writes to SQLite and does not fetch product data. Each variation persists as a distinct cart line. Verified with `flutter analyze` and `git diff --check`.

## 2026-09-27

### Product Details And Options

- Added API-backed product details with an immutable model, cancellable Riverpod provider by ID, responsive image gallery, pricing, descriptions, attributes, and categories.
- Added loading, error, retry, refresh, and stock states; variable-product availability remains unresolved without variation data.
- Added size, color, and other variation option choosers with Riverpod selection state and recognized color swatches.
- Cart and checkout integration awaits variation, cart, and checkout API contracts.
- Formatted product files and passed `flutter analyze`; runtime visual verification remains pending.

### Category List

- Completed by subagent Franklin: replaced the Category placeholder with an API-backed list using `GET /api.php?endpoint=products/categories`.
- Added an immutable category model, a service using centralized Dio, and a Riverpod provider that fetches all pages in batches of 100.
- Added category names, product counts, hierarchy paths, images with fallbacks, and loading, error, retry, empty, and pull-to-refresh states.
- Kept changes inside `lib/features/categories/`; no new dependencies or tests were added.
- Verified: `dart format lib/features/categories` (subagent), and a fresh `flutter analyze` passed with no issues.
- Pending: live API and runtime visual verification, including category images and refresh behavior.

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
