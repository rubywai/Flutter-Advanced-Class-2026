# Product List API

## Endpoint

`GET https://shopapi.rubylearner.com/api.php?endpoint=products`

## Query Parameters

- `page`: page number, default `1`
- `per_page`: number of products per page, default `10`, max `100`
- `orderby`: sort field such as `date`, `title`, or `price`
- `order`: sort direction, `asc` or `desc`

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
