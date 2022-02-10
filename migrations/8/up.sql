CREATE TABLE IF NOT EXISTS counters (
    counter_id SERIAL PRIMARY KEY,
    counter_name VARCHAR(64),
    counter_value INTEGER
);

INSERT INTO counters (counter_name, counter_value)
VALUES ('visitor', 1337);
