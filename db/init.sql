CREATE DATABASE IF NOT EXISTS quest_db;

USE quest_db;

CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(20) NOT NULL,
    email VARCHAR(255) NOT NULL,
    age INT NOT NULL
);



CREATE INDEX idx_user_id ON users(id);

CREATE TABLE channels (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    description TEXT
);

CREATE TABLE genres (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    description TEXT NOT NULL
);

CREATE TABLE channels_genres (
    channel_id INT NOT NULL,
    genre_id INT NOT NULL,
    PRIMARY KEY(channel_id, genre_id),
    FOREIGN KEY (channel_id) REFERENCES channels(id),
    FOREIGN KEY (genre_id) REFERENCES genres(id)
);

CREATE TABLE broadcast_slots (
    id INT AUTO_INCREMENT PRIMARY KEY,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    description TEXT NOT NULL
);

CREATE TABLE titles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    description TEXT
);

/*
中間テーブル　タイトル（作品・番組）とジャンルの多対多を表現
*/
CREATE TABLE titles_genres (
    title_id INT NOT NULL,
    genre_id INT NOT NULL,
    PRIMARY KEY(title_id, genre_id),
    FOREIGN KEY (title_id) REFERENCES titles(id),
    FOREIGN KEY (genre_id) REFERENCES genres(id)
);

CREATE TABLE programs (
    title_id INT NOT NULL,
    season_no INT DEFAULT 1,
    episode_no INT DEFAULT 1,
    description TEXT,
    PRIMARY KEY(title_id, season_no, episode_no),
    FOREIGN KEY (title_id) REFERENCES titles(id)
);

CREATE TABLE broadcast_programs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    program_id INT NOT NULL,
    channel_id INT NOT NULL,
    slot_id INT NOT NULL,
    broadcast_date DATE NOT NULL
);

CREATE TABLE view_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    broadcast_program_id INT NOT NULL,
    user_id INT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (broadcast_program_id) REFERENCES broadcast_programs(id),
    FOREIGN KEY (user_id) REFERENCES users(id)
);



-- usersテーブルにデータを挿入
INSERT INTO users (name, email, age) VALUES
('Alice', 'alice@example.com', 25),
('Bob', 'bob@example.com', 30),
('Charlie', 'charlie@example.com', 22),
('David', 'david@example.com', 28),
('Eve', 'eve@example.com', 35);

-- channelsテーブルにデータを挿入
INSERT INTO channels (name, description) VALUES
('Channel 1', 'This is Channel 1'),
('Channel 2', 'This is Channel 2'),
('Channel 3', 'This is Channel 3');

-- genresテーブルにデータを挿入
INSERT INTO genres (name, description) VALUES
('Genre 1', 'This is Genre 1'),
('Genre 2', 'This is Genre 2'),
('Genre 3', 'This is Genre 3');

-- channels_genresテーブルにデータを挿入
INSERT INTO channels_genres (channel_id, genre_id) VALUES
(1, 1),
(1, 2),
(2, 2),
(2, 3),
(3, 1);

-- broadcast_slotsテーブルにデータを挿入
INSERT INTO broadcast_slots (start_time, end_time, description) VALUES
('08:00:00', '09:00:00', 'Morning Show'),
('12:00:00', '13:00:00', 'Lunch Time News'),
('18:00:00', '19:00:00', 'Evening News');

-- titlesテーブルにデータを挿入
INSERT INTO titles (name, description) VALUES
('Title 1', 'This is Title 1'),
('Title 2', 'This is Title 2'),
('Title 3', 'This is Title 3');

-- titles_genresテーブルにデータを挿入
INSERT INTO titles_genres (title_id, genre_id) VALUES
(1, 1),
(1, 2),
(2, 2),
(2, 3),
(3, 1);

-- programsテーブルにデータを挿入
INSERT INTO programs (title_id, season_no, episode_no, description) VALUES
(1, 1, 1, 'Episode 1 of Season 1 of Title 1'),
(1, 1, 2, 'Episode 2 of Season 1 of Title 1'),
(2, 1, 1, 'Episode 1 of Season 1 of Title 2'),
(2, 1, 2, 'Episode 2 of Season 1 of Title 2'),
(3, 1, 1, 'Episode 1 of Season 1 of Title 3');

-- broadcast_programsテーブルにデータを挿入
INSERT INTO broadcast_programs (program_id, channel_id, slot_id, broadcast_date) VALUES
(1, 1, 1, '2023-01-01'),
(2, 1, 2, '2023-01-02'),
(3, 2, 1, '2023-01-03'),
(4, 2, 2, '2023-01-04'),
(5, 3, 1, '2023-01-05');

-- view_logsテーブルにデータを挿入
INSERT INTO view_logs (broadcast_program_id, user_id) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5);