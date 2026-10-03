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
Adding uses the already-loaded product or selected variation price and stock snapshot.
Cart quantity changes use the saved stock snapshot. Cart contents do not reserve stock.
Variable products are stored as separate lines by product and variation ID. Checkout creates an order from the local cart; backend cart synchronization and currency conversion are not supported.

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


## Checkout: Shipping Methods

`GET /api.php?endpoint=shipping/zones/2/methods`

This version supports Myanmar zone 2. The response is an array of methods with
`id`, `instance_id`, `title`, `order`, `enabled`, `method_id`, and `settings`.
Only enabled methods are displayed, ordered by `order`. Flat-rate cost comes from
`settings.cost.value` as a nonnegative decimal string; free shipping costs zero.
Unsupported methods or invalid flat-rate costs cannot be selected. No method is
selected automatically. The supplied API has no free-shipping eligibility rules.

## Checkout: Create Order

`POST /api.php?endpoint=orders` with JSON and the logged-in customer's bearer token.
The backend associates the order with the JWT customer; no `customer_id` is sent.

```json
{
  "payment_method": "cod",
  "payment_method_title": "Cash on Delivery",
  "set_paid": false,
  "billing": {
    "first_name": "John", "last_name": "Doe",
    "email": "user@example.com", "phone": "09123456789",
    "address_1": "123 Main St", "address_2": "",
    "city": "Yangon", "state": "Yangon", "postcode": "11111", "country": "MM"
  },
  "shipping": {
    "first_name": "John", "last_name": "Doe",
    "address_1": "123 Main St", "address_2": "",
    "city": "Yangon", "state": "Yangon", "postcode": "11111", "country": "MM"
  },
  "line_items": [{"product_id": 799, "quantity": 2, "variation_id": 800}],
  "shipping_lines": [{"method_id": "flat_rate", "method_title": "နယ်မြို့", "total": "20"}],
  "customer_note": "Please deliver in the evening"
}
```

Simple-product lines omit `variation_id`. Local prices are not submitted.
Address edits are order-only; country is fixed to `MM`. The checkout estimate
uses saved cart prices plus shipping, while server totals are authoritative.

The response is an object containing a positive `id`, `status`, `currency`,
`total`, `subtotal`, and `shipping_total`. Additional fields such as `order_key`,
addresses, line items, `date_created`, and `payment_url` may be returned.
A valid order ID confirms creation even when status is `checkout-draft`; the app
shows the actual status and does not mark it paid or open `payment_url`.
Purchased quantities are removed transactionally from SQLite after creation.
Cleanup retries never POST another order. Rejections retain the cart and form.
Uncertain results require explicit confirmation before retry; POST is never
retried automatically. Submission recovery across app restarts is not included.


## My Orders

`GET /api.php?endpoint=orders&customer=5&_fields=id,status,total,date_created,line_items`

The authenticated session's customer ID is required as a string; the existing
bearer token is sent. No unfiltered order request is made when the ID is missing.
The response is an array of orders with `id`, `status`, `total`, `date_created`,
and `line_items`; each item contains `product_id`, `quantity`, and optional
`variation_id`. The live response also includes `name`, `parent_name`, numeric
`price`, decimal-string `total`, `image.src`, and `meta_data` with option
`display_key`/`display_value` (such as Size and Color). My Orders sorts newest first and displays totals in Ks (MMK),
consistent with checkout; this response does not supply currency.

The API also accepts optional `status` and comma-separated `_fields` parameters.
The UI has All, Pending, Processing, and Completed tabs. All omits the status
parameter; other tabs send `pending`, `processing`, or `completed`. Each tab has
separate session-scoped loading, retry, refresh, and scroll state. There is no
pagination, separate order details screen, or product-name lookup. It displays product photos, names, option badges, quantities, unit prices, and line totals from the response; older minimal responses fall back to product/variation IDs. Order totals include shipping or other adjustments and are shown separately from item totals.

My Orders is available under `/profile/orders` independently of customer profile
loading. Authentication is required, and login returns to this route. Logout or
session changes discard previous-customer data and cancel unused requests.
Loading, error/retry, empty, and pull-to-refresh states are supported.

After order creation and successful purchased-item cleanup, checkout replaces
itself with My Orders in the Profile tab and fetches fresh orders. An optional
`createdOrderId` query parameter displays a creation confirmation; no local order
row is fabricated if the GET response does not yet include it. Cart cleanup
failures retain checkout recovery; successful cleanup retry then navigates.
