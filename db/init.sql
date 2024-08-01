
CREATE DATABASE IF NOT EXISTS quest_db;

USE quest_db;

CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(20) NOT NULL,
    email VARCHAR(255) NOT NULL,
    age INT NOT NULL
);

INSERT INTO users(name,email,age) VALUES('saku','email_address',5);

CREATE TABLE ganres (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    description TEXT NOT NULL
);


CREATE TABLE broadcast_slots(
    id INT AUTO_INCREMENT PRIMARY KEY,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    description TEXT NOT NULL
);


CREATE TABLE programs(
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    season INT DEFAULT 0,
    epsode_no INT DEFAULT 1

);