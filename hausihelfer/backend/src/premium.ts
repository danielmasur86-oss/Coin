/**
 * Checks whether a user has an active "premium" entitlement in RevenueCat.
 * RevenueCat handles App Store + Google Play subscriptions; the app logs in with the same
 * user id it sends to this backend.
 */
const RC_SECRET = process.env.REVENUECAT_SECRET_KEY;
const ENTITLEMENT = process.env.REVENUECAT_ENTITLEMENT ?? "premium";
const CACHE_MS = 5 * 60_000;

const cache = new Map<string, { premium: boolean; at: number }>();

export async function isPremium(userId: string): Promise<boolean> {
  if (!RC_SECRET) return false; // not configured yet: everyone is on the free tier

  const hit = cache.get(userId);
  if (hit && Date.now() - hit.at < CACHE_MS) return hit.premium;

  const res = await fetch(
    `https://api.revenuecat.com/v1/subscribers/${encodeURIComponent(userId)}`,
    { headers: { Authorization: `Bearer ${RC_SECRET}` } },
  );
  if (!res.ok) return hit?.premium ?? false;

  const body = (await res.json()) as {
    subscriber?: { entitlements?: Record<string, { expires_date: string | null }> };
  };
  const ent = body.subscriber?.entitlements?.[ENTITLEMENT];
  const premium = !!ent && (ent.expires_date === null || new Date(ent.expires_date) > new Date());
  cache.set(userId, { premium, at: Date.now() });
  return premium;
}
