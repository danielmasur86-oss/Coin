import Fastify from "fastify";
import { z } from "zod";
import { ExplainRequest, PARENT_LANGUAGES, SUBJECTS, type ParentLanguage } from "./schema.js";
import { explainHomework, ExplainError } from "./explain.js";
import {
  FREE_PER_WEEK,
  globalLimitReached,
  pruneOldUsage,
  recordUse,
  remainingFree,
  remainingPremiumToday,
} from "./quota.js";
import { isPremium } from "./premium.js";
import { allowRequest, sweep } from "./ratelimit.js";
import { db } from "./db.js";
import { agbHtml, datenschutzHtml, impressumHtml } from "./legal.js";

const USER_ID_RE = /^[A-Za-z0-9_-]{8,64}$/;

const FeedbackRequest = z.object({
  language: z.enum(Object.keys(PARENT_LANGUAGES) as [ParentLanguage, ...ParentLanguage[]]),
  subject: z.enum(SUBJECTS),
  topicDe: z.string().max(200),
  taskDe: z.string().max(4000),
  comment: z.string().max(2000),
});

export function buildServer() {
  // bodyLimit covers a ~5 MB photo after base64 encoding.
  // trustProxy: the server runs behind a hosting load balancer, so read the client IP from it.
  const app = Fastify({ logger: true, bodyLimit: 8 * 1024 * 1024, trustProxy: true });

  const userIdOf = (headers: Record<string, unknown>) => {
    const id = headers["x-user-id"];
    return typeof id === "string" && USER_ID_RE.test(id) ? id : null;
  };

  app.get("/health", async () => ({ ok: true }));

  // Legal pages (German law requires them to be reachable from the app).
  app.get("/impressum", async (_req, reply) => reply.type("text/html").send(impressumHtml()));
  app.get("/datenschutz", async (_req, reply) => reply.type("text/html").send(datenschutzHtml()));
  app.get("/agb", async (_req, reply) => reply.type("text/html").send(agbHtml()));

  app.get("/v1/quota", async (request, reply) => {
    const userId = userIdOf(request.headers);
    if (!userId) return reply.code(400).send({ error: "bad_user_id" });
    const premium = await isPremium(userId);
    return { premium, remainingFree: premium ? null : remainingFree(userId), freePerWeek: FREE_PER_WEEK };
  });

  app.post("/v1/explain", async (request, reply) => {
    if (!allowRequest(request.ip)) return reply.code(429).send({ error: "too_many_requests" });

    const userId = userIdOf(request.headers);
    if (!userId) return reply.code(400).send({ error: "bad_user_id" });

    const parsed = ExplainRequest.safeParse(request.body);
    if (!parsed.success) {
      return reply.code(400).send({ error: "bad_request", issues: parsed.error.issues.map((i) => i.path.join(".")) });
    }

    if (globalLimitReached()) return reply.code(503).send({ error: "busy" });

    const premium = await isPremium(userId);
    if (premium && remainingPremiumToday(userId) <= 0) {
      return reply.code(429).send({ error: "daily_limit_reached" });
    }
    if (!premium && remainingFree(userId) <= 0) {
      return reply.code(402).send({ error: "free_limit_reached" });
    }

    try {
      const explanation = await explainHomework(parsed.data);
      // Unreadable photos don't count, so a bad photo never costs the parent a free task.
      if (explanation.readable) recordUse(userId);
      return { explanation, remainingFree: premium ? null : remainingFree(userId) };
    } catch (error) {
      if (error instanceof ExplainError) {
        request.log.warn({ code: error.code }, error.message);
        const status = error.code === "upstream_busy" ? 503 : error.code === "refused" ? 422 : 502;
        return reply.code(status).send({ error: error.code });
      }
      throw error;
    }
  });

  // "Report a mistake" from the result screen. Read them with: sqlite3 data/hausihelfer.db "select * from reports"
  app.post("/v1/feedback", async (request, reply) => {
    if (!allowRequest(request.ip)) return reply.code(429).send({ error: "too_many_requests" });
    const parsed = FeedbackRequest.safeParse(request.body);
    if (!parsed.success) return reply.code(400).send({ error: "bad_request" });
    const f = parsed.data;
    db.prepare(
      "INSERT INTO reports (created_at, language, subject, topic_de, task_de, comment) VALUES (?, ?, ?, ?, ?, ?)",
    ).run(new Date().toISOString(), f.language, f.subject, f.topicDe, f.taskDe, f.comment);
    return { ok: true };
  });

  return app;
}

if (import.meta.url === `file://${process.argv[1]}`) {
  const app = buildServer();
  const port = Number(process.env.PORT ?? 8080);
  pruneOldUsage();
  setInterval(() => {
    pruneOldUsage();
    sweep();
  }, 60 * 60_000).unref();
  app.listen({ port, host: "0.0.0.0" }).catch((err) => {
    app.log.error(err);
    process.exit(1);
  });
}
