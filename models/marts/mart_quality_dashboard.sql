{{
    config(
        materialized='table'
    )
}}
with production as (
    select * from {{ ref('int_production_with_quality') }}
),
products as (
    select * from {{ ref('stg_products') }}
),
quality_analysis as (
    select
        date_trunc('month', p.order_date) as month,
        p.plant_code,
        pr.product_category,
        pr.product_subcategory,
        count(distinct p.production_order_id) as production_count,
        sum(p.actual_qty) as total_produced,
        sum(p.defect_qty) as total_defects,
        sum(p.total_samples) as total_samples,
        sum(p.total_pass) as total_pass,
        sum(p.total_fail) as total_fail,
        sum(p.inspection_count) as inspection_count
    from production p
    join products pr on p.product_id = pr.product_id
    where p.status = 'COMPLETED'
    group by 1, 2, 3, 4
)
select
    month,
    plant_code,
    product_category,
    product_subcategory,
    production_count,
    total_produced,
    total_defects,
    total_samples,
    total_pass,
    total_fail,
    inspection_count,
    round(total_pass * 100.0 / nullif(total_samples, 0), 2) as pass_rate,
    round(total_fail * 100.0 / nullif(total_samples, 0), 2) as fail_rate,
    round(total_defects * 100.0 / nullif(total_produced, 0), 2) as defect_rate,
    round(total_samples * 1.0 / nullif(production_count, 0), 1) as samples_per_order,
    case
        when total_defects * 100.0 / nullif(total_produced, 0) < 1 then 'EXCELLENT'
        when total_defects * 100.0 / nullif(total_produced, 0) < 3 then 'GOOD'
        when total_defects * 100.0 / nullif(total_produced, 0) < 5 then 'ACCEPTABLE'
        else 'NEEDS_IMPROVEMENT'
    end as quality_grade
from quality_analysis
