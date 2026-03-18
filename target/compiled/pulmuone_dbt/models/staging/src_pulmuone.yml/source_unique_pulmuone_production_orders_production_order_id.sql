
    
    

select
    production_order_id as unique_field,
    count(*) as n_records

from PULMUONE_POC.PUBLIC.production_orders
where production_order_id is not null
group by production_order_id
having count(*) > 1


