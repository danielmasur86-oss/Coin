/**
 * Simple per-IP limiter (sliding window, in memory). Stops scripts from hammering the
 * expensive /v1/explain endpoint. Per-user quotas live in quota.ts.
 */
const WINDOW_MS = 10 * 60_000;
export const MAX_PER_WINDOW = Number(process.env.IP_LIMIT_PER_10MIN ?? 30);

const hits = new Map<string, number[]>();

export function allowRequest(ip: string, now = Date.now()): boolean {
  const recent = (hits.get(ip) ?? []).filter((t) => now - t < WINDOW_MS);
  if (recent.length >= MAX_PER_WINDOW) {
    hits.set(ip, recent);
    return false;
  }
  recent.push(now);
  hits.set(ip, recent);
  return true;
}

/** Drop idle entries so the map doesn't grow forever. */
export function sweep(now = Date.now()): void {
  for (const [ip, list] of hits) {
    if (list.every((t) => now - t >= WINDOW_MS)) hits.delete(ip);
  }
}
