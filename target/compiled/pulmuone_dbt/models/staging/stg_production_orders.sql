with source as (
    select * from PULMUONE_POC.PUBLIC.production_orders
),
renamed as (
    select
        production_order_id,
        product_id,
        plant_code,
        production_line,
        order_date,
        planned_start_date,
        planned_end_date,
        actual_start_date,
        actual_end_date,
        planned_qty,
        actual_qty,
        defect_qty,
        material_cost,
        labor_cost,
        overhead_cost,
        status,
        shift
    from source
)
select * from renamed