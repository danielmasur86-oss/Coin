import { db } from "./db.js";

/** Free plan: explanations per user per ISO week. */
export const FREE_PER_WEEK = Number(process.env.FREE_PER_WEEK ?? 3);
/** Premium "fair use": explanations per user per day, protects against runaway AI cost. */
export const PREMIUM_PER_DAY = Number(process.env.PREMIUM_PER_DAY ?? 25);
/** Safety cap across ALL users per day (UTC). 0 = no cap. */
export const GLOBAL_PER_DAY = Number(process.env.GLOBAL_PER_DAY ?? 0);

export function isoWeekKey(date: Date): string {
  const d = new Date(Date.UTC(date.getUTCFullYear(), date.getUTCMonth(), date.getUTCDate()));
  const day = d.getUTCDay() || 7;
  d.setUTCDate(d.getUTCDate() + 4 - day);
  const yearStart = new Date(Date.UTC(d.getUTCFullYear(), 0, 1));
  const week = Math.ceil(((d.getTime() - yearStart.getTime()) / 86_400_000 + 1) / 7);
  return `${d.getUTCFullYear()}-W${String(week).padStart(2, "0")}`;
}

const dayKey = (date: Date) => date.toISOString().slice(0, 10);
const GLOBAL_USER = "__all__";

const getStmt = db.prepare("SELECT count FROM usage WHERE user_id = ? AND period = ?");
const incStmt = db.prepare(`
  INSERT INTO usage (user_id, period, count) VALUES (?, ?, 1)
  ON CONFLICT (user_id, period) DO UPDATE SET count = count + 1
`);

function count(userId: string, period: string): number {
  const row = getStmt.get(userId, period) as { count: number } | undefined;
  return row?.count ?? 0;
}

export function remainingFree(userId: string, now = new Date()): number {
  return Math.max(0, FREE_PER_WEEK - count(userId, `w:${isoWeekKey(now)}`));
}

export function remainingPremiumToday(userId: string, now = new Date()): number {
  return Math.max(0, PREMIUM_PER_DAY - count(userId, `d:${dayKey(now)}`));
}

export function globalLimitReached(now = new Date()): boolean {
  return GLOBAL_PER_DAY > 0 && count(GLOBAL_USER, `d:${dayKey(now)}`) >= GLOBAL_PER_DAY;
}

/** Call only after a successful explanation, so failed requests don't use up the quota. */
export function recordUse(userId: string, now = new Date()): void {
  incStmt.run(userId, `w:${isoWeekKey(now)}`);
  incStmt.run(userId, `d:${dayKey(now)}`);
  incStmt.run(GLOBAL_USER, `d:${dayKey(now)}`);
}

/** Removes counters older than ~5 weeks. Run once a day. */
export function pruneOldUsage(now = new Date()): void {
  const cutoff = new Date(now.getTime() - 35 * 86_400_000);
  db.prepare("DELETE FROM usage WHERE period LIKE 'd:%' AND period < ?").run(`d:${dayKey(cutoff)}`);
  db.prepare("DELETE FROM usage WHERE period LIKE 'w:%' AND period < ?").run(`w:${isoWeekKey(cutoff)}`);
}
