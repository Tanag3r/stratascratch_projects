CREATE TABLE IF NOT EXISTS historic_data_bronze AS SELECT * FROM 'C:\Users\lukew\stratascratch_projects\stratascratch_projects\doordash_delivery_est\historical_data.csv';

CREATE TABLE IF NOT EXISTS main.historic_data_silver(
market_id integer,
created_at timestamp not null,
actual_delivery_time timestamp not null,
store_id integer not null,
store_primary_category varchar,
order_protocol integer,
total_items integer,
subtotal integer,
num_distinct_items integer,
min_item_price integer,
max_item_price integer,
total_onshift_dashers integer,
total_busy_dashers integer,
total_outstanding_orders integer,
estimated_order_place_duration integer,
estimated_store_to_consumer_driving_duration integer,
latest_update as (transaction_timestamp()));

--Filter view for store primary category labels
create view if not exists clean_store_category as 
with categories as (select
	store_id,
	store_primary_category,
	count(store_id) as label_count,
	DENSE_RANK() over (partition by store_id order by count(store_id) desc) as label_count_rank,
	lead(store_primary_category,1) over (partition by store_id order by count(store_id) desc) as next_category_value
from main.historic_data_bronze 
group by store_id,store_primary_category
order by store_id,label_count_rank)
select *,
	case when label_count_rank = 1 and store_primary_category <> 'NA' then store_primary_category
	when label_count_rank = 1 and store_primary_category = 'NA' and next_category_value is not null then next_category_value
	else null end as clean_store_primary_category
from categories
where clean_store_primary_category is not null
--where label_count_rank = 1
--and store_primary_category <> 'NA'
--where store_id in (4717,4369,4152,4173,1121,1224)
;

select * from main.clean_store_category limit 25;