import os
import pytest
import psycopg2
from dotenv import load_dotenv

load_dotenv()

DB_URL = os.getenv("DATABASE_URL")


@pytest.fixture
def db_conn():
    conn = psycopg2.connect(DB_URL)
    cursor = conn.cursor()
    yield cursor
    conn.rollback()
    cursor.close()
    conn.close()


def test_books_exist(db_conn):
    """Перевірка, що тестові дані успішно завантажені (DDL + INSERT)"""
    db_conn.execute("SELECT COUNT(*) FROM books;")
    count = db_conn.fetchone()[0]
    assert count > 0, "В базі немає книг!"


def test_overdue_days_function(db_conn):
    """Перевірка роботи SQL-функції розрахунку штрафних днів (overdue_days)"""
    db_conn.execute("""
        INSERT INTO loans (copy_id, book_id, reader_id, staff_id, issued_at, due_date, status)
        VALUES (1, 1, 1, 1, '2023-01-01', '2023-01-15', 'issued') RETURNING id;
    """)
    loan_id = db_conn.fetchone()[0]

    db_conn.execute("SELECT overdue_days(%s);", (loan_id,))
    overdue = db_conn.fetchone()[0]

    assert overdue > 0, "Функція розрахунку штрафних днів працює некоректно"



def test_transaction_rollback_on_unavailable_book(db_conn):
    """Перевірка ACID транзакцій: блокування видачі недоступної книги (Збережена процедура)"""
    db_conn.execute("UPDATE copies SET available = false WHERE id = 2;")

    with pytest.raises(psycopg2.errors.RaiseException) as excinfo:
        db_conn.execute("CALL issue_book(2, 1, 1, CURRENT_DATE + 14);")

    assert "недоступний" in str(excinfo.value).lower(), "Транзакція дозволила видати недоступну книгу!"


def test_view_active_loans(db_conn):
    """Перевірка роботи представлення (VIEW) view_active_loans"""
    db_conn.execute("SELECT COUNT(*) FROM view_active_loans;")
    initial_count = db_conn.fetchone()[0]

    db_conn.execute("""
        INSERT INTO loans (copy_id, book_id, reader_id, staff_id, status)
        VALUES (3, 1, 1, 1, 'issued');
    """)

    db_conn.execute("SELECT COUNT(*) FROM view_active_loans;")
    new_count = db_conn.fetchone()[0]

    assert new_count == initial_count + 1, "Представлення view_active_loans не відображає нові видачі"




def test_trigger_update_total_copies(db_conn):
    """Перевірка тригера: додавання нової копії автоматично змінює books.total_copies"""
    db_conn.execute("SELECT total_copies FROM books WHERE id = 1;")
    initial_copies = db_conn.fetchone()[0]

    db_conn.execute(
        "INSERT INTO copies (book_id, barcode, condition, available) VALUES (1, 'TEST_BARCODE', 'new', true);")

    db_conn.execute("SELECT total_copies FROM books WHERE id = 1;")
    new_copies = db_conn.fetchone()[0]

    assert new_copies == initial_copies + 1, "Тригер trg_update_total_copies не збільшив загальну кількість книг!"


def test_audit_log_trigger(db_conn):
    """Перевірка безпеки: видалення читача викликає логування в таблицю audit_log"""
    db_conn.execute("SELECT COUNT(*) FROM audit_log;")
    initial_logs = db_conn.fetchone()[0]

    db_conn.execute("DELETE FROM readers WHERE id = 2;")

    db_conn.execute("SELECT COUNT(*) FROM audit_log;")
    new_logs = db_conn.fetchone()[0]

    assert new_logs > initial_logs, "Тригер безпеки не записав видалення читача в audit_log!"