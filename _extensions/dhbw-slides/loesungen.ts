// Post-Render-Skript der DHBW-Extension: erzeugt zu jedem Übungsblatt die
// Lösungsfassung. Einbinden in der _quarto.yml des Vorlesungsprojekts:
//
//   project:
//     post-render: _extensions/dermahax/dhbw-slides/loesungen.ts
//
// PDF (dhbw-slides-typst):  ueb-01.typ  →  ueb-01-loesung.pdf  (Typst mit
//                           --input loesung=true), danach wird die .typ gelöscht.
// Notebook (dhbw-slides-ipynb): ueb-01.ipynb → ueb-01-loesung.ipynb mit allen
//                           Zellen; aus ueb-01.ipynb fliegen die Lösungszellen.
// Alle anderen Ausgaben (Folien usw.) bleiben unberührt.

const listFile = Deno.env.get("QUARTO_USE_FILE_FOR_PROJECT_OUTPUT_FILES");
const outputs = (listFile
  ? Deno.readTextFileSync(listFile)
  : Deno.env.get("QUARTO_PROJECT_OUTPUT_FILES") ?? "")
  .split(/\r?\n/)
  .map((s) => s.trim())
  .filter((s) => s.length > 0);

function exists(path: string): boolean {
  try {
    return Deno.statSync(path).isFile;
  } catch {
    return false;
  }
}

// Typst aus der Quarto-Installation finden (Aufruf direkt, ohne Shell)
function typstCommand(): { cmd: string; pre: string[] } {
  const win = Deno.build.os === "windows";
  const exe = win ? "typst.exe" : "typst";
  const bin = Deno.env.get("QUARTO_BIN_PATH");
  const candidates = [
    Deno.env.get("QUARTO_TYPST"),
    bin && `${bin}/tools/${Deno.build.arch}/${exe}`,
    bin && `${bin}/tools/${exe}`,
  ].filter((p): p is string => !!p);
  for (const c of candidates) {
    if (exists(c)) return { cmd: c, pre: [] };
  }
  // Rückfall: quarto typst über die Shell
  return win
    ? { cmd: "cmd", pre: ["/c", "quarto", "typst"] }
    : { cmd: "quarto", pre: ["typst"] };
}

function pdfLoesung(pdf: string) {
  const typ = pdf.replace(/\.pdf$/, ".typ");
  if (!exists(typ)) return;
  if (!Deno.readTextFileSync(typ).includes("dhbw-uebung(")) return;
  const ziel = pdf.replace(/\.pdf$/, "-loesung.pdf");
  const { cmd, pre } = typstCommand();
  const res = new Deno.Command(cmd, {
    args: [...pre, "compile", "--root", ".", "--input", "loesung=true", typ, ziel],
    stdout: "inherit",
    stderr: "inherit",
  }).outputSync();
  if (!res.success) {
    throw new Error(`Lösungsfassung von ${pdf} konnte nicht erzeugt werden (${typ} bleibt liegen).`);
  }
  Deno.removeSync(typ);
  console.log(`Output created: ${ziel}`);
}

// deno-lint-ignore no-explicit-any
function istLoesung(cell: any): boolean {
  const tags = cell?.metadata?.tags;
  return Array.isArray(tags) && tags.includes("loesung");
}

function notebookLoesung(nb: string) {
  const data = JSON.parse(Deno.readTextFileSync(nb));
  if (!Array.isArray(data.cells) || !data.cells.some(istLoesung)) return;
  const ziel = nb.replace(/\.ipynb$/, "-loesung.ipynb");
  Deno.writeTextFileSync(ziel, JSON.stringify(data, null, 1) + "\n");
  // deno-lint-ignore no-explicit-any
  data.cells = data.cells.filter((c: any) => !istLoesung(c));
  Deno.writeTextFileSync(nb, JSON.stringify(data, null, 1) + "\n");
  console.log(`Output created: ${ziel}`);
}

for (const out of outputs) {
  if (out.endsWith("-loesung.pdf") || out.endsWith("-loesung.ipynb")) continue;
  if (out.endsWith(".pdf")) pdfLoesung(out);
  else if (out.endsWith(".ipynb")) notebookLoesung(out);
}
