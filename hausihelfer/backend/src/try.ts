/**
 * Try the AI on a real photo without the app:
 *   npm run try -- zadanie.jpg pl mathe 3
 * (photo, parent language, subject, grade). Needs ANTHROPIC_API_KEY. Each run costs a few cents.
 */
import { readFileSync } from "node:fs";
import { extname } from "node:path";
import { explainHomework } from "./explain.js";
import { ExplainRequest } from "./schema.js";

const [file, parentLanguage = "pl", subject = "mathe", grade = "3", mode = "explain"] = process.argv.slice(2);
if (!file) {
  console.error("Usage: npm run try -- <photo.jpg> [language] [subject] [grade] [explain|check]");
  process.exit(1);
}

const ext = extname(file).toLowerCase();
const mediaType = ext === ".png" ? "image/png" : ext === ".webp" ? "image/webp" : "image/jpeg";

const req = ExplainRequest.parse({
  imageBase64: readFileSync(file).toString("base64"),
  mediaType,
  mode,
  parentLanguage,
  bundesland: "NW",
  schoolType: Number(grade) <= 4 ? "grundschule" : "gymnasium",
  grade: Number(grade),
  subject,
});

const started = Date.now();
const result = await explainHomework(req);
console.log(JSON.stringify(result, null, 2));
console.error(`\n(${((Date.now() - started) / 1000).toFixed(1)} s)`);
