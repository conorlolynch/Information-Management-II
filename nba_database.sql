
# An sql database that represents the structure of data within a season of the NBA 

DROP DATABASE IF EXISTS nba;
DROP USER IF EXISTS staff;
DROP USER IF EXISTS viewer;
FLUSH PRIVILEGES;
CREATE DATABASE nba;
USE nba;

# Define tables and constraints
CREATE TABLE IF NOT EXISTS team (
	team_id int(4) NOT NULL,
    team_name varchar(50) NOT NULL,
    location varchar(20) NOT NULL,
    PRIMARY KEY (team_id)
);

CREATE TABLE IF NOT EXISTS player (
	player_id int(4) NOT NULL,
    firstname varchar(30),
    lastname varchar(30),
    height FLOAT NOT NULL,
    weight FLOAT NOT NULL,
    position varchar(20) NOT  NULL,
    DOB DATE NOT NULL,
    team_id int(4) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    PRIMARY KEY (player_id),
    FOREIGN KEY (team_id) REFERENCES team(team_id)
);

CREATE TABLE IF NOT EXISTS venue (
	venue_id varchar(4) NOT NULL,
    venue_name varchar(40),
    city varchar(30) NOT NULL,
    state varchar(30) NOT NULL,
    capacity INTEGER NOT NULL CHECK (capacity >= 0),
    year_built YEAR NOT NULL,
    PRIMARY KEY (venue_id)
);

CREATE TABLE IF NOT EXISTS game (
	game_id varchar(4) NOT NULL,
    venue_id varchar(4) NOT NULL,
    game_date DATE NOT NULL,
    hometeam_id int(4) NOT NULL,
    awayteam_id int(4) NOT NULL,
    hometeam_score int(3) NOT NULL CHECK (hometeam_score >= 0),
    awayteam_score int(3) NOT NULL CHECK (awayteam_score >= 0),
    PRIMARY KEY (game_id),
    FOREIGN KEY (venue_id) REFERENCES venue(venue_id),
    FOREIGN KEY (hometeam_id) REFERENCES team(team_id),
    FOREIGN KEY (awayteam_id) REFERENCES team(team_id) 
    
);

CREATE TABLE IF NOT EXISTS performance (
	player_id int(4) NOT NULL,
    game_id varchar(4) NOT NULL,
    points int(3) NOT NULL CHECK (points >= 0), 
    rebounds int(2) NOT NULL CHECK (rebounds >= 0),
    assists int(2) NOT NULL CHECK (assists >= 0),
    steals int(2) NOT NULL CHECK (steals >= 0),
    blocks int(2) NOT NULL CHECK (blocks >= 0),
    mins_played int(3) NOT NULL CHECK (mins_played >= 0),
    PRIMARY KEY (player_id, game_id), 
    FOREIGN KEY (player_id) REFERENCES player(player_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (game_id) REFERENCES game(game_id) ON DELETE CASCADE ON UPDATE CASCADE
);


CREATE TABLE IF NOT EXISTS venue_ownership (
	team_id int(4) NOT NULL,
    venue_id varchar(4) NOT NULL,
    PRIMARY KEY (team_id, venue_id),
    FOREIGN KEY (team_id) REFERENCES team(team_id),
    FOREIGN KEY (venue_id) REFERENCES venue(venue_id)
);

CREATE TABLE IF NOT EXISTS coach (
	firstname varchar(30) NOT NULL,
    lastname varchar(30) NOT NULL,
    dob DATE NOT NULL,
    coaching_role varchar(50),
    team_id int(4) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    PRIMARY KEY (firstname, lastname),
    FOREIGN KEY (team_id) REFERENCES team(team_id)
);


# Create restricted views for security and different access levels
CREATE VIEW player_view
AS SELECT player_id, firstname, lastname, height, weight, position, DOB, team_id, start_date, end_date
FROM player;

CREATE VIEW team_view
AS SELECT team_id, team_name, location
FROM team;

CREATE VIEW venue_view
AS SELECT venue_id, venue_name, city, state, capacity, year_built
FROM venue;

CREATE VIEW game_view
AS SELECT game_id,venue_id,game_date,hometeam_id,awayteam_id,hometeam_score,awayteam_score
FROM game;

CREATE VIEW performance_view
AS SELECT player_id, game_id, points, rebounds, assists, steals, blocks, mins_played
FROM performance;

CREATE VIEW venue_ownership_view
AS SELECT team_id, venue_id
FROM venue_ownership;

CREATE VIEW coach_view
AS SELECT firstname, lastname, dob, coaching_role, team_id, start_date, end_date
FROM coach;


# Create roles for different access levels
CREATE ROLE staff;
CREATE ROLE viewer;


# Set permissions for staff
GRANT ALL ON team TO staff;
GRANT ALL ON player TO staff;
GRANT ALL ON game TO staff;
GRANT ALL ON performance TO staff;
GRANT ALL ON venue TO staff;
GRANT ALL ON venue_ownership TO staff;
GRANT ALL ON coach TO staff;

GRANT ALL ON team_view TO staff;
GRANT ALL ON player_view TO staff;
GRANT ALL ON game_view TO staff;
GRANT ALL ON performance_view TO staff;
GRANT ALL ON venue_view TO staff;
GRANT ALL ON venue_ownership_view TO staff;
GRANT ALL ON coach_view TO staff;


# Set permissions for viewer
GRANT SELECT ON team_view TO viewer;
GRANT SELECT ON player_view TO viewer;
GRANT SELECT ON game_view TO viewer;
GRANT SELECT ON performance_view TO viewer;
GRANT SELECT ON venue_view TO viewer;
GRANT SELECT ON venue_ownership_view TO viewer;
GRANT SELECT ON coach_view TO viewer;



# Create semantic constraints 
delimiter $$
CREATE TRIGGER set_default_player_name BEFORE INSERT ON player
	FOR EACH ROW
    BEGIN
		IF NEW.firstname is NULL THEN
			SET NEW.firstname = "noname";
		END IF;
        
        IF NEW.lastname is NULL THEN
			SET NEW.lastname = "noname";
		END IF;
	END;





# Insert entries into the team table
INSERT INTO team (team_id, team_name, location)
	VALUES (6001, 'Golden State Warriors', 'California');
INSERT INTO team (team_id, team_name, location)
	VALUES (6002, 'Miami Heat', 'Florida');
INSERT INTO team (team_id, team_name, location)
	VALUES (6003, 'Los Angeles Lakers', 'California');
INSERT INTO team (team_id, team_name, location)
	VALUES (6004, 'Boston Celtics', 'Massachusetts');
INSERT INTO team (team_id, team_name, location)
	VALUES (6005, 'Portland Trail Blazers', 'Oregon');



# Insert entries into the player table
INSERT INTO player (player_id, firstname, lastname, height, weight, position, DOB, team_id, start_date, end_date)
    VALUES (0001, "Stephen", "Curry", 1.92, 86, "Point Guard", '1988-03-14', 6001, '2016-01-01', '2022-01-01');   
INSERT INTO player (player_id, firstname, lastname, height, weight, position, DOB, team_id, start_date, end_date)
    VALUES (0002, "Klay", "Thompson", 1.98, 98, "Shooting Guard", '1990-02-08', 6001, '2011-07-05', '2021-12-09');  
INSERT INTO player (player_id, firstname, lastname, height, weight, position, DOB, team_id, start_date, end_date)
    VALUES (0003, "Draymond", "Green", 1.98, 104, "Power Forward", '1990-03-04', 6001, '2012-07-20', '2021-11-3'); 
INSERT INTO player (player_id, firstname, lastname, height, weight, position, DOB, team_id, start_date, end_date)
    VALUES (0004, "Andrew", "Wiggins", 2.01, 89, "Small Forward", '1995-02-23', 6001, '2014-09-17', '2021-12-31'); 
INSERT INTO player (player_id, firstname, lastname, height, weight, position, DOB, team_id, start_date, end_date)
    VALUES (0005, "Marquese", "Chriss", 2.06, 109, "Center", "1997-07-02", 6001, "2016-09-01", "2025-12-31");   
    


# Insert entries into the venue table 
INSERT INTO venue (venue_id, venue_name, city, state, capacity, year_built)
	VALUES ('V001', 'Chase Center', 'San Francisco', 'California', 18064, 2019);
INSERT INTO venue (venue_id, venue_name, city, state, capacity, year_built)
	VALUES ('V002', 'AmericanAirlines Arena', 'Miami', 'Florida', 21000 , 1998);   
INSERT INTO venue (venue_id, venue_name, city, state, capacity, year_built)
	VALUES ('V003', 'Staples Center', 'Los Angeles', 'California', 20000 , 1999);  
INSERT INTO venue (venue_id, venue_name, city, state, capacity, year_built)
	VALUES ('V004', 'TD Garden', 'Boston', 'Massachusetts', 19580 , 1995);
INSERT INTO venue (venue_id, venue_name, city, state, capacity, year_built)
	VALUES ('V005', 'Moda Center', 'Portland', 'Oregon', 19980 , 1995);

    
    
# Insert entries into the game table
INSERT INTO game (game_id, venue_id, game_date, hometeam_id, awayteam_id, hometeam_score, awayteam_score)
	VALUES ('G001','V001', '2020-11-01', 6001, 6002, 99, 90);
INSERT INTO game (game_id, venue_id, game_date, hometeam_id, awayteam_id, hometeam_score, awayteam_score)
	VALUES ('G002','V003', '2020-11-03', 6003, 6004, 80, 110);
INSERT INTO game (game_id, venue_id, game_date, hometeam_id, awayteam_id, hometeam_score, awayteam_score)
	VALUES ('G003','V005', '2020-11-07', 6005, 6001, 99, 144);
INSERT INTO game (game_id, venue_id, game_date, hometeam_id, awayteam_id, hometeam_score, awayteam_score)
	VALUES ('G004','V002', '2020-11-12', 6002, 6004, 112, 119);
INSERT INTO game (game_id, venue_id, game_date, hometeam_id, awayteam_id, hometeam_score, awayteam_score)
	VALUES ('G005','V002', '2020-11-19', 6002, 6005, 90, 99);
    
    
    
# Insert entries into the venue_ownership table
INSERT INTO venue_ownership (team_id, venue_id)
	VALUES (6001, 'V001');
INSERT INTO venue_ownership (team_id, venue_id)
	VALUES (6002, 'V002');
INSERT INTO venue_ownership (team_id, venue_id)
	VALUES (6003, 'V003');
INSERT INTO venue_ownership (team_id, venue_id)
	VALUES (6004, 'V004');
INSERT INTO venue_ownership (team_id, venue_id)
	VALUES (6005, 'V005');



# Insert entries into the coach table 
INSERT INTO coach (firstname, lastname, dob, coaching_role, team_id, start_date, end_date)
	VALUES ('Steve','Kerr', '1965-09-27', 'Head Coach', 6001, '2014-05-14', '2022-01-01');
INSERT INTO coach (firstname, lastname, dob, coaching_role, team_id, start_date, end_date)
	VALUES ('Erik','Spoelstra', '1970-11-1', 'Head Coach', 6002, '2008-06-01', '2022-01-01');
INSERT INTO coach (firstname, lastname, dob, coaching_role, team_id, start_date, end_date)
	VALUES ('Frank','Vogel', '1973-06-21', 'Head Coach', 6003, '2019-05-01', '2022-01-01');
INSERT INTO coach (firstname, lastname, dob, coaching_role, team_id, start_date, end_date)
	VALUES ('Brad','Stevens', '1976-10-22', 'Head Coach', 6004, '2013-07-03', '2022-01-01');
INSERT INTO coach (firstname, lastname, dob, coaching_role, team_id, start_date, end_date)
	VALUES ('Terry','Stotts', '1957-11-25', 'Head Coach', 6005, '2012-04-20', '2022-01-01');



# Insert entries into the performance table 
INSERT INTO performance (player_id, game_id, points, rebounds, assists, steals, blocks, mins_played)
	VALUES (0001, 'G001', 30, 2, 6, 1, 0, 30);
INSERT INTO performance (player_id, game_id, points, rebounds, assists, steals, blocks, mins_played)
	VALUES (0002, 'G001', 23, 4, 3, 4, 2, 26);
INSERT INTO performance (player_id, game_id, points, rebounds, assists, steals, blocks, mins_played)
	VALUES (0003, 'G001', 15, 8, 2, 5, 1, 29);
INSERT INTO performance (player_id, game_id, points, rebounds, assists, steals, blocks, mins_played)
	VALUES (0004, 'G001', 21, 7, 3, 0, 0, 12);
INSERT INTO performance (player_id, game_id, points, rebounds, assists, steals, blocks, mins_played)
	VALUES (0005, 'G001', 10, 2, 9, 3, 1, 20);
    
INSERT INTO performance (player_id, game_id, points, rebounds, assists, steals, blocks, mins_played)
	VALUES (001, 'G003', 42, 3, 6, 0, 2, 35);
INSERT INTO performance (player_id, game_id, points, rebounds, assists, steals, blocks, mins_played)
	VALUES (002, 'G003', 31, 6, 1, 1, 4, 29);
INSERT INTO performance (player_id, game_id, points, rebounds, assists, steals, blocks, mins_played)
	VALUES (003, 'G003', 37, 9, 3, 1, 2, 38);
INSERT INTO performance (player_id, game_id, points, rebounds, assists, steals, blocks, mins_played)
	VALUES (004, 'G003', 12, 2, 0, 0, 0, 18);
INSERT INTO performance (player_id, game_id, points, rebounds, assists, steals, blocks, mins_played)
	VALUES (005, 'G003', 22, 10, 6, 0, 2, 32);

