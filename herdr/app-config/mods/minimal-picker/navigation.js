export function rowLayout(sizes) {
  const tops = [];
  let total = 0;
  for (const size of sizes) {
    tops.push(total);
    total += size;
  }
  return { tops, total };
}

export function revealOffset(sizes, index, height, offset) {
  const { tops, total } = rowLayout(sizes);
  const start = tops[index];
  const end = start + sizes[index];
  let next = offset ?? Math.max(0, start - (height - sizes[index]) / 2);
  if (start < next) next = start;
  if (end > next + height) next = end - height;
  return Math.max(0, Math.min(next, Math.max(0, total - height)));
}

export function pageIndex(sizes, selectable, current, height, direction) {
  const { tops } = rowLayout(sizes);
  const target = tops[selectable[current]] + direction * height;
  let next = current;
  if (direction > 0) while (next < selectable.length - 1 && tops[selectable[next]] < target) next++;
  else while (next > 0 && tops[selectable[next]] > target) next--;
  return next;
}
