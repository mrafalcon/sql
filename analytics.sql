with temp_all as (select distinct n.id_bsk, count (*)
from (
select id_bsk
from project1.cards
where id_error is null and id_flight is not null) n
group by n.id_bsk
order by count desc),

temp_double as (
select distinct bsk, count (*)
from project1.query_passangers
group by bsk
order by count desc)

select ta.id_bsk, ta.count as one_side, tb.count*2 as double_side, round ((tb.count*2*100 / ta.count::numeric), 2) as percent_double
from temp_all ta
left join temp_double tb
on ta.id_bsk = tb.bsk
order by percent_double desc
--where ta.count < tb.count*2
