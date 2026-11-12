DROP TABLE IF EXISTS audit_log_partitioned CASCADE;

CREATE TABLE audit_log_partitioned (
    id BIGINT GENERATED ALWAYS AS IDENTITY,
    user_role TEXT,
    user_id INTEGER,
    action TEXT,
    details JSONB,
    created_at TIMESTAMP DEFAULT now()
) PARTITION BY RANGE (created_at);


CREATE TABLE audit_log_2026_11 PARTITION OF audit_log_partitioned
    FOR VALUES FROM ('2026-11-01') TO ('2026-12-01');

CREATE TABLE audit_log_2026_12 PARTITION OF audit_log_partitioned
    FOR VALUES FROM ('2026-12-01') TO ('2027-01-01');


INSERT INTO audit_log_partitioned (user_role, user_id, action, details, created_at)
VALUES ('system', 1, 'TEST PARTITION', '{"status": "ok"}', '2026-11-15');