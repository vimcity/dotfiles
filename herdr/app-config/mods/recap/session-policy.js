export const clean = (s) => (s ?? "").replace(/^[^\p{L}\p{N}]+/u, "").trim();

// An agent on another machine (`ax42/t1`) says which.
export const machineOf = (address) => (address.includes("/") ? address.split("/")[0] : null);

// Branches that are a repo's own default, not work of an agent's.
export const DEFAULT_BRANCHES = new Set(["main", "master", "trunk", "develop"]);

// A ticket's key in a title, as herdr-recap finds one in a branch.
const TICKET = /(?:^|[^a-z0-9])([a-z][a-z0-9]{1,9})-([1-9][0-9]{0,5})(?=[^a-z0-9]|$)/gi;
const NOT_TICKETS = new Set(("phase step part pr v version release issue fix bug test try attempt wave stage sprint " +
  "week day round batch task milestone iteration option plan draft rev").split(" "));
export function ticketKey(s) {
  for (const m of (s ?? "").matchAll(TICKET)) {
    if (!NOT_TICKETS.has(m[1].toLowerCase())) return `${m[1].toUpperCase()}-${m[2]}`;
  }
  return null;
}

