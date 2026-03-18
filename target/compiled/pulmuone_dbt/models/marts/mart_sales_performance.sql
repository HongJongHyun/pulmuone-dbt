
with sales as (
    select * from PULMUONE_POC.intermediate.int_sales_enriched
),
monthly_metrics as (
    select
        date_trunc('month', order_date) as month,
        channel,
        delivery_region,
        product_category,
        brand,
        customer_tier,
        count(distinct order_id) as order_count,
        count(distinct customer_id) as customer_count,
        count(distinct product_id) as product_count,
        sum(quantity) as total_quantity,
        sum(total_amount) as total_revenue,
        sum(gross_margin) as total_margin,
        avg(total_amount) as avg_order_value,
        avg(margin_pct) as avg_margin_pct
    from sales
    group by 1, 2, 3, 4, 5, 6
)
select
    month,
    channel,
    delivery_region,
    product_category,
    brand,
    customer_tier,
    order_count,
    customer_count,
    product_count,
    total_quantity,
    total_revenue,
    total_margin,
    round(avg_order_value, 2) as avg_order_value,
    round(avg_margin_pct, 2) as avg_margin_pct,
    round(total_revenue / nullif(order_count, 0), 2) as revenue_per_order,
    round(total_revenue / nullif(customer_count, 0), 2) as revenue_per_customer
from monthly_metrics