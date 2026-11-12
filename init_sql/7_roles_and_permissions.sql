DROP ROLE IF EXISTS admin_user;
DROP ROLE IF EXISTS librarian_user;
DROP ROLE IF EXISTS operator_user;
DROP ROLE IF EXISTS reader_user;

DROP ROLE IF EXISTS library_admin;
DROP ROLE IF EXISTS library_staff;
DROP ROLE IF EXISTS library_operator;
DROP ROLE IF EXISTS library_reader;


CREATE ROLE library_admin WITH NOLOGIN;
CREATE ROLE library_staff WITH NOLOGIN;
CREATE ROLE library_operator WITH NOLOGIN;
CREATE ROLE library_reader WITH NOLOGIN;


GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO library_admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO library_admin;


GRANT SELECT, INSERT, UPDATE, DELETE ON
    books, copies, readers, loans, fines, authors, book_authors, publishers
TO library_staff;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO library_staff;


GRANT SELECT, INSERT, UPDATE ON copies, readers, loans, fines TO library_operator;

GRANT SELECT ON books, authors, book_authors, publishers TO library_operator;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO library_operator;


GRANT SELECT ON books, copies, authors, publishers TO library_reader;


CREATE USER admin_user WITH PASSWORD 'admin_123';
GRANT library_admin TO admin_user;

CREATE USER librarian_user WITH PASSWORD 'lib_123';
GRANT library_staff TO librarian_user;

CREATE USER operator_user WITH PASSWORD 'oper_123';
GRANT library_operator TO operator_user;

CREATE USER reader_user WITH PASSWORD 'reader_123';
GRANT library_reader TO reader_user;