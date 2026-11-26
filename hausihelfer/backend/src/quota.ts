/**
 * Free-tier limit: FREE_PER_WEEK explanations per user per ISO week.
 *
 * In-memory store: fine for one server instance during the test phase. Before launch,
 * replace `store` with Redis or a database so the count survives restarts and scaling.
 */
export const FREE_PER_WEEK = Number(process.env.FREE_PER_WEEK ?? 3);

const store = new Map<string, number>();

export function isoWeekKey(date: Date): string {
  const d = new Date(Date.UTC(date.getUTCFullYear(), date.getUTCMonth(), date.getUTCDate()));
  const day = d.getUTCDay() || 7;
  d.setUTCDate(d.getUTCDate() + 4 - day);
  const yearStart = new Date(Date.UTC(d.getUTCFullYear(), 0, 1));
  const week = Math.ceil(((d.getTime() - yearStart.getTime()) / 86_400_000 + 1) / 7);
  return `${d.getUTCFullYear()}-W${String(week).padStart(2, "0")}`;
}

function key(userId: string, now: Date) {
  return `${userId}:${isoWeekKey(now)}`;
}

export function remainingFree(userId: string, now = new Date()): number {
  return Math.max(0, FREE_PER_WEEK - (store.get(key(userId, now)) ?? 0));
}

/** Call only after a successful explanation, so failed requests don't use up the quota. */
export function consumeFree(userId: string, now = new Date()): void {
  const k = key(userId, now);
  store.set(k, (store.get(k) ?? 0) + 1);
}
