-- **Initial Questions**

-- 1. What range of years for baseball games played does the provided database cover? 

select min(yearid), max(yearid)
from teams;
--Answer: 1871 through 2016

-- 2. Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?
   
select namefirst as first_name, 
		namelast as last_name, 
		height as height_in_inches, 
		g_all as number_of_games_played, 
		t.name as team_name
from people
inner join appearances as a
using (playerid)
inner join teams as t
using (teamid)
order by height
limit 1;
--Answer: Eddie Gaedel, 43 inches tall, played in one game for the St. Louis Browns


-- 3. Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?

select  namefirst as first_name, namelast as last_name, sum(salary)::numeric::money  as total_salary
from people
inner join salaries
using (playerid)
where playerid in 
		(select playerid
		from collegeplaying
		where schoolid ilike 'vandy')
		--using a subq here prevents us from joining which is causing the extra years
group by namefirst, namelast
order by total_salary desc;
--Answer: David Price, $81,851,296.00
--fixed multiple year issue causeing salary to be tripled


-- 4. Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.

select 
	case when pos='OF' then 'Outfield'
	when pos in ('SS','1B','2B','3B') then 'Infield'
	when pos in ('P','C') then 'Battery'
	end as position,
	yearid,
	sum(po) as number_of_putouts
from fielding
where yearid=2016
group by yearid, position
order by number_of_putouts desc;
--Answer: Infield- 58,934, Battery- 41,424, Outfield- 29,560	

-- 5. Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?

select Round(sum(so)/sum(g),2) as avg_strikeouts,
		round(sum(hr)/sum(g),2) as avg_home_runs,
		case when yearid between 1920 and 1929 then '1920s'
		when yearid between 1930 and 1939 then '1930s'
		when yearid between 1940 and 1949 then '1940s'
		when yearid between 1950 and 1959 then '1950s'
		when yearid between 1960 and 1969 then '1960s'
		when yearid between 1970 and 1979 then '1970s'
		when yearid between 1980 and 1989 then '1980s'
		when yearid between 1990 and 1999 then '1990s'
		when yearid between 2000 and 2009 then '2000s'
		when yearid>=2010 then '2010s'
		end as decade
from teams
where yearid>=1920
group by decade
order by decade desc;
--Answer: Average amount of strikeouts increases as time goes on, also it seems like home runs are very rare since only one decade (2000s) had a home run average over 0.00

--can also do yearid/10*10 for decade
select Round(sum(so)/sum(g),2) as avg_strikeouts,
		round(sum(hr)/sum(g),2) as avg_home_runs,
		yearid/10*10 as decade
from teams
where yearid>=1920
group by decade
order by decade desc;
-- 6. Find the player who had the most success stealing bases in 2016, where __success__ is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted _at least_ 20 stolen bases.

select namefirst as first_name, namelast as last_name, sb::numeric as stolen_bases, sum(sb::numeric+cs::numeric) as total_attempts, (sb::numeric*100)/sum(sb::numeric+cs::numeric)  as successful_attempts_percentage,yearid as year
from batting
inner join people
using (playerid)
where yearid=2016
group by first_name, last_name, sb,yearid
having sum(sb+cs)>=20
order by successful_attempts_percentage desc;
--Answer: Chris Owings successfully stole 21 bases or 91% of his attempts
(sb*100)/sum(sb+cs)
-- 7.  From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. Then redo your query, excluding the problem year. How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?

select name as team_name,sum(w) as total_wins, yearid as year,wswin as world_series_win
from teams
where yearid between 1970 and 2016
and wswin='N'
group by name, yearid,wswin
order by total_wins desc;
--Answer: Seattle Mariners won 116 games in 2001 but did not win the World Series


select name as team_name,sum(w) as total_wins, yearid as year,wswin as world_series_win
from teams
where yearid between 1970 and 2016
and wswin='Y'
group by name, yearid, wswin
order by total_wins;
--Answer: The LA Dodgers had the least amount of wins but still won the world series in 1981. This can be contributed to the player's strike that year which resulted in less games being played


select name as team_name,w as total_wins, yearid as year,wswin as world_series_win
from teams
where yearid between 1970 and 2016
and yearid not in (1981)
and wswin='Y'
group by name, yearid, wswin,w
order by yearid;
--Answer: Excluding 1981, the St. Louis Cardinals had the lowest amount of wins (86) while also winning the World Series in 2006


--How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?

with mw as (
select yearid, max(w) as max_wins
from teams
where yearid>=1970 and yearid <>1981
group by yearid),
wc as (
select teamid,yearid,w,wswin
from teams
where yearid between 1970 and 2016 and yearid<>1981)
select 
sum(case when wswin='Y' then 1 else 0 end) as max_wins_and_won_ws,
count(distinct wc.yearid) as total_ws,
Round(sum(case when wswin='Y' then 1 else 0 end)/
count(distinct wc.yearid)::numeric,2)*100 as percent_max_wins_and_ws_win
from mw
left join wc
on mw.yearid=wc.yearid and mw.max_wins=wc.w
where mw.max_wins is not null;
--Answer: out of 46 world series, 12 teams with the most wins that season also won the world series or 26% of teams

-- 8. Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.

select  park_name,t.name as team_name, sum(h.attendance)/sum(h.games) as avg_attendance
from homegames as h
inner join teams as t
on h.team=t.teamid and h.year=t.yearid
inner join parks as p
on h.park=p.park
where year=2016
and games>=10
group by park_name,t.name
order by avg_attendance desc
limit 5;


select  park_name,t.name as team_name, sum(h.attendance)/sum(h.games) as avg_attendance
from homegames as h
inner join teams as t
on h.team=t.teamid and h.year=t.yearid
inner join parks as p
on h.park=p.park
where year=2016
and games>=10
group by park_name,t.name
order by avg_attendance
limit 5;

-- 9. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.

select p.namefirst ||' '|| p.namelast as name,
		a.lgid, 
		t.name as team_name,
		a.yearid
from awardsmanagers as a
left join people as p
using (playerid)
left join managers as m
using (yearid,lgid) 
left join teams as t
using (teamid, yearid)
where a.playerid in (
		select playerid
		from awardsmanagers
		where awardid= 'TSN Manager of the Year'
		group by playerid
		having count(distinct lgid) >1)
and a.lgid<> 'ML'
and a.playerid = m.playerid
group by p.namefirst,p.namelast,a.lgid,a.yearid,t.name
order by p.namefirst;



-- 10. Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.

 with mhr as 
(select playerid, max(hr) as max_hr
from batting
where yearid=2016
 and playerid in 
 		(select playerid
		from batting
		group by playerid
		having count(distinct yearid)>=10)
group by playerid)
select p.namefirst ||' '|| p.namelast as name,max_hr as max_career_homerun
from batting as b
inner join mhr
using (playerid)
inner join people as p
using (playerid)
where max_hr>=1 
group by p.namefirst, p.namelast,max_hr
having max_hr=max(hr)
order by max_career_homerun desc;

-- **Open-ended questions**

-- 11. Is there any correlation between number of wins and team salary? Use data from 2000 and later to answer this question. As you do this analysis, keep in mind that salaries across the whole league tend to increase together, so you may want to look on a year-by-year basis.


with ssal as (
select sum(salary) as total_salary,teamid,yearid
from salaries
where yearid>=2000
group by teamid, yearid
order by yearid, total_salary),
swins as (
select sum(w) as total_wins,teamid,yearid
from teams
where yearid>=2000
group by teamid,yearid
order by yearid, total_wins)

select swins.teamid, swins.yearid, total_salary, total_wins
from ssal
inner join swins
using (teamid,yearid)
where swins.yearid=2001
and total_salary in (
select max(total_salary)
	from ssal)
order by total_salary desc, total_wins desc


-- 12. In this question, you will explore the connection between number of wins and attendance.
--       Does there appear to be any correlation between attendance at home games and number of wins?
--       Do teams that win the world series see a boost in attendance the following year? What about teams that made the playoffs? Making the playoffs means either being a division winner or a wild card winner.


-- 13. It is thought that since left-handed pitchers are more rare, causing batters to face them less often, that they are more effective. Investigate this claim and present evidence to either support or dispute this claim. First, determine just how rare left-handed pitchers are compared with right-handed pitchers. Are left-handed pitchers more likely to win the Cy Young Award? Are they more likely to make it into the hall of fame?

--   select count(distinct playerid)
--   from people
--   where throws='L'

--  select count(distinct playerid)
--   from people
--   where throws='R'
  
-- select count
-- select throws
-- from people