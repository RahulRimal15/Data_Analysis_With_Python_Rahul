# Premier League ETL project

For this project I used the Premier League dataset from Kaggle (https://www.kaggle.com/datasets/zaeemnalla/premier-league). It has two files: `results.csv` with every match from 2006/07 to 2017/18, and `stats.csv` with the season stats of each team.

I read both files with Pandas, looked through them (EDA), cleaned them, worked out things like points and league position, and answered a few questions about the league. After that I put everything into a SQLite database and wrote 10 SQL queries on it.

Everything is in one notebook, `notebook/premier_league_etl.ipynb`, from the first read_csv to the last query.

## Where things are

- `data/raw` - the two original csv files
- `notebook` - the notebook
- `database/premier_league.sql` - the create table code and the 10 queries
- `database/premier_league.db` - the database made by the notebook
- `database/query_results` - the result of each query saved as csv
- `database/ERD.png` - the ERD

## Database

There are 4 tables. `teams` and `seasons` hold the team names and the seasons. `matches` and `team_stats` use their ids as foreign keys. The ERD shows how they connect.

## How to run

Install the libraries with `pip install -r requirements.txt`, open the notebook and run all the cells. It creates the database and the query results again.
