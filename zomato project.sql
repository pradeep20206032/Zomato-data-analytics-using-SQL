
USE ZOMATO;
drop table if exists goldusers_signup;
CREATE TABLE goldusers_signup(userid integer,gold_signup_date date); 

INSERT INTO goldusers_signup(userid,gold_signup_date) 
 VALUES (1,'2017-09-22'),
(3,'2017-04-21');

drop table if exists users;
CREATE TABLE users(userid integer,signup_date date); 

INSERT INTO users(userid,signup_date) 
 VALUES (1,'2014-09-02'),
(2,'2015-01-15'),
(3,'2014-04-11');

drop table if exists sales;
CREATE TABLE sales(userid integer,created_date date,product_id integer); 

INSERT INTO sales(userid,created_date,product_id) 
 VALUES (1,'2017-04-19',2),
(3,'2019-12-18',1),
(2,'2020-07-20',3),
(1,'2019-10-23',2),
(1,'2018-03-19',3),
(3,'2016-12-20',2),
(1,'2016-11-09',1),
(1,'2016-05-20',3),
(2,'2017-09-24',1),
(1,'2017-03-11',2),
(1,'2016-03-11',1),
(3,'2016-11-10',1),
(3,'2017-12-07',2),
(3,'2016-12-15',2),
(2,'2017-11-08',2),
(2,'2018-09-10',3);


drop table if exists product;
CREATE TABLE product(product_id integer,product_name text,price integer); 

INSERT INTO product(product_id,product_name,price) 
 VALUES
(1,'p1',980),
(2,'p2',870),
(3,'p3',330);


select * from sales;
select * from product;
select * from goldusers_signup;
select * from users;


-- q.1 what is the total amount each customer spent on zomato ?
select a.userid, a.product_id , b.price from sales a inner join product b on a.product_id = b.product_id;
select a.userid, sum( b.price) total_amount_spent from sales a inner join product b on a.product_id = b.product_id
group by a.userid;

-- q 2 How many days has each customer visited zomato ?

select userid , count(distinct created_date) distinct_days from sales group by userid;

-- Q 3 what was the first product purchased by each customer ?
 
 select a.userid ,a.product_id from sales a   inner join users b 
 on a.useid = b.userid
 where a.created_date > b.signup_date 
   ;
   





-- select *,rank() over (partition by userid order by created_date) rnk from sales;

select*from
 (select *,rank() over (partition by userid order by created_date) rnk from sales) a where rnk =1;
 
 -- Q 4 what is the most purchase item on the menu  and how many times was purchased by all customers ?
 
 -- select  product_id , count(product_id)  from sales group by product_id order by count(product_id) desc;
select userid, count(product_id) cnt from sales where product_id= 
(select  product_id  from sales group by product_id order by count(product_id) desc LIMIT 1)group by userid;
 
 select* from
 (select *,rank() over(partition by userid order by cnt desc) rnk from 
 (select userid , product_id, count(product_id) cnt from sales group by userid , product_id)a)b where rnk = 1;

-- tumse na ho payega  select userid ,product_id , count(product_id) cnt from sales group by userid, product_id  order by  cnt desc limit 3;
-- Q 5 which item was most popular for each customer ?

select * from
(select c.*, rank() over(partition by userid order by created_date )rnk from
(select a.userid ,a.created_date,a.product_id,b.gold_signup_date from sales a inner join goldusers_signup b on a.userid=b.userid
and created_date >=gold_signup_date) c)d where rnk = 1; 






-- Q 6 which item was purchased first by the customer after they became a member ?

select * from
(select c.*, rank() over(partition by userid order by created_date )rnk from
(select a.userid ,a.created_date,a.product_id,b.gold_signup_date from sales a inner join 
goldusers_signup b on a.userid=b.userid and created_date >=gold_signup_date) c)d where rnk = 1; 

-- Q 7  which item was purchased just before the customer became a member ? 
select * from
(select c.*, rank() over(partition by userid order by created_date desc )rnk from
(select a.userid ,a.created_date,a.product_id,b.gold_signup_date from sales a inner join 
goldusers_signup b on a.userid=b.userid and created_date <=gold_signup_date) c)d where rnk = 1; 
 
 -- Q 8 what is the total orders and amount spent for each member before they became a member ?
 select userid , count(created_date) order_purchased, sum(price) total_amount from  (
 select c.*, d.price from 
 (select a.userid ,a.created_date,a.product_id,b.gold_signup_date from sales a inner join 
goldusers_signup b on a.userid=b.userid and created_date <=gold_signup_date) c
 inner join product d on c.product_id = d.product_id)e group by userid ;
 
 
 
 
 -- select d.*, case when product_id =1 then 5 when product_id = 2 then 2 when product_id = 3 then 5 else 0 end as point from (select c.userid, c.product_id , sum(price) amt from (select a.*, b.price from sales a inner join product b on a.product_id = b.product_id)c group by userid , product_id)d;

select userid , sum(total_points)*2.5 total_points from
(select e.*, amt/points total_points from
(select d.*, case when product_id =1 then 5 when product_id = 2 then 2 when product_id = 3 then 5 else 0 end as points from
(select c.userid, c.product_id ,sum(price) amt from
(select a.*, b.price from sales a inner join product b on a.product_id = b.product_id)c
group by userid , product_id)d)e)f group by userid;




--  Q 9 if buying each product generates points for eg 5rs = 2 zomato point and each product has different purchasing point 
-- for eg for p1 5rs = 1 zomato point , for p2 10rs = 5  zomato point and p3 5rs = 1 zomato point,
-- calculate points collected by each customer and for which product most points have been given till now. 


-- solution part 1
select userid , sum(total_points)*2.5 total_points from
(select e.*, amt/points total_points from
(select d.*, case when product_id =1 then 5 when product_id = 2 then 2 when product_id = 3 then 5 else 0 end as points from
(select c.userid, c.product_id ,sum(price) amt from
(select a.*, b.price from sales a inner join product b on a.product_id = b.product_id)c
group by userid , product_id)d)e)f group by userid;

-- solution part 2
select e.*, amt/points total_points from
(select d.*, case when product_id =1 then 5 when product_id = 2 then 2 when product_id = 3 then 5 else 0 end as points from
(select c.userid, c.product_id ,sum(price) amt from
(select a.*, b.price from sales a inner join product b on a.product_id = b.product_id)c
group by userid , product_id)d)e;

-- solution part 3;

select product_id , sum(total_points) total_points from
(select e.*, amt/points total_points from
(select d.*, case when product_id =1 then 5 when product_id = 2 then 2 when product_id = 3 then 5 else 0 end as points from
(select c.userid, c.product_id ,sum(price) amt from
(select a.*, b.price from sales a inner join product b on a.product_id = b.product_id)c
group by  userid , product_id)d)e)f group by product_id order by product_id;





-- Q 10 In the first one year after a customer joins the gold program (including  their join date) irrespective of what the customer has purchased
-- they earn 5 zomato points for every 10 rs spent who earned more 1 or 3
--  and what was their point earnings in thier first yr ?



-- Q 11 rank all the transaction of the customers ?
select *, rank() over (partition by userid order by created_date ) rnk from sales;
-- Q12 rank all the transaction for each member whenever they are a zomato gold member for every non gold member transction mark as na  

-- Q12 rank all the transaction for each member whenever they are a zomato gold member for every non gold member transction mark as na  
select e.* ,case when rnk = 0 then 'na' else rnk end as rnkk from 
(select c.*, cast((case when gold_signup_date is null then 0 else rank() 
over(partition by userid order by created_date desc) end  ) as char) as  rnk from
(select a.userid ,a.created_date,a.product_id,b.gold_signup_date from sales a left join
 goldusers_signup b on a.userid = b.userid and created_date >= gold_signup_date ) c) e;
 
 
 
 
 