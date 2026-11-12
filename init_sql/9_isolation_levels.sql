-- Рівень READ COMMITTED
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT count(*) FROM copies WHERE available = true;

-- Паралельна транзакція змінює дані
BEGIN;
UPDATE copies SET available = false WHERE id = 1;
COMMIT;

-- Фантомне читання (результат змінився)
SELECT count(*) FROM copies WHERE available = true;
COMMIT;


-- Рівень REPEATABLE READ
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SELECT count(*) FROM copies WHERE available = true;

-- Паралельна транзакція змінює дані
BEGIN;
UPDATE copies SET available = false WHERE id = 2;
COMMIT;

-- Захист від фантомів (результат НЕ змінився)
SELECT count(*) FROM copies WHERE available = true;
COMMIT;