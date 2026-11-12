--create Database pizza_runner;
use pizza_runner

-- 1. RUNNERS TABLE

DROP TABLE IF EXISTS runners;
GO

CREATE TABLE runners (
  "runner_id" INTEGER,
  "registration_date" DATE
);
GO

INSERT INTO runners
  ("runner_id", "registration_date")
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');
GO



-- 2. CUSTOMER ORDERS TABLE

DROP TABLE IF EXISTS customer_orders;
GO

CREATE TABLE customer_orders (
  "order_id" INTEGER,
  "customer_id" INTEGER,
  "pizza_id" INTEGER,
  "exclusions" VARCHAR(4),
  "extras" VARCHAR(4),
  "order_time" DATETIME2 -- Changed TIMESTAP to DATETIME2
);
GO

INSERT INTO customer_orders
  ("order_id", "customer_id", "pizza_id", "exclusions", "extras", "order_time")
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49');
GO



-- 3. RUNNER ORDERS TABLE

DROP TABLE IF EXISTS runner_orders;
GO

CREATE TABLE runner_orders (
  "order_id" INTEGER,
  "runner_id" INTEGER,
  "pickup_time" VARCHAR(19),
  "distance" VARCHAR(7),
  "duration" VARCHAR(10),
  "cancellation" VARCHAR(23)
);
GO

INSERT INTO runner_orders
  ("order_id", "runner_id", "pickup_time", "distance", "duration", "cancellation")
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');
GO


-- 4. PIZZA NAMES TABLE

DROP TABLE IF EXISTS pizza_names;
GO

CREATE TABLE pizza_names (
  "pizza_id" INTEGER,
  "pizza_name" VARCHAR(50) -- Changed TEXT to VARCHAR
);
GO

INSERT INTO pizza_names
  ("pizza_id", "pizza_name")
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');
GO


-- 5. PIZZA RECIPES TABLE

DROP TABLE IF EXISTS pizza_recipes;
GO

CREATE TABLE pizza_recipes (
  "pizza_id" INTEGER,
  "toppings" VARCHAR(MAX) -- Changed TEXT to VARCHAR
);
GO

INSERT INTO pizza_recipes
  ("pizza_id", "toppings")
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');
GO



-- 6. PIZZA TOPPINGS TABLE

DROP TABLE IF EXISTS pizza_toppings;
GO

CREATE TABLE pizza_toppings (
  "topping_id" INTEGER,
  "topping_name" VARCHAR(50) -- Changed TEXT to VARCHAR
);
GO

INSERT INTO pizza_toppings
  ("topping_id", "topping_name")
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');
GO

--Data Cleaning


update customer_orders set exclusions = null where exclusions = ''
update customer_orders set exclusions = null where exclusions = 'null'
update customer_orders set extras = null where extras= '' or extras = 'null'
update runner_orders set pickup_time = null where pickup_time = 'null'
update runner_orders set distance= null where distance = 'null'
update runner_orders set duration = null where duration = 'null'
update runner_orders set cancellation= null where cancellation = 'null' or cancellation = ''
update runner_orders set distance = REPLACE(distance,'km','') where distance like '%km'
update runner_orders set duration = REPLACE(duration,'minutes','') where duration like '%minutes'
update runner_orders set duration = REPLACE(duration,'mins','') where duration like '%mins'
update runner_orders set duration = REPLACE(duration,'minute','') where duration like '%minute'

alter table runner_orders alter column distance decimal(5,2)
alter table runner_orders alter column duration int
alter table runner_orders alter column pickup_time datetime2

exec sp_rename 'runner_orders.distance','distance_km','column'
exec sp_rename 'runner_orders.durarion_minutes','duration_minutes','column'

select * from customer_orders
select * from runners
select * from runner_orders
select * from pizza_toppings
select * from pizza_names
select * from pizza_recipes


--A. Pizza Metrics

--How many pizzas were ordered?
select count(order_id) as total_pizzas_ordered from customer_orders
--How many unique customer orders were made?
select count (distinct customer_id) as Total_unique_customers from customer_orders
--How many successful orders were delivered by each runner?
select count(order_id) as successful_orders from runner_orders
where cancellation is null
--How many of each type of pizza was delivered?
select pizza_id, count(runner_orders.order_id) from customer_orders
join runner_orders on runner_orders.order_id = customer_orders.order_id
where cancellation is null
group by pizza_id

--How many Vegetarian and Meatlovers were ordered by each customer?
select pizza_name, count(order_id) as orders from customer_orders
join pizza_names on pizza_names.pizza_id = customer_orders.pizza_id
group by pizza_name
--What was the maximum number of pizzas delivered in a single order?
select customer_orders.order_id,count(pizza_id) max_number_of_pizzas from customer_orders
join runner_orders on runner_orders.order_id = customer_orders.order_id
where cancellation is null
group by customer_orders.order_id
--For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
select customer_id, count(pizza_id) as pizzas_without_changes from customer_orders
join runner_orders on runner_orders.order_id = customer_orders.order_id
where exclusions is not null or extras is not null and cancellation is null
group by customer_id

select customer_id, count(pizza_id) as pizzas_without_changes from customer_orders
join runner_orders on runner_orders.order_id = customer_orders.order_id
where exclusions is null and extras is null and cancellation is null
group by customer_id
--How many pizzas were delivered that had both exclusions and extras?
select customer_id, count(pizza_id) as pizzas_with_changes from customer_orders
join runner_orders on runner_orders.order_id = customer_orders.order_id
where exclusions is not null and extras is not null and cancellation is null
group by customer_id
--What was the total volume of pizzas ordered for each hour of the day?
select datepart(hour,order_time) as hour_of_day, count(pizza_id) as number_of_pizza from customer_orders
group by datepart(hour,order_time)
order by hour_of_day
--What was the volume of orders for each day of the week?
select datename(weekday,order_time) as day_of_week, count(pizza_id) as number_of_ordes from customer_orders
group by datename(weekday,order_time)
order by day_of_week
--B. Runner and Customer Experience

--How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
select 
  case 
    when registration_date between '2021-01-01' and '2021-01-07' then 'week 1 (jan 1)'
    when registration_date between '2021-01-08' and '2021-01-14' then 'week 2 (jan 8)'
    else 'week 3 (jan 15)'
  end as registration_week,
  count(runner_id) as runner_signups
from runners
group by 
  case 
    when registration_date between '2021-01-01' and '2021-01-07' then 'week 1 (jan 1)'
    when registration_date between '2021-01-08' and '2021-01-14' then 'week 2 (jan 8)'
    else 'week 3 (jan 15)'
  end;

--What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
select 
  r.runner_id,
  avg(datediff(minute, c.order_time, r.pickup_time)) as avg_pickup_minutes
from runner_orders r
join customer_orders c 
  on r.order_id = c.order_id
where r.pickup_time is not null
group by r.runner_id;

--Is there any relationship between the number of pizzas and how long the order takes to prepare?
select 
  c.order_id,
  count(c.pizza_id) as pizza_count,
  datediff(minute, c.order_time, r.pickup_time) as prep_time_minutes
from customer_orders c
join runner_orders r 
  on c.order_id = r.order_id
where r.pickup_time is not null
group by c.order_id, c.order_time, r.pickup_time
order by pizza_count;

--What was the average distance travelled for each customer?
select 
  c.customer_id,
  avg(distance_km) as avg_distance_km
from customer_orders c
join runner_orders r 
  on c.order_id = r.order_id
where r.pickup_time is not null
group by c.customer_id
order by c.customer_id;

--What was the difference between the longest and shortest delivery times for all orders?
select 
  max(duration_minutes) - min(duration_minutes) as time_difference_minutes
from runner_orders
where pickup_time is not null;

--What was the average speed for each runner for each delivery and do you notice any trend for these values?
select 
  runner_id,
  order_id,
  round(distance_km  / (duration_minutes / 60.0), 1) as speed_kmh
from runner_orders
where pickup_time is not null
order by runner_id, order_id;

--What is the successful delivery percentage for each runner?
select 
  runner_id,
  count(pickup_time) * 100 / count(*) as success_percentage
from runner_orders
group by runner_id
order by runner_id;

--C. Ingredient Optimisation

--What are the standard ingredients for each pizza?
select pizza_name, toppings from pizza_names pn
join pizza_recipes pr on pr.pizza_id = pn.pizza_id
--What was the most commonly added extra?
select order_id, extras from customer_orders where extras is not null
--What was the most common exclusion?
select order_id, exclusions from customer_orders where exclusions is not null
/*Generate an order item for each record in the customers_orders table in the format of one of the following:
Meat Lovers
Meat Lovers - Exclude Beef
Meat Lovers - Extra Bacon
Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers*/
select 
  order_id,
  customer_id,
  case 
    when pizza_id = 1 then 'Meat Lovers'
    else 'Vegetarian'
  end
  -- add exclusions if they exist
  + case 
      when exclusions is not null and exclusions not in ('', 'null') then 
        ' - exclude ' + 
        replace(replace(replace(replace(replace(replace(
          exclusions, 
          '2', 'BBQ Sauce'), 
          '3', 'Beef'), 
          '4', 'Cheese'), 
          '6', 'Mushrooms'),
          '1', 'Bacon'),
          '5', 'Chicken')
      else '' 
    end
  -- Add Extras if they exist
  + case 
      when extras is not null and extras not in ('', 'null') then 
        ' - extra ' + 
        replace(replace(replace(replace(replace(replace(
          extras, 
          '1', 'Bacon'), 
          '4', 'Cheese'), 
          '5', 'Chicken'), 
          '6', 'Mushrooms'),
          '8', 'Pepperoni'),
          '9', 'Peppers')
      else '' 
    end as order_item
from customer_orders;

/*Generate an alphabetically ordered comma separated ingredient list for 
each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"*/
-- Part 1: Meat Lovers (pizza_id = 1)
select 
  order_id,
  'meat lovers: ' +
  case when extras like '%1%' then '2xbacon, ' else 'bacon, ' end +
  case when exclusions like '%2%' then '' else 'bbq sauce, ' end +
  'beef, ' +
  case 
    when exclusions like '%4%' then ''
    when extras like '%4%' then '2xcheese, '
    else 'cheese, ' 
  end +
  case when extras like '%5%' then '2xchicken, ' else 'chicken, ' end +
  case when exclusions like '%6%' then '' else 'mushrooms, ' end +
  'pepperoni, salami' as ingredient_list
from customer_orders
where pizza_id = 1

union all

-- Part 2: Vegetarian (pizza_id = 2)
select 
  order_id,
  'Vegetarian: ' +
  -- Bacon is NOT standard on Vegetarian, so only add it if ordered as Extra ('1')
  case when extras like '%1%' then 'Bacon, ' else '' end +
  -- cheese ('4') can be excluded on vegetarian
  case when exclusions LIKE '%4%' then '' else 'Cheese, ' end +
  'Mushrooms, Onions, Peppers, Tomato Sauce, Tomatoes' as ingredient_list
from customer_orders
where pizza_id = 2

order by order_id;


--What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?
select * from (
  -- 1. bacon (standard on meat lovers, can be extra '1')
  select 'bacon' as topping_name, 
    sum(case when c.pizza_id = 1 then 1 else 0 end + case when c.extras like '%1%' then 1 else 0 end) as total_used
  from customer_orders c join runner_orders r on c.order_id = r.order_id where r.pickup_time is not null

  union all
  -- 2. mushrooms (standard on both pizzas, can be excluded '6')
  select 'mushrooms', 
    sum(1 - case when c.exclusions like '%6%' then 1 else 0 end)
  from customer_orders c join runner_orders r on c.order_id = r.order_id where r.pickup_time is not null

  union all
  -- 3. cheese (standard on both pizzas, can be excluded '4' or extra '4')
  select 'cheese', 
    sum(1 + case when c.extras like '%4%' then 1 else 0 end - case when c.exclusions like '%4%' then 1 else 0 end)
  from customer_orders c join runner_orders r on c.order_id = r.order_id where r.pickup_time is not null

  union all
  -- 4, 5, 6, 7. beef, chicken, pepperoni, salami (always 1 per meat lovers, never changed)
  select 'beef', sum(case when c.pizza_id = 1 then 1 else 0 end)
  from customer_orders c join runner_orders r on c.order_id = r.order_id where r.pickup_time is not null
  union all
  select 'chicken', sum(case when c.pizza_id = 1 then 1 else 0 end)
  from customer_orders c join runner_orders r on c.order_id = r.order_id where r.pickup_time is not null
  union all
  select 'pepperoni', sum(case when c.pizza_id = 1 then 1 else 0 end)
  from customer_orders c join runner_orders r on c.order_id = r.order_id where r.pickup_time is not null
  union all
  select 'salami', sum(case when c.pizza_id = 1 then 1 else 0 end)
  from customer_orders c join runner_orders r on c.order_id = r.order_id where r.pickup_time is not null

  union all
  -- 8. bbq sauce (standard on meat lovers, can be excluded '2')
  select 'bbq sauce', 
    sum(case when c.pizza_id = 1 then 1 else 0 end - case when c.exclusions like '%2%' then 1 else 0 end)
  from customer_orders c join runner_orders r on c.order_id = r.order_id where r.pickup_time is not null

  union all
  -- 9, 10, 11, 12. onions, peppers, tomatoes, tomato sauce (always 1 per vegetarian, never changed)
  select 'onions', sum(case when c.pizza_id = 2 then 1 else 0 end)
  from customer_orders c join runner_orders r on c.order_id = r.order_id where r.pickup_time is not null
  union all
  select 'peppers', sum(case when c.pizza_id = 2 then 1 else 0 end)
  from customer_orders c join runner_orders r on c.order_id = r.order_id where r.pickup_time is not null
  union all
  select 'tomatoes', sum(case when c.pizza_id = 2 then 1 else 0 end)
  from customer_orders c join runner_orders r on c.order_id = r.order_id where r.pickup_time is not null
  union all
  select 'tomato sauce', sum(case when c.pizza_id = 2 then 1 else 0 end)
  from customer_orders c join runner_orders r on c.order_id = r.order_id where r.pickup_time is not null
) as ingredient_totals
order by total_used desc;


--D. Pricing and Ratings


/*If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were 
no charges for changes - how much money has Pizza Runner made so far if 
there are no delivery fees?*/
select 
  sum(case when c.pizza_id = 1 then 12 else 10 end) as total_revenue
from customer_orders c
join runner_orders r on c.order_id = r.order_id
where r.pickup_time is not null;

--What if there was an additional $1 charge for any pizza extras?Add cheese is $1 extra
select 
  sum(
    case when c.pizza_id = 1 then 12 else 10 end
    + case 
        when c.extras is not null and c.extras not in ('', 'null') 
        then len(c.extras) - len(replace(c.extras, ',', '')) + 1 
        else 0 
      end
    + case when c.extras like '%4%' then 1 else 0 end
  ) as total_revenue_with_extras
from customer_orders c
join runner_orders r on c.order_id = r.order_id
where r.pickup_time is not null;

/*The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, 
how would you design an additional table for this new dataset - 
generate a schema for this new table and insert your own data for ratings for each 
successful customer order between 1 to 5.*/
create table runner_ratings (
  order_id int primary key,
  rating int check (rating between 1 and 5)
);

insert into runner_ratings (order_id, rating)
values 
  (1, 5),
  (2, 4),
  (3, 5),
  (4, 3),
  (5, 5),
  (7, 4),
  (8, 5),
  (10, 4);

/*Using your newly generated table - can you join all of the information 
together to form a table which has the following information for successful deliveries?
customer_id
order_id
runner_id
rating
order_time
pickup_time
Time between order and pickup
Delivery duration
Average speed
Total number of pizzas*/
select 
  c.customer_id,
  c.order_id,
  r.runner_id,
  rr.rating,
  c.order_time,
  r.pickup_time,
  datediff(minute, c.order_time, r.pickup_time) as mins_to_pickup,
  r.duration as delivery_duration_mins,
  round(r.distance / (r.duration / 60.0), 1) as avg_speed_kmh,
  count(c.pizza_id) as total_pizzas
from customer_orders c
join runner_orders r on c.order_id = r.order_id
join runner_ratings rr on c.order_id = rr.order_id
where r.pickup_time is not null
group by 
  c.customer_id, c.order_id, r.runner_id, rr.rating, 
  c.order_time, r.pickup_time, r.duration, r.distance
order by c.order_id;

/*If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no 
cost for extras and each runner is paid $0.30 per kilometre traveled - 
how much money does Pizza Runner have left over after these deliveries?*/
with pizza_sales as (
  select sum(case when c.pizza_id = 1 then 12 else 10 end) as revenue
  from customer_orders c
  join runner_orders r on c.order_id = r.order_id
  where r.pickup_time is not null
),
runner_costs as (
  select sum(distance) * 0.30 as delivery_cost
  from runner_orders
  where pickup_time is not null
)
select 
  revenue,
  delivery_cost,
  revenue - delivery_cost as net_profit
from pizza_sales, runner_costs;

--E. Bonus Questions

/*If Danny wants to expand his range of pizzas - how would this impact the existing data 
design? Write an INSERT statement to demonstrate what would happen if a new Supreme pizza
with all the toppings was added to the Pizza Runner menu?*/
insert into pizza_names (pizza_id, pizza_name)
values (3, 'supreme');

insert into pizza_recipes (pizza_id, toppings)
values (3, '1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12');
