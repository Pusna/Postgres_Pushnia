-- Список книг із їхніми авторами
SELECT 
    b.id, 
    b.title, 
    b.isbn, 
    string_agg(CONCAT_WS(' ', a.first_name, a.last_name), ', ') AS authors
FROM books b
JOIN book_authors ba ON ba.book_id = b.id
JOIN authors a ON a.id = ba.author_id
GROUP BY b.id, b.title, b.isbn;

-- Книги, які зараз видані і не повернуті
SELECT 
    l.id AS loan_id, 
    r.card_number, 
    r.first_name, 
    r.last_name, 
    b.title, 
    l.issued_at, 
    l.due_date
FROM loans l
JOIN readers r ON r.id = l.reader_id
JOIN copies c ON c.id = l.copy_id
JOIN books b ON b.id = c.book_id
WHERE l.returned_at IS NULL;

--Кількість виданих книг по читачах за останній місяць
SELECT 
    r.id, 
    r.first_name, 
    r.last_name, 
    COUNT(l.id) AS loans_last_month
FROM loans l
JOIN readers r ON r.id = l.reader_id
WHERE l.issued_at >= (CURRENT_DATE - INTERVAL '30 days')
GROUP BY r.id, r.first_name, r.last_name
ORDER BY loans_last_month DESC;

-- Знайти читачів, які мають прострочені книги
SELECT DISTINCT r.*
FROM readers r
WHERE EXISTS (
    SELECT 1 
    FROM loans l 
    WHERE l.reader_id = r.id 
      AND l.returned_at IS NULL 
      AND l.due_date < CURRENT_DATE
);


-- Представлення для зручного перегляду всіх активних видач
CREATE OR REPLACE VIEW view_active_loans AS
SELECT 
    l.id AS loan_id, 
    l.copy_id, 
    b.title, 
    r.card_number, 
    r.first_name, 
    r.last_name, 
    l.issued_at, 
    l.due_date
FROM loans l
JOIN copies c ON c.id = l.copy_id
JOIN books b ON b.id = c.book_id
JOIN readers r ON r.id = l.reader_id
WHERE l.returned_at IS NULL;


--Представлення для перевірки доступністі книг у бібліотеці
CREATE OR REPLACE VIEW view_book_availability AS
SELECT 
    b.id AS book_id,
    b.isbn,
    b.title,
    b.total_copies,
    COUNT(c.id) FILTER (WHERE c.available = true) AS available_now,
    COUNT(c.id) FILTER (WHERE c.available = false) AS loaned_now
FROM books b
LEFT JOIN copies c ON b.id = c.book_id
GROUP BY b.id, b.isbn, b.title, b.total_copies;