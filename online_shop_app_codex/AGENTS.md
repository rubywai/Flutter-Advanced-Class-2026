# Project Architecture Guide

## Overview

This project is a Flutter online shop application.

Core technical choices:

- State management: `flutter_riverpod`
- Networking: `dio`
- Routing: `go_router`
- Structure: folder by feature
- Deep links: supported through `go_router` plus platform URL registration

## Folder Structure

Use feature-first organization under `lib/features`.

Recommended feature shape:

```text
lib/
  core/
    network/
    router/
    theme/
  features/
    feature_name/
      data/
        models/
        services/
      domain/
        entities/
        repositories/
        use_cases/
      presentation/
        providers/
        screens/
        widgets/
```

Current core folders:

- `lib/core/network`: Dio setup and API client providers.
- `lib/core/router`: App route constants and `GoRouter` configuration.
- `lib/core/theme`: Shared app theme.

Current feature folders:

- `lib/features/products`
- `lib/features/categories`
- `lib/features/cart`
- `lib/features/profile`

## Architecture Rules

- Keep feature-specific code inside its feature folder.
- Keep shared app infrastructure inside `lib/core`.
- Use Riverpod providers for dependency injection and state.
- Keep Dio configuration centralized in `lib/core/network/dio_provider.dart`.
- Do not create feature-specific Dio instances unless there is a strong reason.
- Keep product API access in the service and provider layers; do not add a repository layer for this app.
- Use `go_router` route names and route constants from `lib/core/router`.
- Keep screens thin. Move business logic into providers, repositories, or use cases.
- Keep API models separate from UI widgets.
- Prefer immutable model/entity classes.

## Routing

Routes are defined in `lib/core/router/app_router.dart`.

Route paths are centralized in `lib/core/router/app_routes.dart`.

Current routes:

- `/`
- `/products/:productId`
- `/categories`
- `/cart`
- `/profile`

The app uses one bottom navigation shell with these tabs:

- Home
- Category
- Cart
- Profile

The Home tab shows the product list.

Temporary custom deep-link scheme:

```text
online-shop://app/products/product-1
```

When the production domain is available, add Android App Links and iOS Universal Links for HTTPS deep links.

## API Integration

The API documentation has not been provided yet.

Until the API contract is available:

- Keep placeholders simple.
- Avoid inventing final request/response models.
- Avoid hardcoding fake backend behavior into app architecture.
- Use `String.fromEnvironment('API_BASE_URL')` for configurable API base URL.

Run the app with a custom API base URL:

```bash
flutter run --dart-define=API_BASE_URL=https://your-api.example.com
```

## Testing

The `test/` folder is intentionally removed for this app.

Minimum expectations:

- Run `flutter analyze` before handoff.
- Do not add tests unless the user asks for them.

## Development Guidelines

- Keep changes small and focused.
- Do not refactor unrelated files.
- Follow existing Flutter lint rules.
- Use Material 3 components unless a design system replaces them.
- Avoid adding new dependencies without a clear project need.
- Update `PROGRESS.md` when completing a meaningful development step.
