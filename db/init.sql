
CREATE DATABASE IF NOT EXISTS quest_db;

USE quest_db;

CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(20) NOT NULL,
    email VARCHAR(255) NOT NULL,
    age INT NOT NULL
);

CREATE INDEX idx_user_id ON users(id);

CREATE TABLE channels(
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR NOT NULL,
    description TEXT,
)


CREATE TABLE ganres (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    description TEXT NOT NULL
);


CREATE TABLE channels_genres (
    channel_id INT NOT NULL,
    ganre_id INT NOT NULL,
    PRIMARY KEY(channel_id,ganre_id),
    FOREIGN KEY (channel_id) REFERENCES channels(id),
    FOREIGN KEY (ganre_id) REFERENCES genres(id)
);




CREATE TABLE broadcast_slots(
    id INT AUTO_INCREMENT PRIMARY KEY,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    description TEXT NOT NULL
);





CREATE TABLE titles(
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    description TEXT
);

/*
中間テーブル　タイトル（作品・番組）とジャンルの多対多を表現
*/
CREATE TABLE titles_ganres(
    title_id INT NOT NULL,
    ganre_id INT NOT NULL,
    PRIMARY KEY(title_id,ganre_id),
    FOREIGN KEY (title_id) REFERENCES titles(id),
    FOREIGN KEY (ganre_id) REFERENCES ganres(id) 
);


CREATE TABLE programs(
    title_id INT NOT NULL,
    season_no INT DEFAULT 1,
    epsode_no INT DEFAULT 1,
    description TEXT,
    PRIMARY KEY(title_id,season_no,epsode_no),
    FOREIGN KEY (title_id) REFERENCES titles(id)
);


CREATE TABLE broadcast_slots(
    id INT AUTO_INCREMENT PRIMARY KEY,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
);

CREATE TABLE broadcast_programs(
    id INT AUTO_INCREMENT PRIMARY KEY,
    program_id INT NOT NULL,
    channel_id INT NOT NULL,
    slot_id INT NOT NULL,
    broadcast_date DATE NOT NULL,
);


CREATE TABLE view_logs(
    id INT AUOT_INCREMENT PRIMARY KEY,
    broadcast_programs_id INT NOT NULL,
    user_id INT NOT NULL,
    created_at DATETIME CURRENT_TIMESTAMP,
    FOREIGN KEY(broadcast_program_id) REFERENCES broadcast_programs(id)
    FOREIGN KEY(user_id) REFERENCES users(id)
);




