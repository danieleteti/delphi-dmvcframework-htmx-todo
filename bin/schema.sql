-- Database schema for the HTMX Todo sample.
-- Executed automatically at startup by EnsureSqliteDatabase (FDConnectionConfigU)
-- when bin/todo.db is created fresh. IF NOT EXISTS makes it a safe no-op if the
-- table already exists, so it is also idempotent against an existing database.
CREATE TABLE IF NOT EXISTS todos (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    content TEXT(200)
);