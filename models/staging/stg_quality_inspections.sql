with source as (
    select * from {{ source('pulmuone', 'quality_inspections') }}
),
renamed as (
    select
        inspection_id,
        production_order_id,
        product_id,
        inspection_date,
        inspection_time,
        inspector_id,
        inspection_type,
        sample_size,
        pass_qty,
        fail_qty,
        defect_type,
        ph_value,
        moisture_pct,
        bacteria_count,
        result,
        remarks
    from source
)
select * from renamed
