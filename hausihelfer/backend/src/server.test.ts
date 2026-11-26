import { test } from "node:test";
import assert from "node:assert/strict";
import { z } from "zod";
import { buildServer } from "./server.js";
import {
  FREE_PER_WEEK,
  PREMIUM_PER_DAY,
  isoWeekKey,
  pruneOldUsage,
  recordUse,
  remainingFree,
  remainingPremiumToday,
} from "./quota.js";
import { allowRequest, MAX_PER_WINDOW } from "./ratelimit.js";
import { Explanation } from "./schema.js";
import { db } from "./db.js";

test("isoWeekKey handles year boundaries", () => {
  assert.equal(isoWeekKey(new Date("2026-01-01T12:00:00Z")), "2026-W01");
  assert.equal(isoWeekKey(new Date("2027-01-01T12:00:00Z")), "2026-W53");
  assert.equal(isoWeekKey(new Date("2026-11-26T12:00:00Z")), "2026-W48");
});

test("free quota counts down and resets next week", () => {
  const now = new Date("2026-11-26T12:00:00Z");
  for (let i = 0; i < FREE_PER_WEEK; i++) recordUse("quota-user-1", now);
  assert.equal(remainingFree("quota-user-1", now), 0);
  assert.equal(remainingFree("quota-user-1", new Date("2026-12-03T12:00:00Z")), FREE_PER_WEEK);
});

test("premium fair-use limit is per day", () => {
  const day = new Date("2026-11-26T08:00:00Z");
  recordUse("premium-user-1", day);
  assert.equal(remainingPremiumToday("premium-user-1", day), PREMIUM_PER_DAY - 1);
  assert.equal(remainingPremiumToday("premium-user-1", new Date("2026-11-27T08:00:00Z")), PREMIUM_PER_DAY);
});

test("old counters are pruned", () => {
  recordUse("old-user-1", new Date("2026-01-05T12:00:00Z"));
  pruneOldUsage(new Date("2026-11-26T12:00:00Z"));
  const row = db.prepare("SELECT COUNT(*) AS n FROM usage WHERE user_id = 'old-user-1'").get() as { n: number };
  assert.equal(row.n, 0);
});

test("ip limiter blocks after the limit and frees up after 10 minutes", () => {
  const t = 1_000_000;
  for (let i = 0; i < MAX_PER_WINDOW; i++) assert.ok(allowRequest("1.2.3.4", t));
  assert.equal(allowRequest("1.2.3.4", t), false);
  assert.ok(allowRequest("1.2.3.4", t + 10 * 60_000 + 1));
});

test("rejects requests without a valid user id", async () => {
  const app = buildServer();
  const res = await app.inject({ method: "POST", url: "/v1/explain", payload: {} });
  assert.equal(res.statusCode, 400);
  assert.equal(res.json().error, "bad_user_id");
});

test("rejects invalid bodies before calling the model", async () => {
  const app = buildServer();
  const res = await app.inject({
    method: "POST",
    url: "/v1/explain",
    headers: { "x-user-id": "test-user-12345" },
    payload: { mode: "explain", parentLanguage: "xx" },
  });
  assert.equal(res.statusCode, 400);
  assert.equal(res.json().error, "bad_request");
});

test("returns 402 when the free tasks are used up", async () => {
  for (let i = 0; i < FREE_PER_WEEK; i++) recordUse("used-up-user-1");
  const app = buildServer();
  const res = await app.inject({
    method: "POST",
    url: "/v1/explain",
    headers: { "x-user-id": "used-up-user-1" },
    payload: {
      imageBase64: "A".repeat(200),
      mediaType: "image/jpeg",
      mode: "explain",
      parentLanguage: "pl",
      bundesland: "NW",
      schoolType: "grundschule",
      grade: 3,
      subject: "mathe",
    },
  });
  assert.equal(res.statusCode, 402);
  assert.equal(res.json().error, "free_limit_reached");
});

test("quota endpoint reports the free tier", async () => {
  const app = buildServer();
  const res = await app.inject({ method: "GET", url: "/v1/quota", headers: { "x-user-id": "fresh-user-123" } });
  assert.equal(res.statusCode, 200);
  assert.deepEqual(res.json(), { premium: false, remainingFree: FREE_PER_WEEK, freePerWeek: FREE_PER_WEEK });
});

test("feedback is stored", async () => {
  const app = buildServer();
  const res = await app.inject({
    method: "POST",
    url: "/v1/feedback",
    payload: { language: "pl", subject: "mathe", topicDe: "Division", taskDe: "456 : 3", comment: "Zły wynik" },
  });
  assert.equal(res.statusCode, 200);
  const row = db.prepare("SELECT comment FROM reports ORDER BY id DESC LIMIT 1").get() as { comment: string };
  assert.equal(row.comment, "Zły wynik");
});

test("legal pages are served and escape configured values", async () => {
  process.env.LEGAL_NAME = "Max <b>Muster</b>";
  const app = buildServer();
  for (const path of ["/impressum", "/datenschutz", "/agb"]) {
    const res = await app.inject({ method: "GET", url: path });
    assert.equal(res.statusCode, 200);
    assert.match(res.headers["content-type"] as string, /text\/html/);
  }
  const imp = await app.inject({ method: "GET", url: "/impressum" });
  assert.ok(imp.body.includes("Max &#60;b&#62;Muster&#60;/b&#62;"));
  assert.ok(imp.body.includes("[BITTE AUSFÜLLEN]")); // address not configured
  delete process.env.LEGAL_NAME;
});

test("explanation schema converts to JSON schema", () => {
  const schema = z.toJSONSchema(Explanation) as { required: string[] };
  assert.ok(schema.required.includes("steps"));
  assert.ok(schema.required.includes("solution"));
});
