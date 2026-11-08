import { div } from "gpui-kit";
import { h_flex } from "gpui-base";

const LANG = { ts: "js", tsx: "js", mts: "js", cts: "js", jsx: "js", mjs: "js", cjs: "js", py: "py", rs: "rs", go: "go", toml: "toml", jsonc: "json", yml: "yaml", sh: "sh", bash: "sh", zsh: "sh", h: "c", cxx: "cpp", cc: "cpp", hpp: "cpp", md: "markdown" };
const KEYWORDS = {
  js: new Set("async await break case catch class const continue debugger default delete do else export extends finally for from function if import in instanceof let new of return static super switch this throw try typeof var void while with yield true false null undefined".split(" ")),
  py: new Set("and as assert async await break class continue def del elif else except finally for from global if import in is lambda nonlocal not or pass raise return try while with yield True False None self".split(" ")),
  rs: new Set("as async await break const continue crate dyn else enum extern false fn for if impl in let loop match mod move mut pub ref return self Self static struct super trait true type unsafe use where while".split(" ")),
  go: new Set("break case chan const continue default defer else fallthrough for func go goto if import interface map package range return select struct switch type var true false nil".split(" ")),
  java: new Set("abstract assert boolean break byte case catch char class const continue default do double else enum extends final finally float for if implements import instanceof int interface long native new package private protected public return short static strictfp super switch synchronized this throw throws transient try void volatile while true false null record sealed permits var yield".split(" ")),
  json: new Set("true false null".split(" ")),
  toml: new Set("true false".split(" ")),
  yaml: new Set("true false null yes no on off".split(" ")),
  sh: new Set("if then else elif fi for while in do done case esac function export local readonly return exit set source".split(" ")),
};

export function languageFor(path) {
  const name = path?.split("/").pop()?.toLowerCase();
  if ([".bashrc", ".zshrc", ".profile", "makefile"].includes(name)) return name === "makefile" ? "make" : "sh";
  const ext = name?.split(".").pop();
  const language = LANG[ext] ?? ext;
  return Object.hasOwn(KEYWORDS, language) || ["c", "cpp", "java", "html", "css", "sql", "xml", "php", "lua", "make"].includes(language)
    ? language
    : "plain";
}

export function codeSegments(text, language, t) {
  if (!language || language === "plain" || language === "markdown") return [{ text, color: t.foreground }];
  const hashComments = ["py", "toml", "yaml", "sh"].includes(language);
  const comment = hashComments ? "#.*" : "(?:\\/\\/.*|\\/\\*.*?\\*\\/)";
  const pattern = new RegExp(`(?:\\"(?:\\\\.|[^\\"\\\\])*\\"|'(?:\\\\.|[^'\\\\])*'|\\x60(?:\\\\.|[^\\x60\\\\])*\\x60|${comment}|<\\/?[A-Za-z][^>]*>|\\b\\d+(?:\\.\\d+)?\\b|\\b[A-Za-z_$][\\w$]*\\b)`, "g");
  const keywords = KEYWORDS[language] ?? KEYWORDS.js;
  const out = [];
  let cursor = 0, match;
  while ((match = pattern.exec(text))) {
    if (match.index > cursor) out.push({ text: text.slice(cursor, match.index), color: t.foreground });
    const token = match[0];
    const color = token.startsWith("//") || token.startsWith("#") || token.startsWith("/*") ? t.dim
      : token.startsWith("\"") || token.startsWith("'") || token.startsWith("`") ? t.ansi2
      : token.startsWith("<") ? t.ansi5
      : /^\d/.test(token) ? t.ansi1
      : keywords.has(token) ? t.ansi5
      : /^[A-Z]/.test(token) ? t.ansi3
      : text[pattern.lastIndex] === "(" ? t.ansi4
      : t.foreground;
    out.push({ text: token, color });
    cursor = pattern.lastIndex;
  }
  if (cursor < text.length) out.push({ text: text.slice(cursor), color: t.foreground });
  return out;
}

export function codeText(text, language, t) {
  return h_flex().flex_1().min_w(0).children(codeSegments(text, language, t).map(part =>
    div().flex_none().text_color(part.color).child(part.text)));
}

