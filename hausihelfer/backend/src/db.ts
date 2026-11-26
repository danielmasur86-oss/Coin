import { DatabaseSync } from "node:sqlite";
import { mkdirSync } from "node:fs";
import { dirname } from "node:path";

/**
 * SQLite database (built into Node.js, no extra service needed).
 * Stores only usage counters and error reports – no photos and no personal data.
 * Set DB_PATH to a file on a persistent volume in production.
 */
const DB_PATH = process.env.DB_PATH ?? "./data/hausihelfer.db";

function open(): DatabaseSync {
  if (DB_PATH !== ":memory:") mkdirSync(dirname(DB_PATH), { recursive: true });
  const db = new DatabaseSync(DB_PATH);
  db.exec(`
    PRAGMA journal_mode = WAL;
    CREATE TABLE IF NOT EXISTS usage (
      user_id TEXT NOT NULL,
      period  TEXT NOT NULL,           -- e.g. "w:2026-W48" (week) or "d:2026-11-26" (day)
      count   INTEGER NOT NULL DEFAULT 0,
      PRIMARY KEY (user_id, period)
    );
    CREATE TABLE IF NOT EXISTS reports (
      id         INTEGER PRIMARY KEY AUTOINCREMENT,
      created_at TEXT NOT NULL,
      language   TEXT NOT NULL,
      subject    TEXT NOT NULL,
      topic_de   TEXT NOT NULL,
      task_de    TEXT NOT NULL,
      comment    TEXT NOT NULL
    );
  `);
  return db;
}

export const db = open();
