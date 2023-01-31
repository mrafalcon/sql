delete from project1.query_passangers;

with 
PrepTable as (
	select 
	date_time :: date, 
	case 
	when type_route like '% Трамваи' then id_route|| ' ТМ'
	when type_route like '% Троллейбусы' then id_route|| ' ТБ'
	end as id_route, 
	id_naryad, id_part, id_car, id_stop, time_dep, 
	split_part(count_flights, ',', 1) :: integer as count_flights, 
	case 
	when to_depot like 'Да' then 1
	else 0
	end as to_depot
from project1.flights
	),
PrepTable2 as (
select id_route, id_naryad, id_car, id_stop, time_dep, 
	case 
	when time_dep + (lead (time_dep) over (partition by date_time, id_route, id_naryad order by time_dep) - time_dep)/2 is null 
	then time_dep + (time_dep - lag (time_dep) over (partition by date_time, id_route, id_naryad order by time_dep))/2 
	else time_dep + (lead (time_dep) over (partition by date_time, id_route, id_naryad order by time_dep) - time_dep)/2 end as next_time_dep

from PrepTable
where to_depot=0 and count_flights is not null
order by date_time, id_route, id_naryad, id_part, time_dep
	),
PrepTable3 as (
	select *
	from PrepTable2
	),
PrepTable4 as (
	select id_route, id_naryad, id_car, '' as id_stop, lag (next_time_dep) over (partition by id_route, id_naryad order by next_time_dep) as time_dep, 
	time_dep as next_time_dep
	from PrepTable2
	),
PrepTable5 as (	
(select *
from PrepTable4
where time_dep is not null)
union 
(select *
from PrepTable3)
	),
PrepTable6 as (	
select *
from PrepTable5
where next_time_dep - time_dep < '04:00:00'
order by time_dep, id_route, id_naryad, id_car),
PrepTable7 as (	
select p6.id_route, p6.id_naryad, p6.id_car, case when p6.id_stop = r.stop_1 then r.stop_1 else r.stop_2 end as id_stop, p6.time_dep, p6.next_time_dep
from PrepTable6 p6
join project1.routes r
on p6.id_route = r.id_route
order by p6.time_dep, p6.id_route, p6.id_naryad
	),

PrepTable8 as (
	select *, row_number () over (partition by id_route, id_naryad, id_car order by id_route, id_naryad, id_car, time_dep) as row_flight
from PrepTable7
),

PrepTable9 as (
	select p8.id_route, p8.id_naryad, p8.id_car, p8.row_flight, p8.time_dep, pc.id_bsk, pc.id_flight, pc.date_time, p8.next_time_dep
from PrepTable8 p8
join project1.cards pc
on p8.id_route = pc.id_route and p8.id_naryad = pc.id_naryad and p8.id_car = pc.id_car and p8.time_dep < pc.date_time and pc.date_time < p8.next_time_dep
where pc.id_error is null
order by p8.time_dep, p8.id_route, p8.id_naryad, pc.date_time
),

passangers as (
	select id_bsk as bsk, id_route as route, id_naryad, id_car as car,  row_flight, id_flight as flight, time_dep, date_time as created_at, next_time_dep as time_back,
	lead(id_route) over (partition by id_bsk order by date_time)  as next_route, 
	lead(id_naryad)  over (partition by id_bsk order by date_time) as next_id_naryad,
	lead(id_car)  over (partition by id_bsk order by date_time) as next_car,
	lead(row_flight) over (partition by id_bsk order by date_time)  as next_row_flight,
	lead(id_flight) over (partition by id_bsk order by date_time)  as next_flight, 
	lead(time_dep)  over (partition by id_bsk order by date_time) as next_time_dep, 
	lead(date_time)  over (partition by id_bsk order by date_time) as next_created_at, 
	lead(next_time_dep)  over (partition by id_bsk order by date_time) as next_time_back,
	row_number () over (partition by id_bsk, time_dep::date order by id_bsk, date_time)
	from PrepTable9
  )

--select distinct n.duration::time, count (*)
--from (

insert into project1.query_passangers
select 
	bsk, 
	route, 
	--n.id_naryad as naryad, 
	car, 
	--row_flight, 
	time_dep, 
	created_at, 
	time_back, 
	next_route, 
	--n.next_id_naryad as next_naryad, 
	next_car, 
	--next_row_flight, 
	next_time_dep, 
	next_created_at, 
	next_time_back, 
	duration 
	--row_number
from (
select *, next_created_at-created_at as duration,
	case 
		when (flight is null or next_flight is null) then 6 -- транзакции на парковых рейсах
		when created_at::time < '04:00:00' then 5 -- транзакция до начала движения по маршрутам
		when car = next_car and (route = next_route and id_naryad = passangers.next_id_naryad and (flight = next_flight or row_flight = next_row_flight)) then 4 -- повторное прикладывание на 1 рейсе
		--when car = next_car and next_created_at-created_at < '02:00:00' then 4 -- повторное прикладывание на 1 рейсе
		--when (next_created_at-created_at > '16:00:00' ) then 3 -- промежуток более 16 часов (при нормальном 8часовом сне для человека)	
		--when (next_created_at-created_at < '00:01:30' and car = next_car) then 2 --повторное прикладывание в пределах 1 перегона?
		--when (route = '19 ТМ' and next_created_at-created_at < '00:17:30' and car = next_car) then 1 --повторное прикладывание в пределах 1 рейса? 19 ТМ - 1 рейс -> 18мин30сек - перегон без пассажиров (1 минута) = 17:30
		--when (route = '48 ТМ' and next_created_at-created_at < '00:45:30' and car = next_car) then 1 --повторное прикладывание в пределах 1 рейса? 48 ТМ 1 рейс - перегон без пассажиров (1 минута)
	end as possible_error
from passangers
where next_created_at:: date = created_at:: date and mod (row_number, 2) = 1
order by next_created_at-created_at ASC 
) n
where possible_error is null
order by time_dep
