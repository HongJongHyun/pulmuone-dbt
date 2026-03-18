
with production as (
    select * from PULMUONE_POC.intermediate.int_production_with_quality
),
products as (
    select * from PULMUONE_POC.staging.stg_products
),
monthly_metrics as (
    select
        date_trunc('month', p.order_date) as month,
        p.plant_code,
        p.production_line,
        pr.product_category,
        pr.brand,
        count(distinct p.production_order_id) as order_count,
        sum(p.planned_qty) as total_planned,
        sum(p.actual_qty) as total_actual,
        sum(p.defect_qty) as total_defects,
        sum(p.total_cost) as total_cost,
        avg(p.achievement_rate) as avg_achievement_rate,
        avg(p.defect_rate) as avg_defect_rate,
        avg(p.pass_rate) as avg_pass_rate,
        sum(p.material_cost) as total_material_cost,
        sum(p.labor_cost) as total_labor_cost,
        sum(p.overhead_cost) as total_overhead_cost
    from production p
    join products pr on p.product_id = pr.product_id
    where p.status = 'COMPLETED'
    group by 1, 2, 3, 4, 5
)
select
    month,
    plant_code,
    production_line,
    product_category,
    brand,
    order_count,
    total_planned,
    total_actual,
    total_defects,
    round(total_cost, 2) as total_cost,
    round(avg_achievement_rate, 2) as avg_achievement_rate,
    round(avg_defect_rate, 2) as avg_defect_rate,
    round(avg_pass_rate, 2) as avg_pass_rate,
    round(total_cost / nullif(total_actual, 0), 2) as cost_per_unit,
    round(total_material_cost * 100.0 / nullif(total_cost, 0), 2) as material_cost_pct,
    round(total_labor_cost * 100.0 / nullif(total_cost, 0), 2) as labor_cost_pct
from monthly_metrics