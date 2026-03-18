with source as (
    select * from PULMUONE_POC.PUBLIC.sales_orders
),
renamed as (
    select
        order_id,
        order_date,
        order_time,
        customer_id,
        product_id,
        quantity,
        unit_price,
        discount_pct,
        total_amount,
        channel,
        region,
        delivery_date,
        delivery_status,
        payment_status,
        promotion_id
    from source
)
select * from renamed