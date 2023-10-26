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

select  namefirst as first_name, namelast as last_name, sum(salary) as total_salary
from people
inner join collegeplaying
using (playerid)
inner join schools
using (schoolid)
inner join salaries
using (playerid)
where schoolname='Vanderbilt University'
group by first_name, last_name
order by total_salary desc;
--Answer: David Price, $245,553,888


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

-- 6. Find the player who had the most success stealing bases in 2016, where __success__ is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted _at least_ 20 stolen bases.

select namefirst as first_name, namelast as last_name, sb as stolen_bases, sum(sb+cs) as total_attempts, (sb*100)/sum(sb+cs)  as successful_attempts_percentage,yearid as year
from batting
inner join people
using (playerid)
where yearid=2016
group by first_name, last_name, sb,yearid
having sum(sb+cs)>=20
order by successful_attempts_percentage desc;
--Answer: Chris Owings successfully stole 21 bases or 91% of his attempts

-- 7.  From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. Then redo your query, excluding the problem year. How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?

select name as team_name,sum(w) as total_wins, yearid as year,wswin as world_series_win
from teams
where yearid between 1970 and 2016
group by name, yearid,wswin
order by total_wins desc
--Answer:

select wswin, t.name,yearid,sum(w)
from teams as t
group by t.name, yearid, wswin
order by name 

-- 8. Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.

--Answer:

-- 9. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.

--Answer:

-- 10. Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.

--Answer:

-- **Open-ended questions**

-- 11. Is there any correlation between number of wins and team salary? Use data from 2000 and later to answer this question. As you do this analysis, keep in mind that salaries across the whole league tend to increase together, so you may want to look on a year-by-year basis.

-- 12. In this question, you will explore the connection between number of wins and attendance.
--     <ol type="a">
--       <li>Does there appear to be any correlation between attendance at home games and number of wins? </li>
--       <li>Do teams that win the world series see a boost in attendance the following year? What about teams that made the playoffs? Making the playoffs means either being a division winner or a wild card winner.</li>
--     </ol>


-- 13. It is thought that since left-handed pitchers are more rare, causing batters to face them less often, that they are more effective. Investigate this claim and present evidence to either support or dispute this claim. First, determine just how rare left-handed pitchers are compared with right-handed pitchers. Are left-handed pitchers more likely to win the Cy Young Award? Are they more likely to make it into the hall of fame?

  
