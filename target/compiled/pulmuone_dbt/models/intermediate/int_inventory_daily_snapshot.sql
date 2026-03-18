with inventory as (
    select * from PULMUONE_POC.staging.stg_inventory_transactions
),
daily_summary as (
    select
        transaction_date,
        item_type,
        item_id,
        warehouse_code,
        sum(case when transaction_type = 'RECEIPT' then quantity else 0 end) as receipt_qty,
        sum(case when transaction_type = 'ISSUE' then quantity else 0 end) as issue_qty,
        sum(case when transaction_type = 'ADJUSTMENT' then quantity else 0 end) as adjustment_qty,
        sum(case when transaction_type = 'RETURN' then quantity else 0 end) as return_qty,
        sum(quantity) as net_quantity,
        sum(quantity * unit_cost) as total_value,
        count(distinct transaction_id) as transaction_count
    from inventory
    group by transaction_date, item_type, item_id, warehouse_code
)
select
    transaction_date,
    item_type,
    item_id,
    warehouse_code,
    receipt_qty,
    issue_qty,
    adjustment_qty,
    return_qty,
    net_quantity,
    total_value,
    transaction_count,
    sum(net_quantity) over (partition by item_type, item_id, warehouse_code order by transaction_date rows unbounded preceding) as running_balance
from daily_summary