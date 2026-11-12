CREATE TABLE IF NOT EXISTS publishers (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    address TEXT,
    phone TEXT,
    email TEXT
);

CREATE TABLE IF NOT EXISTS books (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    isbn VARCHAR(20) UNIQUE,
    title TEXT NOT NULL,
    subtitle TEXT,
    publisher_id INTEGER REFERENCES publishers(id),
    year SMALLINT,
    pages INTEGER,
    language VARCHAR(50),
    description TEXT,
    total_copies INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT now()
);

CREATE TABLE IF NOT EXISTS authors (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name TEXT,
    last_name TEXT NOT NULL,
    birth_date DATE,
    bio TEXT
);

CREATE TABLE IF NOT EXISTS book_authors (
    book_id INTEGER REFERENCES books (id) ON DELETE CASCADE,
    author_id INTEGER REFERENCES authors (id) ON DELETE CASCADE,
    contribution TEXT,
    PRIMARY KEY (book_id, author_id)
);

CREATE TABLE IF NOT EXISTS copies (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    book_id INTEGER REFERENCES books (id) ON DELETE CASCADE,
    barcode VARCHAR(50) UNIQUE,
    condition TEXT,
    available BOOLEAN DEFAULT true
);

CREATE TABLE IF NOT EXISTS readers (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    card_number VARCHAR(20) UNIQUE NOT NULL,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    email TEXT,
    phone TEXT,
    registration_date DATE DEFAULT CURRENT_DATE,
    status VARCHAR(20) DEFAULT 'active'
);

CREATE TABLE IF NOT EXISTS staff (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    username TEXT UNIQUE NOT NULL,
    hashed_password TEXT NOT NULL,
    role VARCHAR(20) NOT NULL,
    full_name TEXT,
    email TEXT
);

CREATE TABLE IF NOT EXISTS loans (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    copy_id INTEGER REFERENCES copies (id),
    book_id INTEGER REFERENCES books (id),
    reader_id INTEGER REFERENCES readers (id) ON DELETE SET NULL,
    staff_id INTEGER REFERENCES staff (id),
    issued_at TIMESTAMP DEFAULT now(),
    due_date DATE,
    returned_at TIMESTAMP,
    status VARCHAR(20) DEFAULT 'issued'
);

CREATE TABLE IF NOT EXISTS fines (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    loan_id INTEGER REFERENCES loans (id) ON DELETE CASCADE,
    amount NUMERIC(8,2) NOT NULL DEFAULT 0,
    paid BOOLEAN DEFAULT false,
    issued_at TIMESTAMP DEFAULT now(),
    paid_at TIMESTAMP
);

CREATE TABLE IF NOT EXISTS audit_log (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_role TEXT,
    user_id INTEGER,
    action TEXT,
    details JSONB,
    created_at TIMESTAMP DEFAULT now()
);


CREATE TABLE IF NOT EXISTS backups (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    file_name TEXT NOT NULL,
    backup_date TIMESTAMP DEFAULT now(),
    size_mb NUMERIC(8,2),
    checksum TEXT,
    status VARCHAR(20) DEFAULT 'success',
    retention_policy VARCHAR(50) DEFAULT '7 days'
);




INSERT INTO publishers (name) VALUES 
('А-БА-БА-ГА-ЛА-МА-ГА'), 
('Видавництво Старого Лева');

INSERT INTO authors (first_name, last_name) VALUES
('Тарас', 'Шевченко'), 
('Леся', 'Українка'), 
('Джоан', 'Роулінг');

INSERT INTO books (isbn, title, publisher_id, year, pages, language, total_copies) VALUES 
('978-1', 'Кобзар', 1, 1840, 720, 'uk', 3),
('978-2', 'Лісова пісня', 2, 1911, 144, 'uk', 2),
('978-3', 'Гаррі Поттер і філософський камінь', 1, 1997, 320, 'uk', 5);

INSERT INTO book_authors (book_id, author_id) VALUES 
(1,1), (2,2), (3,3);

INSERT INTO copies (book_id, barcode) VALUES
(1, 'BC1001'), (1, 'BC1002'), (1, 'BC1003'),
(2, 'BC2001'), (2, 'BC2002'),
(3, 'BC3001'), (3, 'BC3002'), (3, 'BC3003'), (3, 'BC3004'), (3, 'BC3005');

INSERT INTO readers (card_number, first_name, last_name, email) VALUES
('C0001', 'Іван', 'Іваненко', 'ivan@example.com'),
('C0002', 'Олена', 'Петрів', 'olena@example.com');

INSERT INTO staff (username, hashed_password, role, full_name, email) VALUES
('admin', 'test_hash_123', 'librarian', 'Олексій Бібліотекар', 'admin@library.com');

