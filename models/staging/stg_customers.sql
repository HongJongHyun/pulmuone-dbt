with source as (
    select * from {{ source('pulmuone', 'customers') }}
),
renamed as (
    select
        customer_id,
        customer_name,
        customer_type,
        channel_detail,
        business_number,
        contact_name,
        contact_email,
        contact_phone,
        address,
        city,
        region,
        credit_limit,
        payment_terms,
        contract_start_date,
        tier,
        is_active
    from source
)
select * from renamed
