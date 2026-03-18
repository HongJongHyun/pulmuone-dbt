
with suppliers as (
    select * from PULMUONE_POC.staging.stg_suppliers
),
materials as (
    select * from PULMUONE_POC.staging.stg_raw_materials
),
production as (
    select * from PULMUONE_POC.intermediate.int_production_with_quality
),
supplier_materials as (
    select
        s.supplier_id,
        s.supplier_name,
        s.supplier_type,
        s.region,
        s.quality_rating,
        s.is_certified,
        s.payment_terms,
        count(distinct m.material_id) as material_count,
        sum(m.unit_cost * m.min_order_qty) as potential_order_value,
        avg(m.lead_time_days) as avg_lead_time
    from suppliers s
    left join materials m on s.supplier_id = m.supplier_id
    group by 1, 2, 3, 4, 5, 6, 7
),
material_usage as (
    select
        m.supplier_id,
        date_trunc('month', p.order_date) as month,
        sum(p.material_cost) as material_cost_used
    from production p
    cross join materials m
    where p.status = 'COMPLETED'
    group by 1, 2
),
supplier_usage_summary as (
    select
        supplier_id,
        count(distinct month) as active_months,
        sum(material_cost_used) as total_material_value
    from material_usage
    group by supplier_id
)
select
    sm.supplier_id,
    sm.supplier_name,
    sm.supplier_type,
    sm.region,
    sm.quality_rating,
    sm.is_certified,
    sm.payment_terms,
    sm.material_count,
    round(sm.potential_order_value, 2) as potential_order_value,
    round(sm.avg_lead_time, 1) as avg_lead_time_days,
    case
        when sm.quality_rating >= 4.5 then 'A'
        when sm.quality_rating >= 4.0 then 'B'
        when sm.quality_rating >= 3.5 then 'C'
        else 'D'
    end as supplier_grade,
    case
        when sm.is_certified then 'CERTIFIED'
        else 'NOT_CERTIFIED'
    end as certification_status
from supplier_materials sm