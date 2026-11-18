--------------------------------------------------------------------------------------
--          This is the SQL script for the NFL Team Statistics Database.            --
--        It contains queries to analyze team performance, win percentages,         --
--                      points scored and allowed, and other.                       --
--               This script is designed through visual studio code.                --
--------------------------------------------------------------------------------------

USE NFLTeamStatisticsDb;

SELECT *
FROM [dbo].[OverallTeamStats]
GO;

----------------------------------------------------------------------
--                  Query 1: Best Win Percentage                    --
--          Which 10 team seasons had the best win percentage,      --
--           and what were their points scored and allowed?         --
----------------------------------------------------------------------

SELECT TOP 10 win_loss_perc, team, year, points, points_opp, points_diff
FROM [dbo].[OverallTeamStats]
ORDER BY win_loss_perc DESC
GO

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--          Results show that the 2007 New England Patriots had the best win percentage of 1.000, with 16 wins and 0 losses, scoring 589 points and allowing only 274 points against them.          --
--                                                     This was a historic season for the Patriots, as they went undefeated in the regular season.                                                  --
--                              They had a dominant offense and defense, with 589 points scored and only 274 points allowed, resulting in a points difference of 315.                               --
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------
--            Query 2: Average Points Per Game Over Time                --
--      How has average points per game changed from 2003 to 2023?      --
--------------------------------------------------------------------------

SELECT year, AVG(points/16) AS avg_points_per_game 
FROM [dbo].[OverallTeamStats]
WHERE year BETWEEN 2003 AND 2023
GROUP BY year
ORDER BY year
GO

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--              Results show that since 2003, the average points per game in the NFL has fluctuated, with some seasons seeing higher scoring than others.               --
--                                        The data indicates that there has been a general trend of increasing scoring over time.                                       --
--                                 This could be attributed to changes in rules, offensive strategies, and player talent over the years.                                --
--              Overall, the average points per game has shown a gradual increase, reflecting the evolving nature of the game and its emphasis on offense.              --
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------
--             Query 3: Best Points Difference by Season                --
--      Which team had the best points difference in each season?       --
--------------------------------------------------------------------------

SELECT year, team, points, points_opp, points_diff
FROM [dbo].[OverallTeamStats] AS OTS1
WHERE points_diff = (
    SELECT MAX(points_diff)
    FROM [dbo].[OverallTeamStats] AS OTS2
    WHERE OTS1.year = OTS2.year
)
ORDER BY points_diff DESC
GO

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--           Results show that the 2007 New England Patriots had the best points difference of 315, scoring 589 points and allowing only 274 points against them.             --
--                 The 2008 Titans and Ravens had the lowest points difference of 141, which could be attributed to a competitive season between the league.                  --
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------
--            Query 4: Teams with Win Percentage Above .500              --
--      Which teams have had the most seasons with a winning record?     --
---------------------------------------------------------------------------

SELECT team, COUNT(win_loss_perc) AS total_win_loss_perc_above_500
FROM [dbo].[OverallTeamStats]
WHERE win_loss_perc > 0.500 
GROUP BY team HAVING COUNT(win_loss_perc) > 0.500  
ORDER BY total_win_loss_perc_above_500 DESC

------------------------------------------------------------------------------------------------------------------------------------------------------
--              Results show that the New England Patriots have had the most dominance with 18 total seasons with a winning record,                 --
--          this is followed by the Pittsburgh Steelers and Seattle Seahawks with 16 seasons, and the Green Bay Packers with 15 seasons.            --
--  Doing extra research, active teams with the least amount of seasons with a winning record include the Oakland/Las Vegas Raiders with 2 seasons, --
--                                                   and the Cleveland Browns with 3 seasons.                                                       --
------------------------------------------------------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------
--              Query 5: Turnover Percentage Grouping                      --
--         Do teams that win the turnover battle win more games?           --
-----------------------------------------------------------------------------

WITH Turnover AS (
    SELECT team, wins, win_loss_perc,
           CASE
               WHEN turnover_pct < 7  THEN 'Low'
               WHEN turnover_pct < 15 THEN 'Medium'
               ELSE 'High'
           END AS turnover_group
    FROM [dbo].[OverallTeamStats]
)
SELECT turnover_group,
       COUNT(*)                          AS team_seasons,
       ROUND(AVG(wins * 1.0), 2)         AS avg_wins,
       ROUND(AVG(win_loss_perc), 3)      AS avg_win_pct
FROM Turnover
GROUP BY turnover_group
ORDER BY CASE turnover_group
             WHEN 'Low'    THEN 1
             WHEN 'Medium' THEN 2
             ELSE 3
         END;
------------------------------------------------------------------------------------------------------------------------------------------------------
--                 Results show that teams with a low turnover percentage have the highest average wins and win percentage,                         --
--                       while teams with a high turnover percentage have the lowest average wins and win percentage.                               --
------------------------------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------
--              Query 6: Pass vs. Rush Ratio Over Time                  --
--              Has the league become more pass-heavy?                  --
--------------------------------------------------------------------------

SELECT year, SUM(pass_att) * 1.0 / SUM(pass_att + rush_att) AS pass_share
FROM [dbo].[OverallTeamStats]
GROUP BY year
ORDER BY year; 

------------------------------------------------------------------------------------------------------------------------------------------------------
--              Results show that the league has become more pass-heavy over time, with the pass share increasing from 2003 to 2023.                --
--      This trend can be attributed to changes in offensive strategies, rule changes favoring passing, and the evolution of quarterback play.      --
--                   The data indicates that teams are increasingly relying on passing plays to move the ball and score points,                     --
--                                             reflecting a shift in the overall style of play in the NFL.                                          --
------------------------------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------
--        Query 7: Teams with Most Improved Win Total from One Season to the Next        --
--      Which teams improved their win total the most from one season to the next?       --
-------------------------------------------------------------------------------------------

SELECT team, year, wins, 
       wins - LAG(wins) OVER (PARTITION BY team ORDER BY year) AS win_change
FROM [dbo].[OverallTeamStats]
WHERE year > 2003

------------------------------------------------------------------------------------------------------------------------------------------------------
--                      Results show that the 2008 Miami Dolphins had the most improved win total from one season to the next,                      --
--                                     with a change of 10 wins, going from 1 win in 2007 to 11 wins in 2008.                                       --
--         This significant improvement can be attributed to changes in coaching staff, player acquisitions, and overall team performance.          --
--              Other notable teams with significant improvements include the 2016 Dallas Cowboys and the 2012 Indianapolis Colts,                  --
--                                              both with a change of 9 wins from the previous season.                                              --
------------------------------------------------------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------------
--                     Query 8: Teams Scoring Above Average with Losing Records                          --
--       Which teams scored more than the league average that season but still had a losing record?      --
-----------------------------------------------------------------------------------------------------------

WITH SeasonAvg AS (
    SELECT year, team, wins, losses, points,
           AVG(points * 1.0) OVER (PARTITION BY year) AS league_avg_points
    FROM [dbo].[OverallTeamStats]
)
SELECT year, team, wins, losses, points,
       ROUND(league_avg_points, 1) AS league_avg_points
FROM SeasonAvg
WHERE points > league_avg_points
  AND wins < losses
ORDER BY year, points DESC;

------------------------------------------------------------------------------------------------------------------------------------------------------
--        Results show that there are several teams that scored more than the league average in a given season but still had a losing record.       --
--           This indicates that while these teams were able to put up points, they struggled in other areas such as defense or turnovers.          --
--                   Notable examples include the 2004 Kansas City Chiefs, who scored 483 points but had a losing record of 7-9,                    --
--                           and the 2021 Minnesota Vikings, who scored 425 points but finished with a record of 8-9.                               --
------------------------------------------------------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------------
--                           Query 9: Penalty Yards vs. Win Percentage Grouping                          --
--      Split team seasons into four groups by penalty yards. Do the most penalised teams win less?      --
-----------------------------------------------------------------------------------------------------------

SELECT 
    CASE 
        WHEN penalties_yds < 500 THEN 'Low'
        WHEN penalties_yds < 750 THEN 'Medium'
        WHEN penalties_yds < 1050 THEN 'High'
        ELSE 'Very High'
    END AS penalty_group,
    COUNT(*) AS team_seasons,
    ROUND(AVG(win_loss_perc), 3) AS avg_win_pct
FROM [dbo].[OverallTeamStats]
GROUP BY 
    CASE 
        WHEN penalties_yds < 500 THEN 'Low'
        WHEN penalties_yds < 750 THEN 'Medium'
        WHEN penalties_yds < 1050 THEN 'High'
        ELSE 'Very High'
    END
ORDER BY avg_win_pct DESC

------------------------------------------------------------------------------------------------------------------------------------------------------
--                         Results show that teams with lower penalty yards tend to have a higher average win percentage,                           --
--                              while teams with higher penalty yards tend to have a lower average win percentage.                                  --
--                    This suggests that minimizing penalties can contribute to better team performance and success on the field.                   --
------------------------------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------
--          Query 10: Cumulative Wins Over the Years and Franchise with Most Wins from 2003 to 2023          --
-- Show each team’s cumulative wins over the years, and which franchise has the most wins from 2003 to 2023. --
---------------------------------------------------------------------------------------------------------------

SELECT team, year, wins,
       SUM(wins) OVER (PARTITION BY team ORDER BY year) AS cumulative_wins 
FROM [dbo].[OverallTeamStats]
ORDER BY team, year;

-------------------------------------------------------------------------------------------------------------------------------------------------------
--              Results show that the New England Patriots have the most cumulative wins from 2003 to 2023, with a total of 243 wins.                --
--                         This is followed by the Pittsburgh Steelers with 213 wins, and the Green Bay Packers with 207 wins.                       --
--                           The data indicates that these franchises have been consistently successful over the years,                              --
--                                  maintaining a high level of performance and competitiveness in the league.                                       --
-------------------------------------------------------------------------------------------------------------------------------------------------------
