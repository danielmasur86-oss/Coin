/**
 * Impressum, Datenschutzerklärung and AGB pages in German, filled from environment variables.
 *
 * IMPORTANT: these are starting templates, not legal advice. Have them checked by a
 * German lawyer or a generator service (e.g. eRecht24, IT-Recht Kanzlei) before launch.
 */
const MISSING = "[BITTE AUSFÜLLEN]";
const env = (k: string) => escapeHtml(process.env[k]?.trim() || MISSING);

function escapeHtml(s: string): string {
  return s.replace(/[&<>"']/g, (c) => `&#${c.charCodeAt(0)};`);
}

function page(title: string, body: string): string {
  return `<!doctype html>
<html lang="de"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>${title} – HausiHelfer</title>
<style>
  :root { color-scheme: light dark; }
  body { font-family: system-ui, sans-serif; max-width: 720px; margin: 0 auto; padding: 24px 16px; line-height: 1.55; }
  h1 { font-size: 1.6rem; } h2 { font-size: 1.15rem; margin-top: 1.6em; }
  nav a { margin-right: 12px; }
</style></head>
<body>
<nav><a href="/impressum">Impressum</a><a href="/datenschutz">Datenschutz</a><a href="/agb">AGB</a></nav>
<h1>${title}</h1>
${body}
</body></html>`;
}

export function impressumHtml(): string {
  return page("Impressum", `
<h2>Angaben gemäß § 5 DDG</h2>
<p>${env("LEGAL_NAME")}<br>${env("LEGAL_ADDRESS")}</p>
<h2>Kontakt</h2>
<p>E-Mail: ${env("LEGAL_EMAIL")}<br>Telefon: ${env("LEGAL_PHONE")}</p>
${process.env.LEGAL_VAT_ID ? `<h2>Umsatzsteuer-ID</h2><p>${env("LEGAL_VAT_ID")}</p>` : ""}
<h2>Verantwortlich für den Inhalt</h2>
<p>${env("LEGAL_NAME")}, Anschrift wie oben.</p>
<h2>Verbraucherstreitbeilegung</h2>
<p>Wir sind nicht bereit oder verpflichtet, an Streitbeilegungsverfahren vor einer
Verbraucherschlichtungsstelle teilzunehmen.</p>`);
}

export function datenschutzHtml(): string {
  return page("Datenschutzerklärung", `
<h2>1. Verantwortlicher</h2>
<p>${env("LEGAL_NAME")}, ${env("LEGAL_ADDRESS")}, E-Mail: ${env("LEGAL_EMAIL")}</p>

<h2>2. Welche Daten wir verarbeiten</h2>
<p>Die App benötigt kein Benutzerkonto. Wir verarbeiten:</p>
<ul>
  <li><b>Fotos von Hausaufgaben</b>, die Sie selbst auswählen, zusammen mit den Angaben
  Sprache, Bundesland, Schulform, Klasse und Fach. Das Foto wird nur zur Erstellung der
  Erklärung verwendet und auf unseren Servern <b>nicht gespeichert</b>.</li>
  <li><b>Eine zufällige Geräte-ID</b> (ohne Bezug zu Ihrer Person), um die Anzahl kostenloser
  Aufgaben zu zählen und Käufe zuzuordnen. Gespeichert werden nur Zähler, maximal 5 Wochen.</li>
  <li><b>Fehlermeldungen</b>, die Sie freiwillig senden (Aufgabentext und Ihr Kommentar).</li>
</ul>
<p>Ihr Verlauf und Ihre Einstellungen werden nur lokal auf Ihrem Gerät gespeichert.
Bitte fotografieren Sie keine Namen oder andere persönliche Daten Ihres Kindes.</p>

<h2>3. Zweck und Rechtsgrundlage</h2>
<p>Bereitstellung der App und Erfüllung des Nutzungsvertrags (Art. 6 Abs. 1 lit. b DSGVO);
Schutz vor Missbrauch (Art. 6 Abs. 1 lit. f DSGVO).</p>

<h2>4. Empfänger</h2>
<ul>
  <li><b>Anthropic PBC</b> (USA) erstellt die Erklärungen mit künstlicher Intelligenz.
  Die Übermittlung erfolgt auf Grundlage eines Auftragsverarbeitungsvertrags und der
  EU-Standardvertragsklauseln. Daten aus der API werden nicht zum Training verwendet.</li>
  <li><b>RevenueCat Inc.</b> (USA) verwaltet Abonnements (Geräte-ID und Kaufstatus).</li>
  <li><b>Apple</b> bzw. <b>Google</b> wickeln Zahlungen ab; es gelten deren Datenschutzbestimmungen.</li>
  <li>Unser Server-Hoster: ${env("LEGAL_HOSTER")} (Server in der EU).</li>
</ul>

<h2>5. Ihre Rechte</h2>
<p>Sie haben das Recht auf Auskunft, Berichtigung, Löschung, Einschränkung der Verarbeitung,
Datenübertragbarkeit und Widerspruch sowie das Recht auf Beschwerde bei einer
Datenschutz-Aufsichtsbehörde. Lokale Daten können Sie in der App unter
„Einstellungen → Meine Daten löschen“ jederzeit löschen.</p>

<h2>6. Künstliche Intelligenz</h2>
<p>Die Erklärungen werden automatisch von einer KI erstellt und können Fehler enthalten.</p>`);
}

export function agbHtml(): string {
  return page("Allgemeine Geschäftsbedingungen", `
<h2>1. Geltungsbereich</h2>
<p>Diese Bedingungen gelten für die Nutzung der App „HausiHelfer“ von ${env("LEGAL_NAME")}.
Die App richtet sich an Erwachsene (Eltern und Erziehungsberechtigte).</p>

<h2>2. Leistung</h2>
<p>Die App erklärt fotografierte Hausaufgaben mithilfe künstlicher Intelligenz. Die
Erklärungen sind eine Lernhilfe und ersetzen keinen Unterricht. Für die Richtigkeit
der Inhalte wird keine Gewähr übernommen.</p>

<h2>3. Kostenlose Nutzung und Premium</h2>
<p>Kostenlos sind ${process.env.FREE_PER_WEEK ?? 3} Aufgaben pro Woche. Premium ist ein Abonnement,
das über den App Store (Apple) oder Google Play abgeschlossen und abgerechnet wird.
Es verlängert sich automatisch, sofern es nicht spätestens 24 Stunden vor Ablauf in den
Kontoeinstellungen des jeweiligen Stores gekündigt wird. Zum Schutz vor Missbrauch gilt
im Premium eine faire Nutzungsgrenze von ${process.env.PREMIUM_PER_DAY ?? 25} Aufgaben pro Tag.</p>

<h2>4. Widerrufsrecht</h2>
<p>Für Käufe gelten die Widerrufs- und Erstattungsregeln von Apple bzw. Google.</p>

<h2>5. Pflichten der Nutzer</h2>
<p>Bitte laden Sie nur Fotos von Schulaufgaben hoch und keine personenbezogenen Daten Dritter.</p>

<h2>6. Haftung</h2>
<p>Wir haften unbeschränkt bei Vorsatz und grober Fahrlässigkeit sowie bei Verletzung von
Leben, Körper oder Gesundheit. Im Übrigen ist die Haftung auf vorhersehbare, typische
Schäden begrenzt.</p>

<h2>7. Schlussbestimmungen</h2>
<p>Es gilt deutsches Recht. Zwingende Verbraucherschutzvorschriften bleiben unberührt.</p>`);
}
