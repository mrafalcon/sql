-- Table: project1.cards

DROP TABLE IF EXISTS project1.cards;

CREATE TABLE IF NOT EXISTS project1.cards
(
    date_time timestamp without time zone,
    id_bsk bigint,
    id_error integer,
    id_comp text COLLATE pg_catalog."default",
    id_car text COLLATE pg_catalog."default",
    id_route text COLLATE pg_catalog."default",
    id_naryad integer,
    id_flight integer,
    count integer
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS project1.cards
    OWNER to postgres;
-- Index: ind_cards

DROP INDEX IF EXISTS project1.ind_cards;

CREATE INDEX IF NOT EXISTS ind_cards
    ON project1.cards USING btree
    (date_time ASC NULLS LAST, 
	 id_bsk ASC NULLS LAST, 
	 id_error ASC NULLS FIRST, 
	 id_comp ASC NULLS LAST, 
	 id_car ASC NULLS LAST, 
	 id_route ASC NULLS LAST, 
	 id_naryad ASC NULLS LAST, 
	 id_flight ASC NULLS LAST, 
	 count ASC NULLS LAST)
    TABLESPACE pg_default;

-- Table: project1.flights

DROP TABLE IF EXISTS project1.flights;

CREATE TABLE IF NOT EXISTS project1.flights
(
    date_time timestamp without time zone,
    type_route text,
    id_route text ,
    id_naryad integer,
    id_part integer,
    id_car text,
    id_stop text,
    time_arr timestamp without time zone,
    time_dep timestamp without time zone,
    count_flights text,
    move_time text,
    to_depot text
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS project1.flights
    OWNER to postgres;
-- Index: ind_flights

DROP INDEX IF EXISTS project1.ind_flights;

CREATE INDEX IF NOT EXISTS ind_flights
    ON project1.flights USING btree
    (date_time ASC NULLS LAST, 
	 type_route ASC NULLS LAST, 
	 id_route ASC NULLS LAST, 
	 id_naryad ASC NULLS LAST, 
	 id_part ASC NULLS LAST, 
	 id_car ASC NULLS LAST, 
	 id_stop ASC NULLS LAST, 
	 time_arr ASC NULLS LAST, 
	 time_dep ASC NULLS LAST, 
	 count_flights ASC NULLS LAST, 
	 move_time ASC NULLS LAST, 
	 to_depot ASC NULLS LAST)
    TABLESPACE pg_default;
	
-- Table: project1.routes

DROP TABLE IF EXISTS project1.routes;

CREATE TABLE IF NOT EXISTS project1.routes
(
    id_route text ,
    stop_1 text ,
    stop_2 text
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS project1.routes
    OWNER to postgres;
-- Index: ind_routes

DROP INDEX IF EXISTS project1.ind_routes;

CREATE INDEX IF NOT EXISTS ind_routes
    ON project1.routes USING btree
    (id_route COLLATE pg_catalog."default" ASC NULLS LAST, 
	 stop_1 COLLATE pg_catalog."default" ASC NULLS LAST, 
	 stop_2 COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;
	
	
-- Table: project1.passangers

DROP TABLE IF EXISTS project1.query_passangers;

CREATE TABLE IF NOT EXISTS project1.query_passangers
(
    bsk bigint,
	route text,
	--naryad int,
	car text,
	--row_flight int,
	time_dep timestamp without time zone,
	created_at timestamp without time zone,
	time_back timestamp without time zone,
	next_route text,
	--next_naryad int,
	next_car text,
	--next_row_flight int,
	next_time_dep timestamp without time zone,
	next_created_at timestamp without time zone,
	next_time_back timestamp without time zone,
	duration interval
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS project1.query_passangers
    OWNER to postgres;
-- Index: ind_routes

DROP INDEX IF EXISTS project1.ind_query_passangers;

CREATE INDEX ind_query_passangers
    ON project1.query_passangers USING btree
    (bsk ASC NULLS LAST,
	route ASC NULLS LAST,
	--naryad ASC NULLS LAST,
	car ASC NULLS LAST,
	--row_flight ASC NULLS LAST,
	time_dep ASC NULLS LAST,
	created_at ASC NULLS LAST,
	time_back ASC NULLS LAST,
	next_route ASC NULLS LAST,
	--next_naryad ASC NULLS LAST,
	next_car ASC NULLS LAST,
	--next_row_flight ASC NULLS LAST,
	next_time_dep ASC NULLS LAST,
	next_created_at ASC NULLS LAST,
	next_time_back ASC NULLS LAST,
	duration ASC NULLS LAST )
    TABLESPACE pg_default;
