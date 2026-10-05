-- Author: Gerardo Najarro
-- Created: 10/02/2026

-- Lego SQL Challenge (Snowflake)
-- Part 1: Schema setup
-- Part 2: Unique parts analysis
-- Part 3: Tableau dashboard (built outside this file, using the exported views)

-- ============================================================
-- PART 1: SCHEMA SETUP
-- ============================================================

-- creates my own schema to hold all the tables
create schema if not exists gerard_lego;

-- use to explore and help determine the best fitting data type for each column
-- select
--     min(id),
--     max(id),
--     max(length(name)),
--     max(length(rgb)),
--     max(length(is_trans))
-- from staging.lego_colors;

-- select
--     min(id),
--     max(id),
--     min(version),
--     max(version),
--     max(length(set_num))
-- from staging.lego_inventories;

-- select
--     min(inventory_id),
--     max(inventory_id),
--     max(length(part_num)),
--     min(color_id),
--     max(color_id),
--     min(quantity),
--     max(quantity),
--     max(length(is_spare))
-- from staging.lego_inventory_parts;


-- select
--     min(id),
--     max(id),
--     max(length(name))
-- from staging.lego_part_categories;


-- select
--     min(inventory_id),
--     max(inventory_id),
--     max(length(set_num)),
--     min(quantity),
--     max(quantity)
-- from staging.lego_inventory_sets;

-- select
--     max(length(part_num)),
--     max(length(name)), 
--     min(part_cat_id),
--     max(part_cat_id)
-- from staging.lego_parts;

-- select
--     max(length(set_num)), 
--     max(length(name)),
--     min(year),
--     max(year),
--     min(theme_id),
--     max(theme_id),
--     min(num_parts),
--     max(num_parts)
-- from staging.lego_sets;

-- select
--     min(id),
--     max(id),
--     max(length(name)), 
--     min(parent_id),
--     max(parent_id)
-- from staging.lego_themes;

-- clears out any previous version so the script starts clean every time
drop table if exists gerard_lego.colors cascade;
drop table if exists gerard_lego.inventories cascade;
drop table if exists gerard_lego.inventory_parts cascade;
drop table if exists gerard_lego.inventory_sets cascade;
drop table if exists gerard_lego.part_categories cascade;
drop table if exists gerard_lego.parts cascade;
drop table if exists gerard_lego.sets cascade;
drop table if exists gerard_lego.themes cascade;

-- defines each table with the data types picked from the exploration queries above
create table gerard_lego.colors (
	id smallint,
	name varchar(50),
	rgb varchar(6),
	is_trans varchar(1)
);

create table gerard_lego.inventories (
	id smallint,
	version smallint,
	set_num varchar(20)
);

create table gerard_lego.inventory_parts (
	inventory_id smallint,
	part_num varchar(15),
	color_id smallint,
	quantity smallint,
	is_spare varchar(1)
);

create table gerard_lego.inventory_sets (
	inventory_id smallint,
	set_num varchar(20),
	quantity smallint
	);

create table gerard_lego.part_categories (
	id smallint,
	name varchar(50)
);

create table gerard_lego.parts (
	part_num varchar(15),
	name varchar(255),
	part_cat_id smallint
);

create table gerard_lego.sets (
	set_num varchar(20),
	name varchar(100),
	year smallint,
	theme_id smallint,
	num_parts smallint
);

create table gerard_lego.themes (
	id smallint,
	name varchar(50),
	parent_id smallint
);

-- copies the raw data from staging into the created tables in my schema
insert into gerard_lego.colors (
	select * from staging.lego_colors
);

insert into gerard_lego.inventories (
	select * from staging.lego_inventories
);

insert into gerard_lego.inventory_parts (
	select * from staging.lego_inventory_parts
);

insert into gerard_lego.inventory_sets (
	select * from staging.lego_inventory_sets
);

insert into gerard_lego.part_categories (
	select * from staging.lego_part_categories
);

insert into gerard_lego.parts (
	select * from staging.lego_parts
);

insert into gerard_lego.sets (
	select * from staging.lego_sets
);

-- themes needs the parent_id cast to smallint so it matches the table definition
insert into gerard_lego.themes (
	select 
		id,
		name,
		cast(parent_id as smallint)
	from staging.lego_themes
);

-- fill in missing parts that are only found within the inventory parts table
-- (the name and category are unknown for these, so they stay null)
insert into gerard_lego.parts (
	select distinct
		IP.part_num,
		null as name,
		cast(null as smallint) as part_cat_id
		from gerard_lego.inventory_parts as IP
	left join gerard_lego.parts as P ON IP.part_num = P.part_num
	where P.part_num is null
);

-- Add primary keys: marks the unique identifier for each table
-- (inventory_parts and inventory_sets do not get one)
alter table gerard_lego.colors add primary key (id);
alter table gerard_lego.inventories add primary key (id);
alter table gerard_lego.parts add primary key (part_num);
alter table gerard_lego.part_categories add primary key (id);
alter table gerard_lego.sets add primary key (set_num);
alter table gerard_lego.themes add primary key (id);

-- Add foreign keys: enforces the relationships between the tables
alter table gerard_lego.parts add foreign key (part_cat_id) 
	references gerard_lego.part_categories(id);


alter table gerard_lego.inventory_parts add foreign key (inventory_id) 
	references gerard_lego.inventories(id);

alter table gerard_lego.inventory_parts add foreign key (part_num) 
	references gerard_lego.parts(part_num);

alter table gerard_lego.inventory_parts add foreign key (color_id) 
	references gerard_lego.colors(id);


alter table gerard_lego.inventory_sets add foreign key (inventory_id) 
	references gerard_lego.inventories(id);

alter table gerard_lego.inventory_sets add foreign key (set_num) 
	references gerard_lego.sets(set_num);


alter table gerard_lego.sets add foreign key (theme_id) 
	references gerard_lego.themes(id);


alter table gerard_lego.inventories add foreign key (set_num) 
	references gerard_lego.sets(set_num);

-- ============================================================
-- PART 2: UNIQUE PARTS ANALYSIS
-- ============================================================

-- 1. Unique Parts Identification:
-- Identify parts that appear in only one LEGO set. Note the quantity of the part does not matter.

create view unique_parts_view as

-- pt: links each part to the inventory it shows up in
with pt as (
    select
        parts.part_num,
        inventory_id as id
    from parts
        inner join inventory_parts
            on parts.part_num = inventory_parts.part_num
),

-- st: one row per set inventory, with the set name, year and theme name added
st as (
    select
        sets.set_num,
        inventories.id,
        sets.name as set_name,
        year,
        themes.name as theme_name,
        num_parts
    from sets
        inner join inventories
            on sets.set_num = inventories.set_num
        inner join themes
            on sets.theme_id = themes.id
),

-- mt: combines the two above so every part is paired with its set details
mt as (
    select
        part_num,
        set_num,
        st.id,
        set_name,
        year,
        theme_name,
        num_parts 
    from pt
        inner join st
            on pt.id = st.id
),

-- lt: the list of unique parts, meaning parts that appear in only one set
lt as (
    select part_num as unique_part_num
    from mt
    group by part_num
    having count(distinct set_num) = 1
)

-- 2. Set Analysis:
-- For each LEGO set, calculate the number of unique parts it includes and the total number of parts (we're looking for a count of the parts, not quantity). Calculate the ratio of unique parts to total parts as a measure of 'uniqueness' for each set. Enrich your query with the set year and theme name.

-- final select: left join keeps every part in each set, not just the unique ones
-- unique_parts counts the parts that matched the unique list
-- total_parts counts all parts in the set
-- uniqueness_ratio is unique parts compared to total parts, rounded to 2 decimals
select
    set_name,
    year,
    theme_name,
    count(case when unique_part_num is not null then 1 end) as unique_parts,
    count(part_num) as total_parts,
    round(count(case when unique_part_num is not null then 1 end)/count(part_num), 2)::float AS uniqueness_ratio
from mt
    left join lt
        on mt.part_num = lt.unique_part_num
group by all
;

-- 3. Create a View:
-- Lastly, you'll want to create a view of your final query, which includes the set name, year of release, theme, number of unique parts, total number of parts, and 'uniqueness' ratio.

-- completed in step 1.

-- Extra view for my own analysis:
-- a master table with one row per part per set, plus a Unique / Not Unique tag
-- built to connect with the uniqueness ratio table in the dashboard
create or alter view main_table_view as

-- pt: links each part to the inventory it shows up in
with pt as (
    select
        parts.part_num,
        inventory_id as id
    from parts
        inner join inventory_parts
            on parts.part_num = inventory_parts.part_num
),

-- st: one row per set inventory, with the set name, year and theme name added
st as (
    select
        sets.set_num,
        inventories.id,
        sets.name as set_name,
        year,
        themes.name as theme_name,
        num_parts
    from sets
        inner join inventories
            on sets.set_num = inventories.set_num
        inner join themes
            on sets.theme_id = themes.id
),

-- lt: counts how many sets each part appears in, then tags it
-- Unique if it appears in exactly one set, Not Unique otherwise
lt as (
    select
        part_num,
        case when set_count = 1 then 'Unique' else 'Not Unqiue' end as unique_tracker
    from (
        -- subquery: number of sets each part appears in
        select
            part_num,
            count(distinct set_num) as set_count
        from pt
            inner join st
                on pt.id = st.id
        group by 1
    )
)

-- final select: every part in every set with its set details and unique tag
select
    pt.part_num,
    set_num,
    st.id,
    set_name,
    year,
    theme_name,
    unique_tracker 
from pt
    inner join st
        on pt.id = st.id
    inner join lt
        on pt.part_num = lt.part_num
;

-- 4. Download your data and save it locally as a csv.
-- Run a query to extract the data from your view and save it to a csv file, we'll be adding this to our GitHub repo later.

-- uniqueness ratio view results (csv export)
select * 
from unique_parts_view
;

-- master table view results (csv export)
select * 
from main_table_view
;