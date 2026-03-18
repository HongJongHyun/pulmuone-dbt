
    
    

select
    inspection_id as unique_field,
    count(*) as n_records

from PULMUONE_POC.PUBLIC.quality_inspections
where inspection_id is not null
group by inspection_id
having count(*) > 1


