select * from Project..data1
select * from Project..data2

-- number of rows into our dataset

Select COUNT(*) from Project..data1
select COUNT(*) from Project..data2

--dataset for jahrkhand and bihar
Select * from Project..data1 where state in ('Jharkhand','Bihar')

--total population
select SUM(Population) as total_pop from Project..data2

--average growth of population for India
Select AVG(Growth)*100 as avg_growth from Project..data1

Select * from Project..data1


--avg population growth state wise
select state,AVG(Growth)*100 as Avg_growth_of_states from Project..data1 group by State

select top 3 state,round(AVG(Sex_Ratio),0) as Avg_SEx_ratio_of_states from Project..data1 group by State order by Avg_SEx_ratio_of_states desc

select top 3 state,round(AVG(Sex_Ratio),0) as Avg_SEx_ratio_of_states from Project..data1 group by State order by  Avg_SEx_ratio_of_states asc

--top 3 and bottom 3 states in Avg_sex_ratio
drop table if exists topstates
create table topstates
( state nvarchar(255),
  topstate float
  )
insert into topstates
select top 3 state,round(AVG(Sex_Ratio),0) as Avg_SEx_ratio_of_states from Project..data1 group by State order by Avg_SEx_ratio_of_states desc
select * from topstates



drop table if exists bottomstates
create table bottomstates
( state nvarchar(255),
  bottomstate float
  )
insert into bottomstates
select top 3 state,round(AVG(Sex_Ratio),0) as Avg_SEx_ratio_of_states from Project..data1 group by State order by Avg_SEx_ratio_of_states asc
select * from bottomstates




--we want the top 3 states and bottom 3 states in one single table
select * from
(select top 3 * from topstates order by topstates.topstate desc) 
as a

union
select * from
(select top 3 * from bottomstates order by bottomstates.bottomstate asc) 
as b


--states starting with letter a 
select distinct State from Project..data1 where state like 'A%' or state like 'B%'

--joining both the table
select a.District,a.State,a.Sex_Ratio,b.Population from Project..data1 a inner join Project..data2 b on a.District=b.District  

--i want the number of males and females from the population

-- Population = male + female .....1

-- sex_ratio = female/male ......2
--female = sex_ratio*male  ......3

--Population = male + sex_ratio*male
--Population = male(1 + sex_ratio)
--male = Population/(1 + sex_ratio)....4


--male(1 + sex_ratio) = male + female
--female = (Population*sex_ratio)/(1 + Sex_ratio)......5

select d.state,sum(d.males) total_males,sum(d.females) total_female from
(select c.District,c.State,round(c.Population/(1 + c.sex_ratio),0) males,round((c.Population*c.sex_ratio)/(1 + c.sex_ratio),0) females from
(select a.District,a.State,a.Sex_Ratio/1000 sex_ratio,b.Population from Project..data1 a inner join Project..data2 b on a.District=b.District) c ) d group by d.State



-- total Litercacy rate 
-- total literate people / population = literacy_ratio
-- total literate people = literacy_ratio* population

--total number of illiterate = (1-literacy_ratio)*population
select d.state,sum(d.literate_people) total_literate,sum(d.illiterate_people) total_illiterate from
(select c.District,c.state,round(c.literacy_ratio*c.Population,0) literate_people,round(((1-c.literacy_ratio)*c.Population),0) illiterate_people from
(select a.District,a.State,a.Literacy/100 literacy_ratio,b.Population from Project..data1 a inner join Project..data2 b on a.District=b.District) c) d
group by state

--we want to get previous population census
--population = previous_pop + previous_pop*growth
--previous_pop = population/(1 + growth)

select c.State,sum(c.previous_year_population) previous_year_population,sum(c.current_population) current_population from
(select a.District,a.State,round(b.Population/(1 + growth),0) previous_year_population,b.Population current_population from Project..data1 a inner join Project..data2 b on a.District=b.District) c
group by c.State

--population vs area 
--how many people_count got change from the previous census
--creating a common colum to perform join operation
--how many people / sq kilometer (change from previous census)

select ROUND(total_previous_pop/n.total_area,0) previous_people_per_sq_km , round(n.total_current_pop/n.total_area,0) current_people_per_sq_km from
(select q.*,r.total_area from 
(select '1' as keyy,e.* from
(select sum(d.previous_year_population) total_previous_pop,sum(d.current_population) total_current_pop from
(select c.State,sum(c.previous_year_population) previous_year_population,sum(c.current_population) current_population from
(select a.District,a.State,round(b.Population/(1 + growth),0) previous_year_population,b.Population current_population from Project..data1 a inner join Project..data2 b on a.District=b.District) c
group by c.State) d) e) q inner join 

(select '1' as keyy,f.* from 
(select sum(area_km2) total_area from Project..data2) f) r on q.keyy = r.keyy) n


--Window function
--top 3 district from each state which have highest literacy_rate
select a.* from
(select District,state,literacy,rank() over (partition by state order by literacy desc) rnk from Project..data1) a
where a.rnk in (1,2,3)




