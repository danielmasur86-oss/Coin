import Anthropic from "@anthropic-ai/sdk";
import { betaZodOutputFormat } from "@anthropic-ai/sdk/helpers/beta/zod";
import { Explanation, type ExplainRequest } from "./schema.js";
import { SYSTEM_PROMPT, buildUserText } from "./prompt.js";

const MODEL = process.env.CLAUDE_MODEL ?? "claude-opus-5-5";
const EFFORT = (process.env.CLAUDE_EFFORT ?? "medium") as "low" | "medium" | "high";

const client = new Anthropic();

export class ExplainError extends Error {
  constructor(
    public readonly code: "refused" | "unparseable" | "upstream_busy" | "upstream_error",
    message: string,
  ) {
    super(message);
  }
}

export async function explainHomework(req: ExplainRequest): Promise<Explanation> {
  let response;
  try {
    response = await client.beta.messages.parse({
      model: MODEL,
      max_tokens: 16000,
      // If the main model declines, the API retries on a fallback model in the same call.
      betas: ["server-side-fallback-2026-07-01"],
      fallbacks: "default",
      output_config: { effort: EFFORT, format: betaZodOutputFormat(Explanation) },
      system: [{ type: "text", text: SYSTEM_PROMPT, cache_control: { type: "ephemeral" } }],
      messages: [
        {
          role: "user",
          content: [
            { type: "image", source: { type: "base64", media_type: req.mediaType, data: req.imageBase64 } },
            { type: "text", text: buildUserText(req) },
          ],
        },
      ],
    });
  } catch (error) {
    if (error instanceof Anthropic.RateLimitError || error instanceof Anthropic.InternalServerError) {
      throw new ExplainError("upstream_busy", error.message);
    }
    if (error instanceof Anthropic.APIError) {
      throw new ExplainError("upstream_error", `${error.status}: ${error.message}`);
    }
    throw error;
  }

  if (response.stop_reason === "refusal") {
    throw new ExplainError("refused", response.stop_details?.category ?? "refusal");
  }
  if (!response.parsed_output) {
    throw new ExplainError("unparseable", `stop_reason=${response.stop_reason}`);
  }
  return response.parsed_output;
}
