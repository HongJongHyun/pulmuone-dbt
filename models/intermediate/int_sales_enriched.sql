with sales as (
    select * from {{ ref('stg_sales_orders') }}
),
products as (
    select * from {{ ref('stg_products') }}
),
customers as (
    select * from {{ ref('stg_customers') }}
)
select
    s.order_id,
    s.order_date,
    s.customer_id,
    c.customer_name,
    c.customer_type,
    c.channel_detail,
    c.tier as customer_tier,
    c.region as customer_region,
    s.product_id,
    p.product_name,
    p.product_category,
    p.product_subcategory,
    p.brand,
    p.storage_type,
    s.quantity,
    s.unit_price,
    s.discount_pct,
    s.total_amount,
    s.channel,
    s.region as delivery_region,
    s.delivery_status,
    s.payment_status,
    p.unit_cost,
    s.total_amount - (s.quantity * p.unit_cost) as gross_margin,
    round((s.total_amount - (s.quantity * p.unit_cost)) * 100.0 / nullif(s.total_amount, 0), 2) as margin_pct
from sales s
join products p on s.product_id = p.product_id
join customers c on s.customer_id = c.customer_id
