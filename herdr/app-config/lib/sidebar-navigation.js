export function navigateSidebar(direction, spaces, run) {
  const items = spaces.flatMap(space => (space.tabs ?? []).map(tab => ({ space, tab })));
  if (!items.length) return;
  const current = items.findIndex(({ space, tab }) => space.active && tab.active);
  const index = current < 0 ? (direction > 0 ? 0 : items.length - 1)
    : (current + direction + items.length) % items.length;
  const next = items[index];
  if (!next.space.active) run("space.select", { id: next.space.id });
  if (!next.tab.active) run("tab.select", { id: next.tab.id });
}
