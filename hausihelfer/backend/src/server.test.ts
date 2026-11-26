import { test } from "node:test";
import assert from "node:assert/strict";
import { buildServer } from "./server.js";
import { isoWeekKey, remainingFree, consumeFree, FREE_PER_WEEK } from "./quota.js";
import { Explanation } from "./schema.js";
import { z } from "zod";

test("isoWeekKey handles year boundaries", () => {
  assert.equal(isoWeekKey(new Date("2026-01-01T12:00:00Z")), "2026-W01");
  assert.equal(isoWeekKey(new Date("2027-01-01T12:00:00Z")), "2026-W53");
  assert.equal(isoWeekKey(new Date("2026-11-26T12:00:00Z")), "2026-W48");
});

test("free quota counts down and resets next week", () => {
  const now = new Date("2026-11-26T12:00:00Z");
  for (let i = 0; i < FREE_PER_WEEK; i++) consumeFree("quota-user-1", now);
  assert.equal(remainingFree("quota-user-1", now), 0);
  assert.equal(remainingFree("quota-user-1", new Date("2026-12-03T12:00:00Z")), FREE_PER_WEEK);
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

test("quota endpoint reports the free tier", async () => {
  const app = buildServer();
  const res = await app.inject({ method: "GET", url: "/v1/quota", headers: { "x-user-id": "fresh-user-123" } });
  assert.equal(res.statusCode, 200);
  assert.deepEqual(res.json(), { premium: false, remainingFree: FREE_PER_WEEK, freePerWeek: FREE_PER_WEEK });
});

test("explanation schema converts to JSON schema", () => {
  const schema = z.toJSONSchema(Explanation) as { required: string[] };
  assert.ok(schema.required.includes("steps"));
  assert.ok(schema.required.includes("solution"));
});
