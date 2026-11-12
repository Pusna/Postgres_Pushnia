--Функція обчислення боргу яка рахує, на скільки днів читач прострочив книгу
CREATE OR REPLACE FUNCTION overdue_days(p_loan_id INT) 
RETURNS INT AS $$
DECLARE 
    v_days INT;
BEGIN
    SELECT GREATEST(0, (COALESCE(returned_at::date, CURRENT_DATE) - due_date)) INTO v_days
    FROM loans 
    WHERE id = p_loan_id;
    
    RETURN COALESCE(v_days, 0);
END;
$$ LANGUAGE plpgsql;


-- Функція перевірки - чи є у читача зараз прострочені книги
CREATE OR REPLACE FUNCTION has_overdue_books(p_reader_id INT) 
RETURNS BOOLEAN AS $$
DECLARE 
    v_has_debt BOOLEAN;
BEGIN
    SELECT EXISTS (
        SELECT 1 FROM loans 
        WHERE reader_id = p_reader_id 
          AND returned_at IS NULL 
          AND due_date < CURRENT_DATE
    ) INTO v_has_debt;
    
    RETURN v_has_debt;
END;
$$ LANGUAGE plpgsql;



-- Процедура Видачі книги
CREATE OR REPLACE PROCEDURE issue_book(
    p_copy_id INT, 
    p_reader_id INT, 
    p_staff_id INT, 
    p_due_date DATE
) AS $$
BEGIN
    
    IF NOT EXISTS (SELECT 1 FROM readers WHERE id = p_reader_id AND status = 'active') THEN
        RAISE EXCEPTION 'Видача заборонена: читача не знайдено або його квиток неактивний!';
    END IF;
    
    IF has_overdue_books(p_reader_id) THEN
        RAISE EXCEPTION 'Видача заборонена: у читача є неповернуті прострочені книги!';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM copies WHERE id = p_copy_id AND available = true) THEN
        RAISE EXCEPTION 'Екземпляр книги недоступний для видачі (ID копії: %)', p_copy_id;
    END IF;

    INSERT INTO loans (copy_id, book_id, reader_id, staff_id, issued_at, due_date, status)
    SELECT p_copy_id, book_id, p_reader_id, p_staff_id, CURRENT_TIMESTAMP, p_due_date, 'issued'
    FROM copies WHERE id = p_copy_id;

    UPDATE copies SET available = false WHERE id = p_copy_id;
END;
$$ LANGUAGE plpgsql;



-- Процедура Поверненя книги
CREATE OR REPLACE PROCEDURE return_book(p_loan_id INT) AS $$
DECLARE
    v_copy_id INT;
    v_overdue INT;
BEGIN
    SELECT copy_id INTO v_copy_id FROM loans WHERE id = p_loan_id AND returned_at IS NULL;
    
    IF v_copy_id IS NULL THEN
        RAISE EXCEPTION 'Ця видача вже закрита або не існує!';
    END IF;

    UPDATE loans SET returned_at = CURRENT_TIMESTAMP, status = 'returned' WHERE id = p_loan_id;
    
    UPDATE copies SET available = true WHERE id = v_copy_id;

    v_overdue := overdue_days(p_loan_id);
    IF v_overdue > 0 THEN
        INSERT INTO fines (loan_id, amount)
        VALUES (p_loan_id, v_overdue * 10.00);
    END IF;

END;
$$ LANGUAGE plpgsql;