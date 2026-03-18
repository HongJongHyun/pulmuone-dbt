with source as (
    select * from PULMUONE_POC.PUBLIC.raw_materials
),
renamed as (
    select
        material_id,
        material_name,
        material_category,
        unit_of_measure,
        unit_cost,
        supplier_id,
        lead_time_days,
        min_order_qty,
        shelf_life_days,
        is_organic,
        origin_country
    from source
)
select * from renamed