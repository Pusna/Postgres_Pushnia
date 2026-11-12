-- Атомарність
-- частковий відкат транзакції при помилці перша книга видається, а друга скасовується
BEGIN;
UPDATE copies SET available = false WHERE id = 1;
INSERT INTO loans (copy_id, book_id, reader_id, staff_id, due_date, status) VALUES (1, 1, 1, 1, CURRENT_DATE + 14, 'issued');
SAVEPOINT sp_before_second_book;
UPDATE copies SET available = false WHERE id = 2;
INSERT INTO loans (copy_id, book_id, reader_id, staff_id, due_date, status) VALUES (2, 2, 1, 1, CURRENT_DATE + 14, 'issued');
ROLLBACK TO SAVEPOINT sp_before_second_book;
COMMIT;

-- Блокування
-- Лок рядка від подвійної видачі з таймаутом у 2 секунди
BEGIN;
SET lock_timeout = '2s';
SELECT id, available FROM copies WHERE id = 3 FOR UPDATE;
UPDATE copies SET available = false WHERE id = 3;
INSERT INTO loans (copy_id, book_id, reader_id, staff_id, due_date, status) VALUES (3, 3, 2, 1, CURRENT_DATE + 14, 'issued');
COMMIT;

-- Ізоляція (READ COMMITTED)
-- базовий рівень, дані можуть непомітно змінитися іншою транзакцією
BEGIN;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT count(*) FROM copies WHERE available = true;
SELECT count(*) FROM copies WHERE available = true;
COMMIT;

-- Ізоляція (REPEATABLE READ)
-- захист від змін, база фіксує знімок даних на момент початку транзакції
BEGIN;
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SELECT count(*) FROM copies WHERE available = true;
SELECT count(*) FROM copies WHERE available = true;
COMMIT;

-- Ізоляція (SERIALIZABLE)
-- найвищий захист, база автоматично скасовує транзакції при ризику фантомних читань
BEGIN;
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
SELECT id, available FROM copies WHERE book_id = 3 AND available = true;
UPDATE copies SET available = false WHERE book_id = 3 AND available = true;
COMMIT;

-- Довговічність (Durability)
-- гарантія того, що після COMMIT дані не зникнуть навіть при збої сервера
BEGIN;
INSERT INTO publishers (name, address) VALUES ('Тестове Видавництво', 'Київ');
COMMIT;