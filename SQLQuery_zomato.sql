


drop table if exists goldusers_signup;
CREATE TABLE goldusers_signup(userid integer,gold_signup_date date); 

INSERT INTO goldusers_signup(userid,gold_signup_date) 
 VALUES (1,'09-22-2017'),
(3,'04-21-2017');

drop table if exists users;
CREATE TABLE users(userid integer,signup_date date); 

INSERT INTO users(userid,signup_date) 
 VALUES (1,'09-02-2014'),
(2,'01-15-2015'),
(3,'04-11-2014');

drop table if exists sales;
CREATE TABLE sales(userid integer,created_date date,product_id integer); 

INSERT INTO sales(userid,created_date,product_id) 
 VALUES (1,'04-19-2017',2),
(3,'12-18-2019',1),
(2,'07-20-2020',3),
(1,'10-23-2019',2),
(1,'03-19-2018',3),
(3,'12-20-2016',2),
(1,'11-09-2016',1),
(1,'05-20-2016',3),
(2,'09-24-2017',1),
(1,'03-11-2017',2),
(1,'03-11-2016',1),
(3,'11-10-2016',1),
(3,'12-07-2017',2),
(3,'12-15-2016',2),
(2,'11-08-2017',2),
(2,'09-10-2018',3);


drop table if exists product;
CREATE TABLE product(product_id integer,product_name text,price integer); 

INSERT INTO product(product_id,product_name,price) 
 VALUES
(1,'p1',980),
(2,'p2',870),
(3,'p3',330);


select * from users
select * from goldusers_signup
select * from sales
select * from product


/* 1.what is total amount each customer spent on zomato ?
2.How many days has each customer visited zomato?
3.what was the first product purchased by each customer?
4.what is most purchased item on menu & how many times was it purchased by all customers ?
5.which item was most popular for each customer?
6.which item was purchased first by customer after they become a member ?
7. which item was purchased just before the customer became a member?
8. what is total orders and amount spent for each member before they become a member?
9. If buying each product generates points for eg 5rs=2 zomato point 
  and each product has different purchasing points for eg for p1 5rs=1 zomato point,for p2 10rs=zomato point and p3 5rs=1 zomato point  2rs =1zomato point, calculate points collected by each customer and for which product most points have been given till now.
10. In the first year after a customer joins the gold program (including the join date ) irrespective of what customer has purchased earn 5 zomato points for every 10rs spent who earned more more 1 or 3 what int earning in first yr ? 1zp = 2rs
11. rnk all transaction of the customers
12. rank all transaction for each member whenever they are zomato gold member for every non gold member transaction mark as na
*/

--1.what is total amount each customer spent on zomato ?

select s.userid,sum(price) as total_amount
from sales s
inner join product p
on s.product_id = p.product_id
group by s.userid


--2.How many days has each customer visited zomato?

select * from users
select * from goldusers_signup
select * from sales
select * from product


select userid,count(distinct created_date) as visited
from sales 
group by userid


--3.what was the first product purchased by each customer?

select * from(
select * ,
DENSE_RANK() over(partition by userid order by created_date) rn 
from sales) T
where rn=1

--4.what is most purchased item on menu & how many times was it purchased by all customers ?

select * from users
select * from goldusers_signup
select * from sales
select * from product


select userid ,count(product_id) as cnt_product
from sales
where product_id = (select top 1 product_id from sales group by product_id
order by count(product_id) desc)
group by userid

--5.which item was most popular for each customer?

select * from(
select *, rank() over(partition by userid order by cnt desc) rnk from
(select userid,product_id, count(product_id) as cnt 
from sales
group by userid,product_id) a)b
where rnk = 1


--6.which item was purchased first by customer after they become a member ?

select * from 
(select c.*,rank() over(partition by userid order by created_date ) rnk from
(select s.userid,created_date,product_id,gold_signup_date
from sales s
inner join goldusers_signup g
on s.userid = g.userid
and created_date >= gold_signup_date) c)d
where rnk =1

--7. which item was purchased just before the customer became a member?

select * from users
select * from goldusers_signup
select * from sales
select * from product

select * from 
(select c.*,rank() over(partition by userid order by created_date desc) rnk from
(select s.userid,created_date,product_id,gold_signup_date
from sales s
inner join goldusers_signup g
on s.userid = g.userid
and created_date <= gold_signup_date) c)d
where rnk =1

--8. what is total orders and amount spent for each member before they become a member?

select userid,count(created_date) order_purchased,sum(price) total_amount
from(
select c.*,p.price from
(select s.userid,created_date,product_id,gold_signup_date
from sales s
inner join goldusers_signup g
on s.userid = g.userid
and created_date <= gold_signup_date)c
inner join product p on c.product_id = p.product_id)e
group by userid

--9. If buying each product generates points for eg 5rs=2 zomato point 
--and each product has different purchasing points for eg for p1 5rs=1 
--zomato point,for p2 10rs= 5 zomato point and p3 5rs=1 zomato point  
--2rs =1zomato point, calculate points collected by each customer and for 
--which product most points have been given till now.

select * from users
select * from goldusers_signup
select * from sales
select * from product

select userid,sum(total_points)*2.5 as total_money_earned from 
(select e.*,amt/points as total_points from
(select d.*,case when product_id = 1 then 5 when product_id = 2 then 2
when product_id = 3 then 5 else 0 end as points from
(select c.userid,c.product_id, sum(price) as amt
from 
(select s.*,p.price
from sales s
inner join product p
on s.product_id = p.product_id) c
group by userid,product_id)d)e)f
group by userid

select * from
(select *, rank() over(order by total_points_earned desc) rnk from
(select product_id,sum(total_points) as total_points_earned from 
(select e.*,amt/points as total_points from
(select d.*,case when product_id = 1 then 5 when product_id = 2 then 2
when product_id = 3 then 5 else 0 end as points from
(select c.userid,c.product_id, sum(price) as amt
from 
(select s.*,p.price
from sales s
inner join product p
on s.product_id = p.product_id) c
group by userid,product_id)d)e)f
group by product_id) g)h
where rnk = 1



--10. In the first year after a customer joins the gold program (including the join date ) 
--irrespective of what customer has purchased earn 5 zomato points for every 10rs spent who earned more more 1 or 3 what int earning in first yr ? 1zp = 2rs

select * from users
select * from goldusers_signup
select * from sales
select * from product

select c.*, p.price*0.5 as total_points_earned from 
(select s.userid,created_date,product_id,gold_signup_date
from sales s
inner join goldusers_signup g
on s.userid = g.userid
and created_date >= gold_signup_date 
and created_date < dateadd(year,1,gold_signup_date))c
inner join product p on c.product_id = p.product_id

--11. rnk all transaction of the customers

SELECT * , RANK() OVER(PARTITION BY USERID ORDER BY CREATED_DATE ) AS Rnk FROM sales

--12. rank all transaction for each member whenever they are zomato gold member for every non gold member transaction mark as na

select e.*,case when rnk=0 then 'na' else rnk end as rnkk from
    (select c.*,cast((case when gold_signup_date is null then 0 else rank() over 
    (partition by userid order by created_date desc)end)as varchar) as rnk from 
    (select a.userid, a.created_date, a.product_id, b.gold_signup_date 
    from sales a left join goldusers_signup b on a.userid=b.userid and created_date>=gold_signup_date)c)e;