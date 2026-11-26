import Fastify from "fastify";
import { ExplainRequest } from "./schema.js";
import { explainHomework, ExplainError } from "./explain.js";
import { consumeFree, remainingFree, FREE_PER_WEEK } from "./quota.js";
import { isPremium } from "./premium.js";

const USER_ID_RE = /^[A-Za-z0-9_-]{8,64}$/;

export function buildServer() {
  // bodyLimit covers a ~5 MB photo after base64 encoding.
  const app = Fastify({ logger: true, bodyLimit: 8 * 1024 * 1024 });

  app.get("/health", async () => ({ ok: true }));

  app.get("/v1/quota", async (request, reply) => {
    const userId = request.headers["x-user-id"];
    if (typeof userId !== "string" || !USER_ID_RE.test(userId)) {
      return reply.code(400).send({ error: "bad_user_id" });
    }
    const premium = await isPremium(userId);
    return { premium, remainingFree: premium ? null : remainingFree(userId), freePerWeek: FREE_PER_WEEK };
  });

  app.post("/v1/explain", async (request, reply) => {
    const userId = request.headers["x-user-id"];
    if (typeof userId !== "string" || !USER_ID_RE.test(userId)) {
      return reply.code(400).send({ error: "bad_user_id" });
    }
    const parsed = ExplainRequest.safeParse(request.body);
    if (!parsed.success) {
      return reply.code(400).send({ error: "bad_request", issues: parsed.error.issues.map((i) => i.path.join(".")) });
    }

    const premium = await isPremium(userId);
    if (!premium && remainingFree(userId) <= 0) {
      return reply.code(402).send({ error: "free_limit_reached" });
    }

    try {
      const explanation = await explainHomework(parsed.data);
      if (!premium && explanation.readable) consumeFree(userId);
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

  return app;
}

if (import.meta.url === `file://${process.argv[1]}`) {
  const app = buildServer();
  const port = Number(process.env.PORT ?? 8080);
  app.listen({ port, host: "0.0.0.0" }).catch((err) => {
    app.log.error(err);
    process.exit(1);
  });
}
