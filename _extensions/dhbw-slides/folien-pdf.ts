// Post-Render-Skript der DHBW-Extension: druckt die gerenderten Foliensätze
// zusätzlich als PDF (03-kapitel.html -> 03-kapitel.pdf). Einbinden:
//
//   project:
//     post-render:
//       - _extensions/dermahax/dhbw-slides/loesungen.ts
//       - _extensions/dermahax/dhbw-slides/folien-pdf.ts
//
// Wann entstehen PDFs?
//   quarto render                                  ganzes Projekt -> ja
//   quarto render 03-kapitel.qmd                   eine Datei     -> nein
//   quarto preview / VS Code Strg+Umschalt+K                      -> nein
//   quarto render 03-kapitel.qmd --profile pdf     erzwingen      -> ja
//
// Gedruckt werden nur reveal.js-Ausgaben mit gleichnamiger .qmd; Hilfsdokumente
// aus .md-Dateien bleiben außen vor. Eine Seite pro Fragment-Schritt regelt
// `pdf-separate-fragments` (in der Extension standardmäßig an).
//
// Gedruckt wird mit Chrome oder Edge (headless, über das DevTools-Protokoll,
// damit erst gedruckt wird, wenn reveal.js und KaTeX fertig sind). Der Browser
// wird automatisch gesucht; anderer Pfad über die Umgebungsvariable
// DHBW_PDF_BROWSER.

const renderAll = Deno.env.get("QUARTO_PROJECT_RENDER_ALL") === "1";
const profilPdf = (Deno.env.get("QUARTO_PROFILE") ?? "")
  .split(",")
  .map((s) => s.trim())
  .includes("pdf");
if (!renderAll && !profilPdf) Deno.exit(0);

const listFile = Deno.env.get("QUARTO_USE_FILE_FOR_PROJECT_OUTPUT_FILES");
const outputs = (listFile
  ? Deno.readTextFileSync(listFile)
  : Deno.env.get("QUARTO_PROJECT_OUTPUT_FILES") ?? "")
  .split(/\r?\n/)
  .map((s) => s.trim())
  .filter((s) => s.length > 0);

const win = Deno.build.os === "windows";
const sep = win ? "\\" : "/";

function exists(path: string): boolean {
  try {
    return Deno.statSync(path).isFile;
  } catch {
    return false;
  }
}

const sleep = (ms: number) => new Promise((r) => setTimeout(r, ms));

// ---------------------------------------------------------------------------
// Auswahl und Browser

function istFoliensatz(html: string): boolean {
  if (!html.endsWith(".html")) return false;
  if (!exists(html.replace(/\.html$/, ".qmd"))) return false;
  // reveal.js-Ausgabe erkennen, ohne die ganze ~4-MB-Datei zu lesen
  const f = Deno.openSync(html);
  const buf = new Uint8Array(64 * 1024);
  const n = f.readSync(buf) ?? 0;
  f.close();
  return new TextDecoder().decode(buf.subarray(0, n)).includes("reveal");
}

function findeBrowser(): string | undefined {
  const env = Deno.env.get("DHBW_PDF_BROWSER");
  if (env) return env;
  const pf = Deno.env.get("ProgramFiles") ?? "C:\\Program Files";
  const pf86 = Deno.env.get("ProgramFiles(x86)") ?? "C:\\Program Files (x86)";
  const local = Deno.env.get("LOCALAPPDATA") ?? "";
  const kandidaten = win
    ? [
      `${pf}\\Google\\Chrome\\Application\\chrome.exe`,
      `${pf86}\\Google\\Chrome\\Application\\chrome.exe`,
      `${local}\\Google\\Chrome\\Application\\chrome.exe`,
      `${pf86}\\Microsoft\\Edge\\Application\\msedge.exe`,
      `${pf}\\Microsoft\\Edge\\Application\\msedge.exe`,
    ]
    : Deno.build.os === "darwin"
    ? [
      "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
      "/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge",
    ]
    : [
      "/usr/bin/google-chrome",
      "/usr/bin/chromium",
      "/usr/bin/chromium-browser",
      "/usr/bin/microsoft-edge",
    ];
  return kandidaten.find(exists);
}

function fileUrl(absPath: string): string {
  let p = absPath.replace(/\\/g, "/");
  if (p.startsWith("//?/")) p = p.slice(4); // Windows-Langpfad-Präfix
  if (!p.startsWith("/")) p = "/" + p; // C:/… -> /C:/…
  return "file://" + encodeURI(p).replace(/\?/g, "%3F").replace(/#/g, "%23");
}

// ---------------------------------------------------------------------------
// Minimaler Client für das Chrome-DevTools-Protokoll

class Cdp {
  private id = 0;
  private offen = new Map<number, { ok: (v: any) => void; fehler: (e: Error) => void }>();
  private constructor(private ws: WebSocket) {
    ws.onmessage = (e) => {
      const m = JSON.parse(e.data as string);
      const p = m.id !== undefined ? this.offen.get(m.id) : undefined;
      if (!p) return;
      this.offen.delete(m.id);
      m.error ? p.fehler(new Error(m.error.message)) : p.ok(m.result);
    };
  }
  static verbinden(url: string): Promise<Cdp> {
    return new Promise((ok, fehler) => {
      const ws = new WebSocket(url);
      ws.onopen = () => ok(new Cdp(ws));
      ws.onerror = () => fehler(new Error(`Keine Verbindung zu ${url}`));
    });
  }
  // deno-lint-ignore no-explicit-any
  send(method: string, params: Record<string, unknown> = {}): Promise<any> {
    return new Promise((ok, fehler) => {
      const id = ++this.id;
      this.offen.set(id, { ok, fehler });
      this.ws.send(JSON.stringify({ id, method, params }));
    });
  }
  close() {
    try {
      this.ws.close();
    } catch { /* egal */ }
  }
}

function base64Bytes(b64: string): Uint8Array {
  const bin = atob(b64);
  const out = new Uint8Array(bin.length);
  for (let i = 0; i < bin.length; i++) out[i] = bin.charCodeAt(i);
  return out;
}

// reveal.js im Druckmodus fertig, Schriften geladen, Formeln gesetzt?
const BEREIT = `(() => {
  const R = window.Reveal;
  if (!R || !R.isReady || !R.isReady()) return false;
  if (!document.querySelector('.pdf-page')) return false;
  if (document.fonts && document.fonts.status !== 'loaded') return false;
  return true;
})()`;

async function drucke(page: Cdp, html: string, pdf: string) {
  const url = fileUrl(Deno.realPathSync(html)) + "?print-pdf";
  await page.send("Page.navigate", { url });
  const ende = Date.now() + 60_000;
  for (;;) {
    await sleep(250);
    const r = await page.send("Runtime.evaluate", { expression: BEREIT, returnByValue: true })
      .catch(() => undefined);
    if (r?.result?.value === true) break;
    if (Date.now() > ende) throw new Error("Zeitüberschreitung beim Laden");
  }
  await sleep(1000); // KaTeX-Rendern und letzte Layout-Schritte
  const { data } = await page.send("Page.printToPDF", {
    printBackground: true,
    preferCSSPageSize: true,
    displayHeaderFooter: false,
    marginTop: 0,
    marginBottom: 0,
    marginLeft: 0,
    marginRight: 0,
  });
  Deno.writeFileSync(pdf, base64Bytes(data));
}

// ---------------------------------------------------------------------------

const folien = outputs.filter(istFoliensatz);
if (folien.length === 0) Deno.exit(0);

const browser = findeBrowser();
if (!browser) {
  console.warn(
    "folien-pdf: Kein Chrome/Edge gefunden – PDFs übersprungen. " +
      "Pfad über die Umgebungsvariable DHBW_PDF_BROWSER angeben.",
  );
  Deno.exit(0);
}

// eigenes, temporäres Profil: ein bereits geöffnetes Chrome stört so nicht
const profil = Deno.makeTempDirSync({ prefix: "dhbw-pdf-" });
const prozess = new Deno.Command(browser, {
  args: [
    "--headless=new",
    "--disable-gpu",
    "--no-first-run",
    "--no-default-browser-check",
    "--disable-extensions",
    `--user-data-dir=${profil}`,
    "--remote-debugging-port=0",
    "about:blank",
  ],
  stdout: "null",
  stderr: "null",
}).spawn();

let fehler = 0;
let browserWs: Cdp | undefined;
try {
  // Chrome schreibt Port und Browser-Pfad in die Datei DevToolsActivePort
  let zeilen: string[] = [];
  for (let i = 0; i < 200 && zeilen.length < 2; i++) {
    try {
      zeilen = Deno.readTextFileSync(profil + sep + "DevToolsActivePort")
        .split(/\r?\n/).filter((z) => z);
    } catch { /* noch nicht da */ }
    if (zeilen.length < 2) await sleep(100);
  }
  if (zeilen.length < 2) throw new Error("Browser startet nicht");
  const basis = `ws://127.0.0.1:${zeilen[0]}`;
  browserWs = await Cdp.verbinden(basis + zeilen[1]);
  const { targetId } = await browserWs.send("Target.createTarget", { url: "about:blank" });
  const page = await Cdp.verbinden(`${basis}/devtools/page/${targetId}`);
  await page.send("Page.enable");

  for (const html of folien) {
    const pdf = html.replace(/\.html$/, ".pdf");
    try {
      await drucke(page, html, pdf);
      console.log(`Output created: ${pdf}`);
    } catch (e) {
      const grund = e instanceof Deno.errors.PermissionDenied || String(e).includes("os error 32")
        ? "Datei gesperrt – noch im PDF-Viewer geöffnet?"
        : String((e as Error).message ?? e);
      console.warn(`folien-pdf: ${pdf} nicht erzeugt (${grund})`);
      fehler++;
    }
  }
  page.close();
} catch (e) {
  console.warn(`folien-pdf: abgebrochen (${(e as Error).message}) – die HTML-Folien sind fertig.`);
  fehler = folien.length;
} finally {
  if (browserWs) {
    await browserWs.send("Browser.close").catch(() => undefined);
    browserWs.close();
  }
  const beendet = await Promise.race([prozess.status.then(() => true), sleep(5000).then(() => false)]);
  if (!beendet) {
    try {
      prozess.kill();
    } catch { /* schon weg */ }
  }
  await sleep(300);
  try {
    Deno.removeSync(profil, { recursive: true });
  } catch { /* liegt im Temp-Ordner, egal */ }
}

if (fehler > 0) {
  console.warn(`folien-pdf: ${fehler} PDF(s) fehlen, die HTML-Folien sind aber fertig.`);
}
