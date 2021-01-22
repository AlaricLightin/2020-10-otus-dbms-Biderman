CREATE database otus;
USE otus;

CREATE TABLE users (
    id serial NOT NULL PRIMARY KEY,
    name varchar(20) NOT NULL,
    surname varchar(20) NOT NULL
);

INSERT INTO users(name, surname) VALUES ('Ivan', 'Ivanov');