--Тригер зберігає дані читача в лог при його видаленні
CREATE OR REPLACE FUNCTION log_reader_deletion() RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO audit_log (user_role, user_id, action, details)
    VALUES ('system', NULL, 'DELETE on readers', row_to_json(OLD));
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_log_reader_deletion
AFTER DELETE ON readers
FOR EACH ROW EXECUTE FUNCTION log_reader_deletion();

-- Тригер оновлює загальну кількість екземплярів книги
CREATE OR REPLACE FUNCTION update_total_copies() RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE books SET total_copies = total_copies + 1 WHERE id = NEW.book_id;

    ELSIF TG_OP = 'DELETE' THEN
        UPDATE books SET total_copies = GREATEST(0, total_copies - 1) WHERE id = OLD.book_id;

    ELSIF TG_OP = 'UPDATE' AND OLD.book_id IS DISTINCT FROM NEW.book_id THEN
        UPDATE books SET total_copies = GREATEST(0, total_copies - 1) WHERE id = OLD.book_id;
        UPDATE books SET total_copies = total_copies + 1 WHERE id = NEW.book_id;

    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_total_copies
AFTER INSERT OR DELETE OR UPDATE OF book_id ON copies
FOR EACH ROW EXECUTE FUNCTION update_total_copies();