with production as (
    select * from PULMUONE_POC.staging.stg_production_orders
),
quality as (
    select * from PULMUONE_POC.staging.stg_quality_inspections
),
quality_summary as (
    select
        production_order_id,
        sum(sample_size) as total_samples,
        sum(pass_qty) as total_pass,
        sum(fail_qty) as total_fail,
        count(distinct inspection_id) as inspection_count,
        round(sum(pass_qty) * 100.0 / nullif(sum(sample_size), 0), 2) as pass_rate
    from quality
    group by production_order_id
)
select
    p.production_order_id,
    p.product_id,
    p.plant_code,
    p.production_line,
    p.order_date,
    p.planned_qty,
    p.actual_qty,
    p.defect_qty,
    p.material_cost,
    p.labor_cost,
    p.overhead_cost,
    p.material_cost + p.labor_cost + p.overhead_cost as total_cost,
    p.status,
    p.shift,
    coalesce(q.inspection_count, 0) as inspection_count,
    coalesce(q.total_samples, 0) as total_samples,
    coalesce(q.total_pass, 0) as total_pass,
    coalesce(q.total_fail, 0) as total_fail,
    coalesce(q.pass_rate, 0) as pass_rate,
    round(p.defect_qty * 100.0 / nullif(p.actual_qty, 0), 2) as defect_rate,
    round(p.actual_qty * 100.0 / nullif(p.planned_qty, 0), 2) as achievement_rate
from production p
left join quality_summary q on p.production_order_id = q.production_order_id