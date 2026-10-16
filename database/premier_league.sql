-- Premier League ETL project (SQLite)
-- This file has the table creation code and the 10 SQL report queries

PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS team_stats;
DROP TABLE IF EXISTS matches;
DROP TABLE IF EXISTS teams;
DROP TABLE IF EXISTS seasons;

CREATE TABLE teams (
    team_id    INTEGER PRIMARY KEY,
    team_name  TEXT NOT NULL UNIQUE
);

CREATE TABLE seasons (
    season_id   INTEGER PRIMARY KEY,
    season      TEXT NOT NULL UNIQUE,
    start_year  INTEGER NOT NULL,
    end_year    INTEGER NOT NULL
);

CREATE TABLE matches (
    match_id      INTEGER PRIMARY KEY,
    season_id     INTEGER NOT NULL,
    home_team_id  INTEGER NOT NULL,
    away_team_id  INTEGER NOT NULL,
    home_goals    INTEGER NOT NULL CHECK (home_goals >= 0),
    away_goals    INTEGER NOT NULL CHECK (away_goals >= 0),
    result        TEXT NOT NULL CHECK (result IN ('H', 'D', 'A')),
    total_goals   INTEGER NOT NULL,
    FOREIGN KEY (season_id) REFERENCES seasons (season_id),
    FOREIGN KEY (home_team_id) REFERENCES teams (team_id),
    FOREIGN KEY (away_team_id) REFERENCES teams (team_id),
    CHECK (home_team_id <> away_team_id)
);

CREATE TABLE team_stats (
    team_stat_id     INTEGER PRIMARY KEY,
    team_id          INTEGER NOT NULL,
    season_id        INTEGER NOT NULL,
    wins             INTEGER NOT NULL,
    draws            INTEGER NOT NULL,
    losses           INTEGER NOT NULL,
    goals_for        INTEGER NOT NULL,
    goals_against    INTEGER NOT NULL,
    goal_difference  INTEGER NOT NULL,
    points           INTEGER NOT NULL,
    position         INTEGER NOT NULL CHECK (position BETWEEN 1 AND 20),
    shots            INTEGER,
    shots_on_target  INTEGER,
    clean_sheets     INTEGER,
    yellow_cards     INTEGER,
    red_cards        INTEGER,
    tackles          INTEGER,
    passes           INTEGER,
    saves            INTEGER,
    FOREIGN KEY (team_id) REFERENCES teams (team_id),
    FOREIGN KEY (season_id) REFERENCES seasons (season_id),
    UNIQUE (team_id, season_id),
    CHECK (wins + draws + losses = 38)
);

-- ==============================
-- SQL reporting queries
-- ==============================

-- Query 1: How many matches ended in a home win, draw and away win?
SELECT
    CASE result
        WHEN 'H' THEN 'Home win'
        WHEN 'A' THEN 'Away win'
        ELSE 'Draw'
    END AS result,
    COUNT(*) AS matches,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM matches), 1) AS percentage
FROM matches
GROUP BY result
ORDER BY matches DESC;

-- Query 2: Average goals per match in each season
SELECT s.season, COUNT(*) AS matches, ROUND(AVG(m.total_goals), 2) AS avg_goals
FROM matches m
JOIN seasons s ON m.season_id = s.season_id
GROUP BY s.season
ORDER BY s.season;

-- Query 3: Which team won the league each season?
SELECT s.season, t.team_name AS champion, ts.points, ts.goal_difference
FROM team_stats ts
JOIN teams t ON ts.team_id = t.team_id
JOIN seasons s ON ts.season_id = s.season_id
WHERE ts.position = 1
ORDER BY s.season;

-- Query 4: Top 10 teams by total points over the 12 seasons
SELECT t.team_name, COUNT(*) AS seasons_played, SUM(ts.points) AS total_points,
       ROUND(AVG(ts.points), 1) AS avg_points
FROM team_stats ts
JOIN teams t ON ts.team_id = t.team_id
GROUP BY t.team_name
ORDER BY total_points DESC
LIMIT 10;

-- Query 5: Home win percentage of teams that played at least 100 home matches
SELECT t.team_name, COUNT(*) AS home_matches,
       SUM(CASE WHEN m.result = 'H' THEN 1 ELSE 0 END) AS home_wins,
       ROUND(SUM(CASE WHEN m.result = 'H' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS home_win_pct
FROM matches m
JOIN teams t ON m.home_team_id = t.team_id
GROUP BY t.team_name
HAVING COUNT(*) >= 100
ORDER BY home_win_pct DESC
LIMIT 10;

-- Query 6: The 10 highest scoring matches
SELECT s.season, h.team_name AS home_team, a.team_name AS away_team,
       m.home_goals, m.away_goals, m.total_goals
FROM matches m
JOIN teams h ON m.home_team_id = h.team_id
JOIN teams a ON m.away_team_id = a.team_id
JOIN seasons s ON m.season_id = s.season_id
ORDER BY m.total_goals DESC, s.season
LIMIT 10;

-- Query 7: Teams that scored more than the average in 2017-2018
SELECT t.team_name, ts.goals_for, ts.position
FROM team_stats ts
JOIN teams t ON ts.team_id = t.team_id
JOIN seasons s ON ts.season_id = s.season_id
WHERE s.season = '2017-2018'
  AND ts.goals_for > (
      SELECT AVG(ts2.goals_for)
      FROM team_stats ts2
      JOIN seasons s2 ON ts2.season_id = s2.season_id
      WHERE s2.season = '2017-2018'
  )
ORDER BY ts.goals_for DESC;

-- Query 8: Best defences, fewest goals conceded in a season
SELECT t.team_name, s.season, ts.goals_against, ts.clean_sheets, ts.position
FROM team_stats ts
JOIN teams t ON ts.team_id = t.team_id
JOIN seasons s ON ts.season_id = s.season_id
ORDER BY ts.goals_against ASC
LIMIT 10;

-- Query 9: Do top 4 teams have more shots and passes than the rest?
SELECT CASE WHEN position <= 4 THEN 'Top 4' ELSE 'Rest' END AS group_name,
       COUNT(*) AS team_seasons,
       ROUND(AVG(shots_on_target), 0) AS avg_shots_on_target,
       ROUND(AVG(passes), 0) AS avg_passes,
       ROUND(AVG(goals_for), 1) AS avg_goals
FROM team_stats
GROUP BY group_name;

-- Query 10: Teams with at least 10 seasons in the league and their average position
SELECT t.team_name, COUNT(*) AS seasons_played, ROUND(AVG(ts.position), 1) AS avg_position,
       MIN(ts.position) AS best_position
FROM team_stats ts
JOIN teams t ON ts.team_id = t.team_id
GROUP BY t.team_name
HAVING COUNT(*) >= 10
ORDER BY avg_position;
