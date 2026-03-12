{{
    config(
        materialized='table'
    )
}}
with inventory as (
    select * from {{ ref('int_inventory_daily_snapshot') }}
),
products as (
    select * from {{ ref('stg_products') }}
),
monthly_inventory as (
    select
        date_trunc('month', i.transaction_date) as month,
        i.warehouse_code,
        i.item_type,
        i.item_id,
        sum(i.receipt_qty) as total_receipt,
        sum(i.issue_qty) as total_issue,
        sum(abs(i.total_value)) as total_value,
        avg(i.running_balance) as avg_balance,
        max(i.running_balance) as max_balance,
        min(i.running_balance) as min_balance
    from inventory i
    group by 1, 2, 3, 4
),
with_product as (
    select
        m.month,
        m.warehouse_code,
        m.item_type,
        m.item_id,
        case 
            when m.item_type = 'PRODUCT' then p.product_name
            else m.item_id
        end as item_name,
        case 
            when m.item_type = 'PRODUCT' then p.product_category
            else 'RAW_MATERIAL'
        end as category,
        m.total_receipt,
        m.total_issue,
        m.total_value,
        m.avg_balance,
        m.max_balance,
        m.min_balance
    from monthly_inventory m
    left join products p on m.item_id = p.product_id and m.item_type = 'PRODUCT'
)
select
    month,
    warehouse_code,
    item_type,
    item_id,
    item_name,
    category,
    total_receipt,
    total_issue,
    round(total_value, 2) as total_value,
    round(avg_balance, 2) as avg_balance,
    round(max_balance, 2) as max_balance,
    round(min_balance, 2) as min_balance,
    case 
        when avg_balance > 0 then round((total_issue / nullif(avg_balance, 0)) * 12, 2)
        else 0
    end as annual_turnover_rate,
    case 
        when total_issue > 0 then round(avg_balance * 30.0 / nullif(total_issue, 0), 1)
        else 0
    end as days_on_hand
from with_product
