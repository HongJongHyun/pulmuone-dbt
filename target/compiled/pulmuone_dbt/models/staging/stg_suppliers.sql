with source as (
    select * from PULMUONE_POC.PUBLIC.suppliers
),
renamed as (
    select
        supplier_id,
        supplier_name,
        supplier_type,
        contact_name,
        contact_email,
        contact_phone,
        address,
        city,
        region,
        contract_start_date,
        contract_end_date,
        payment_terms,
        quality_rating,
        is_certified
    from source
)
select * from renamed