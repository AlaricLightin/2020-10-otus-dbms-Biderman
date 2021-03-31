-- Таблица с сырыми данными
CREATE TABLE IF NOT EXISTS raw_data (
    id bigserial NOT NULL PRIMARY KEY,
    title varchar(20),
    first_name varchar(20),
    last_name varchar(30),
    corr_language varchar(2),
    birth_date varchar(10),
    gender varchar(10),
    marital_status varchar(10),
    country varchar(2),
    postal_code varchar(10),
    region varchar(30),
    city varchar(40),
    street varchar(100),
    building varchar(10)
);

-- Копирование из файла в таблицу
COPY raw_data(title, first_name, last_name, corr_language, birth_date, gender, marital_status,
              country, postal_code, region, city, street, building)
    FROM '/data/some_customers.csv'
WITH (FORMAT CSV, HEADER);

-- Создание справочника стран
-- (В справочник добавляются только коды, названия можно добавить разве что в ручном режиме
-- или воспользовавшись какой-нибудь ещё базой.)
INSERT INTO customers.countries (code)
SELECT DISTINCT country FROM raw_data;

-- Функция для удобства работы с датой рождения
CREATE OR REPLACE FUNCTION get_birth_date(birth_date_string varchar)
    RETURNS date
AS
$$
SELECT CASE
           WHEN birth_date_string <> '' THEN CAST(birth_date_string AS date)
           END;
$$ LANGUAGE SQL;

-- Функция для удобства работы с гендером
CREATE OR REPLACE FUNCTION get_gender(gender_string varchar)
    RETURNS customers.gender_type
AS
$$
SELECT CASE gender_string
           WHEN 'Male' THEN 'MALE'::customers.gender_type
           WHEN 'Female' THEN 'FEMALE'::customers.gender_type
           END;
$$
    LANGUAGE SQL;

-- Проверка, эквивалентны ли пары "улица-номер дома"
CREATE OR REPLACE FUNCTION is_address_string_equal(street1 varchar, building1 varchar,
                                                   street2 varchar, building2 varchar)
    RETURNS boolean
AS
$$
SELECT (street1 = street2 and building1 = building2)
           OR (building1 = '' AND (street1 = street2 || ' ' || building2 OR street1 = building2 || ' ' || street2))
           OR (building2 = '' AND (street2 = street1 || ' ' || building1 OR street2 = building1 || ' ' || street1))
$$ LANGUAGE sql;

-- Вспомогательная функция для добавления адресов
CREATE OR REPLACE PROCEDURE add_address(r record, current_customer_id bigint)
    LANGUAGE 'plpgsql'
AS
$$
DECLARE
    current_city_id bigint;
BEGIN
    -- Сначала проверяем, есть ли у нас такой город
    SELECT id
    INTO current_city_id
    FROM customers.cities
    WHERE country_code = r.country
      AND region = r.region
      AND city = r.city;

    IF NOT FOUND THEN -- если нет, то добавляем вместе с адресом
        INSERT INTO customers.cities(country_code, region, city)
        VALUES (r.country, r.region, r.city)
        RETURNING id INTO current_city_id;

        INSERT INTO customers.addresses (customer_id, postal_code, city_id, street, building)
        VALUES (current_customer_id, r.postal_code, current_city_id, r.street, r.building);
    ELSE -- если есть, то проверяем, может быть адрес такой уже тоже есть
        PERFORM 1
        FROM customers.addresses
        WHERE customer_id = current_customer_id
          AND postal_code = r.postal_code
          AND city_id = current_city_id
          AND is_address_string_equal(street, building, r.street, r.building);

        IF NOT FOUND THEN
            INSERT INTO customers.addresses (customer_id, postal_code, city_id, street, building)
            VALUES (current_customer_id, r.postal_code, current_city_id, r.street, r.building);
        END IF;
    END IF;
END;
$$;

-- Основная процедура импорта данных из вспомогательной таблицы
DO
$$
    DECLARE
        c CURSOR FOR SELECT *
                     FROM raw_data
                     ORDER BY id;
        r                   record;
        current_customer_id bigint;
    BEGIN
        current_customer_id := null;
        FOR r in c -- идём по всем строкам
            LOOP
                IF r.first_name <> '' or r.last_name <> '' THEN
                    -- Если у нас строка с непустыми именем или фамилией, проверяем, есть ли у нас уже этот покупатель
                    SELECT id
                    INTO current_customer_id
                    FROM customers.customers
                    WHERE first_name = r.first_name
                      AND last_name = r.last_name
                      AND birth_date IS NOT DISTINCT FROM get_birth_date(r.birth_date)
                      AND gender IS NOT DISTINCT FROM get_gender(r.gender);

                    IF NOT FOUND THEN -- Если покупателя нет, то добавляем
                        INSERT INTO customers.customers (first_name, last_name, title, birth_date, gender,
                                                         correspondence_language)
                        VALUES (r.first_name,
                                r.last_name,
                                r.title,
                                get_birth_date(r.birth_date),
                                get_gender(r.gender),
                                r.corr_language)
                        RETURNING id INTO current_customer_id;
                    END IF;

                    CALL add_address(r, current_customer_id);
                ELSE -- если у нас пустое имя, то мы берём предыдущее
                    IF current_customer_id IS NOT NULL THEN
                        CALL add_address(r, current_customer_id);
                    END IF;
                END IF;
            END LOOP;
    END
$$;
