# Development Progress

## Progress Log Rules

- Update this file after every meaningful development step.
- Record what changed, what was verified, and what remains pending.
- Keep entries grouped by date with newest work added under the current date.
- Mention commands run for validation when applicable.

## 2026-10-03

### Green Shopping App Icon

- Generated an emerald-green shopping-bag app icon using the built-in ImageGen tool; saved the 1024px master and generation prompt in assets/app_icon/.
- Replaced all five Android launcher density resources and all fifteen iOS AppIcon PNG files using the existing platform icon references and catalog.
- Verified every native icon's required pixel dimensions and opaque background, flutter analyze (no issues), and git diff --check. No dependencies added; device launcher and iOS build verification remain pending.


### Selected Product Option Loading

- Added a visible progress bar and loading spinner in the fixed product-detail purchase area while the selected size/color combination resolves.
- Shows Loading price and availability; quantity and Add to cart controls stay disabled during lookup, and stale variation pricing is hidden. Option selectors remain available so selection changes can cancel previous lookups.
- Verified: dart format, flutter analyze (no issues), and git diff --check. Runtime visual verification remains pending.


### Customer Profile Presentation

- Improved the account header with a themed background, avatar fallback, clearer name/email hierarchy, and suppression of duplicate username/email text.
- Added separate Billing address and Shipping address cards with icons, subtitles, and explicit labels for names, address lines, city, state/region, postcode, country, and supplied contact fields. Missing address values show Not provided.
- Address fields adapt from two columns to one on narrow screens or with larger text; refresh, editing, My Orders access, and logout during customer failures remain available.
- Verified: dart format, flutter analyze (no issues), and git diff --check. Runtime visual verification remains pending.


### Rich Order Cards And Status Tabs

- Extended order line parsing for the supplied live response: product names, parent names, image.src, numeric unit prices, decimal line totals, and display option metadata.
- Redesigned orders with rounded cards, product photos and image fallbacks, Size/Color badges, colored status badges, readable dates, grouped prices, and distinct item/order totals. Minimal API responses retain product/variation ID fallbacks; narrow layouts and larger text stack product details.
- Added swipeable All, Pending, Processing, and Completed tabs using the API status parameter; All omits it. Requests are keyed by session and status, with independent loading/error/empty/refresh handling and scroll positions. Checkout opens All after successful cleanup.
- Verified order tab changes with flutter analyze (no issues), flutter build apk --debug, git diff --check, and an offline status-query simulation (All omits status; pending/processing/completed send it). Debug APK installed on emulator-5554; populated-card/tab visual verification remains pending.
- Updated api_doc.md. Verified supplied rich/minimal response parsing with a temporary local Dart probe; no test files or live orders were created.

### My Orders And Checkout Navigation

- Added a My Orders row under Profile, independent of customer information loading/error states, and an authenticated /profile/orders route in the Profile navigation branch.
- Added session-scoped Riverpod order loading using GET orders with the customer ID string and documented field selection; missing IDs never make unfiltered requests, session changes discard prior data, and disposed requests are cancelled.
- Added newest-first order cards with number, status (including checkout-draft), date, MMK total, and product/variation IDs and quantities; loading, empty, error/retry, refresh, and logout states are supported.
- Checkout now automatically opens My Orders once after creation and successful cart cleanup, refreshing orders and showing a creation banner. Cleanup failures retain recovery and navigate after retry succeeds. The submitted checkout is removed from navigation history.
- Updated api_doc.md with the order-list contract and navigation behavior.
- Verified: dart format, flutter analyze (no issues), git diff --check, flutter build apk --debug, and an offline Dio simulation covering customer/field parameters, multiple orders/date ordering, checkout-draft, simple/variation summaries, empty data, malformed responses, invalid authentication, and missing customer ID. No test files or live orders were created.
- Debug APK installed on emulator-5554; visually verified My Orders empty state, refresh/logout actions, Profile tab selection, back navigation to Profile, and the Profile My Orders entry. Full successful checkout-to-list navigation, cleanup-failure recovery, account switching, populated-list visual coverage, and iOS verification remain pending. Existing Android build-tool upgrade warnings remain.

### Shipping Zone Correction

- Updated checkout shipping-method requests to zone 2 because zone 1 is unavailable; updated api_doc.md.
- Verified: flutter analyze (no issues) and git diff --check.

### Logout During Customer Loading Failures

- Added an always-visible logout action to the signed-in Profile app bar, including customer loading, error, and unavailable states.
- Added logout to Checkout before order creation, including customer-fetch failures; disabled it during order submission. Uses existing session/token clearing and authenticated-route redirects.
- Verified: dart format, flutter analyze (no issues), and git diff --check.

### Checkout And Order Creation

- Added an authenticated checkout route and a Checkout button below the populated cart subtotal, with login return navigation.
- Added checkout-only editable customer shipping/billing details, Myanmar country restriction, billing-same-as-shipping option, email/phone validation, and optional customer note.
- Added enabled shipping-method loading from zone 1, explicit selection, flat-rate/free-shipping cost handling, and exact-decimal estimated totals.
- Added JSON Cash on Delivery order creation using existing bearer authentication; simple and variation cart lines map to documented request fields without local prices or customer_id.
- Added submission/navigation guards, readable rejection messages, explicit confirmation for uncertain-result retries, and server order ID/status/currency/totals confirmation, including checkout-draft.
- Added transactional removal of purchased quantities, preserving remaining quantities and unrelated lines; cleanup failures retain the successful order and retry cleanup without another POST.
- Updated api_doc.md with shipping and order contracts and current cart behavior. Existing uncommitted cart clear helpers were preserved.
- Verified: dart format, flutter analyze (no issues), git diff --check, and a temporary offline Dio response simulation for enabled/invalid/free/flat-rate methods, decimal totals, simple/variation payloads, creation success, rejection, timeout, and unreadable responses. No test files were added and no live orders were created.
- Android debug APK built successfully and installed on emulator-5554; checkout deep link opens and customer loading/error/retry layout was visually inspected. The emulator customer request failed, preventing populated-form runtime checks. Existing Gradle/AGP/Kotlin upgrade warnings remain.
- Pending: full emulator/runtime checkout validation (login return, address forms, cleanup/restart behavior, narrow widths, large text), iOS checks, and live order verification with explicit authorization.

## 2026-10-02

### Authentication Flow

- Added form-encoded registration, OTP verification, login, logout, and password-reset request flows against `auth.php`.
- Added Riverpod session state with JWT and expiry persistence through `shared_preferences`; authenticated requests receive a bearer token.
- Added public login, registration, OTP, and reset routes with redirect support for future protected checkout/order routes.
- Added a reusable `requireAuthentication` route redirect helper for the future checkout/order route.
- Verified with `dart format` and `flutter analyze` (no issues).
- Profile now shows a login action for signed-out users and logout for active sessions, with a return path to the profile screen after login.
- Auth registration, login, OTP verification, and reset now all send JSON because the API returns `Invalid JSON body` for form-encoded requests.
- Normalized API error and reset messages so auth screens show readable text instead of raw JSON responses.
- Reset success now appears in a confirmation dialog with the server message.

### Customer Profile

- Added customer models and API service for `GET` and JSON `PUT` requests to `api.php?endpoint=customers/{id}`.
- Login sessions now retain the customer ID from the response or JWT claim, including persistence across app restarts.
- Profile now loads customer information after login, supports refresh, displays billing and shipping details, and provides logout.
- Added a dedicated profile edit form for names and billing fields; shipping and account email remain read-only.
- Verified with `dart format lib/features/profile` and `flutter analyze` (no issues).
- Fixed restored sessions from older logins by deriving and persisting the customer ID from the saved JWT claim.
- Hardened customer loading for both flat customer responses and `{success, data}` envelopes; missing session IDs now show a clear re-login error.
- Added shipping address fields to the profile edit form and included the shipping object in customer update requests.

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
