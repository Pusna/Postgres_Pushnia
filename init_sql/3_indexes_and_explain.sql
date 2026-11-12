-- Створення B-Tree індексів для прискорення пошуку
CREATE INDEX IF NOT EXISTS idx_books_isbn ON books (isbn);
CREATE INDEX IF NOT EXISTS idx_copies_book_id ON copies (book_id);
CREATE INDEX IF NOT EXISTS idx_loans_reader_id ON loans (reader_id);
CREATE INDEX IF NOT EXISTS idx_readers_card_number ON readers (card_number);

-- Частковий індекс який зберігає в пам'яті тільки доступні екземпляри
CREATE INDEX IF NOT EXISTS idx_copies_available ON copies (book_id) WHERE available = true;



SET enable_seqscan = OFF;

EXPLAIN ANALYZE 
SELECT * FROM books WHERE isbn = '978-1';

-- Перевірка часткового індексу
EXPLAIN ANALYZE 
SELECT * FROM copies WHERE book_id = 1 AND available = true;


SET enable_seqscan = ON;