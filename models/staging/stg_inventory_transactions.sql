with source as (
    select * from {{ source('pulmuone', 'inventory_transactions') }}
),
renamed as (
    select
        transaction_id,
        transaction_date,
        transaction_time,
        item_type,
        item_id,
        warehouse_code,
        transaction_type,
        quantity,
        unit_cost,
        reference_type,
        reference_id,
        lot_number,
        expiry_date,
        created_by
    from source
)
select * from renamed
