import { z } from "zod";

/** Languages a parent can choose. Must match the app's supported locales. */
export const PARENT_LANGUAGES = {
  de: "Deutsch",
  pl: "Polski",
  en: "English",
  tr: "Türkçe",
  uk: "Українська",
  ru: "Русский",
  ar: "العربية",
} as const;
export type ParentLanguage = keyof typeof PARENT_LANGUAGES;

export const BUNDESLAENDER = [
  "BW", "BY", "BE", "BB", "HB", "HH", "HE", "MV",
  "NI", "NW", "RP", "SL", "SN", "ST", "SH", "TH",
] as const;

export const SCHOOL_TYPES = [
  "grundschule", "gymnasium", "realschule", "hauptschule", "gesamtschule", "oberschule",
] as const;

export const SUBJECTS = ["mathe", "deutsch", "englisch", "sachunterricht", "other"] as const;

const ALLOWED_MEDIA = ["image/jpeg", "image/png", "image/webp"] as const;
/** ~5 MB of image bytes once base64-decoded. */
const MAX_BASE64_LENGTH = 7_000_000;

/** Request body the app sends to POST /v1/explain. */
export const ExplainRequest = z.object({
  imageBase64: z.string().min(100).max(MAX_BASE64_LENGTH),
  mediaType: z.enum(ALLOWED_MEDIA),
  /** "explain" = new task, "check" = photo of a finished task to look for mistakes. */
  mode: z.enum(["explain", "check"]),
  parentLanguage: z.enum(Object.keys(PARENT_LANGUAGES) as [ParentLanguage, ...ParentLanguage[]]),
  bundesland: z.enum(BUNDESLAENDER),
  schoolType: z.enum(SCHOOL_TYPES),
  grade: z.number().int().min(1).max(13),
  subject: z.enum(SUBJECTS),
});
export type ExplainRequest = z.infer<typeof ExplainRequest>;

/** Structured answer the model must return. All prose fields are in the parent's language,
 *  except fields ending in `_de`, which are German sentences the parent can say to the child. */
export const Explanation = z.object({
  readable: z.boolean().describe("false if the photo is unreadable or is not a school task"),
  task_original_de: z.string().describe("The task text as written on the sheet (German)"),
  task_translation: z.string().describe("What the task asks, in the parent's language, in plain words"),
  topic: z.string().describe("Topic name in the parent's language, e.g. 'Fractions'"),
  topic_de: z.string().describe("German school term for the topic, e.g. 'Bruchrechnung'"),
  how_to_explain: z.string().describe("Short guidance for the parent on how to explain this to the child"),
  steps: z.array(
    z.object({
      parent_hint: z.string().describe("What the parent should do/know in this step (parent's language)"),
      ask_child_de: z.string().describe("A guiding question in simple German the parent can ask the child"),
      ask_child_translation: z.string().describe("Translation of ask_child_de into the parent's language"),
    }),
  ),
  german_vocabulary: z.array(
    z.object({ de: z.string(), translation: z.string() }),
  ).describe("Key German school words from this task with translations"),
  solution: z.string().describe("Full worked solution for the parent only, using the German school method"),
  check: z.object({
    is_correct: z.boolean().nullable().describe("null in explain mode"),
    feedback: z.string().describe("Where the mistake is and a hint, without simply giving the answer. Empty in explain mode"),
  }),
  confidence: z.enum(["high", "medium", "low"]),
});
export type Explanation = z.infer<typeof Explanation>;
