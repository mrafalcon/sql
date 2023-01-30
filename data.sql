with preptable as (
	select id_bsk as bsk, id_route as route, id_flight as flight, date_time as created_at, id_car as car,
	lead(id_route) over (partition by id_bsk order by date_time)  as next_route, 
	lead(id_flight) over (partition by id_bsk order by date_time)  as next_flight, 
	lead(date_time)  over (partition by id_bsk order by date_time) as next_created_at, 
	lead(id_car)  over (partition by id_bsk order by date_time) as next_car
	from project1.cards
	where id_error is null
  )

--select distinct n.duration::time, count (*)
--from (
select *
from (
select *, next_created_at-created_at as duration,
	case 
		when (flight is null or next_flight is null) then 6 -- транзакции на парковых рейсах
		when created_at::time < '04:00:00' then 5 -- транзакция до начала движения по маршрутам
		when car = next_car and flight = next_flight and next_created_at-created_at < '02:00:00' then 4 -- повторное прикладывание на 1 рейсе
		--when (next_created_at-created_at > '16:00:00' ) then 3 -- промежуток более 16 часов (при нормальном 8часовом сне для человека)	
		--when (next_created_at-created_at < '00:01:30' and car = next_car) then 2 --повторное прикладывание в пределах 1 перегона?
		--when (route = '19 ТМ' and next_created_at-created_at < '00:17:30' and car = next_car) then 1 --повторное прикладывание в пределах 1 рейса? 19 ТМ - 1 рейс -> 18мин30сек - перегон без пассажиров (1 минута) = 17:30
		--when (route = '48 ТМ' and next_created_at-created_at < '00:45:30' and car = next_car) then 1 --повторное прикладывание в пределах 1 рейса? 48 ТМ 1 рейс - перегон без пассажиров (1 минута)
	end as possible_error
from preptable
where next_created_at:: date = created_at:: date
order by next_created_at-created_at ASC 
) n
where possible_error is null --and  car = next_car
--) n
--group by duration
--order by duration