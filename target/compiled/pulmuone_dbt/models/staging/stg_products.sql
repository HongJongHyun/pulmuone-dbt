with source as (
    select * from PULMUONE_POC.PUBLIC.products
),
renamed as (
    select
        product_id,
        product_name,
        product_category,
        product_subcategory,
        brand,
        unit_price,
        unit_cost,
        weight_g,
        shelf_life_days,
        storage_type,
        is_organic,
        is_vegan,
        launch_date,
        discontinue_date,
        status
    from source
)
select * from renamed