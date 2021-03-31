CREATE SCHEMA IF NOT EXISTS customers;

CREATE TYPE customers.gender_type AS ENUM
    ('MALE', 'FEMALE');
CREATE TYPE customers.marital_status_type AS ENUM
    ('SINGLE', 'MARRIED', 'DIVORCED', 'WIDOWED');

CREATE TABLE IF NOT EXISTS customers.customers (
    id bigserial NOT NULL PRIMARY KEY,
    first_name varchar(100),
    last_name varchar(100),
    title varchar(20),
    birth_date date,
    gender customers.gender_type,
    marital_status customers.marital_status_type,
    correspondence_language varchar(16)
);

COMMENT ON TABLE customers.customers
    IS 'Данные о покупателях';

CREATE TABLE IF NOT EXISTS customers.countries (
    code varchar(2) NOT NULL PRIMARY KEY,
    name varchar(30)
);

COMMENT ON TABLE customers.countries
    IS 'Страны';

COMMENT ON COLUMN customers.countries.code
    IS 'Двухбуквенный код страны';

COMMENT ON COLUMN customers.countries.name
    IS 'Название страны';

CREATE TABLE IF NOT EXISTS customers.cities (
    id bigserial NOT NULL PRIMARY KEY,
    country_code varchar(2) NOT NULL,
    region varchar(30),
    city varchar(40),

    CONSTRAINT fk_cities_countries FOREIGN KEY (country_code)
        REFERENCES customers.countries(code)
);

COMMENT ON TABLE customers.cities
    IS 'Города';

CREATE TABLE IF NOT EXISTS customers.addresses (
    id bigserial NOT NULL PRIMARY KEY,
    customer_id bigint NOT NULL,
    postal_code varchar(10) NOT NULL,
    city_id bigint,
    street varchar(100),
    building varchar(10),

    CONSTRAINT fk_addresses_customers FOREIGN KEY (customer_id)
        REFERENCES customers.customers(id),

    CONSTRAINT fk_addresses_cities FOREIGN KEY (city_id)
        REFERENCES customers.cities(id)
);

COMMENT ON TABLE customers.addresses
    IS 'Адреса покупателей';