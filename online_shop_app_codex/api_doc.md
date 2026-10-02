# Product List API

## Endpoint

`GET https://shopapi.rubylearner.com/api.php?endpoint=products`

## Query Parameters

- `page`: page number, default `1`
- `per_page`: number of products per page, default `10`, max `100`
- `orderby`: sort field such as `date`, `title`, or `price`
- `order`: sort direction, `asc` or `desc`
- `category`: category ID, for category-specific product results
- `search`: product search text

## Category Products And Search

Both filters return the same product-array response as the product list and support `page` and `per_page`.

```text
GET /api.php?endpoint=products&category=41&page=1&per_page=20
GET /api.php?endpoint=products&search=shirt&page=1&per_page=20
```

The app uses global search; combining category and search filters is not part of the current UI.
Search is trimmed and debounced by 400 ms; submitting searches immediately. Empty queries make no request.
Category and search results use 20-item pages; Home retains 10-item pages.

## Local Cart

Cart storage is local SQLite on Android/iOS, not a backend cart endpoint.
Before adding, `GET /api.php?endpoint=products/{id}` validates the current price and stock for a simple product.
Cart quantity changes use the saved stock snapshot. Cart contents do not reserve stock.
Variable products, checkout, server synchronization, and currency conversion are not supported.

## Example

```text
https://shopapi.rubylearner.com/api.php?endpoint=products&per_page=5&page=1
```

## Response Shape

The endpoint returns a JSON array of product objects. The app uses the fields below for the product list:

- `id`
- `name`
- `slug`
- `price`
- `short_description`
- `stock_status`
- `images`
