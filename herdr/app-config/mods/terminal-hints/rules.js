export default [
  { name: "url", pattern: "https?://[^\\s<>\\\"'`]+" },
  { name: "email", pattern: "\\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,}\\b", flags: "i" },
  { name: "uuid", pattern: "\\b[0-9a-f]{8}(?:-[0-9a-f]{4}){3}-[0-9a-f]{12}\\b", flags: "i" },
  { name: "account", pattern: "\\b[0-9]{12}\\b" },
  { name: "path", pattern: "(?:~|\\.{1,2})?/[^\\s<>\\\"'`|,;]+" },
];
