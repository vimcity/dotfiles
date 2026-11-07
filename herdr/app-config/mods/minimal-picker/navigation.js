export function revealTarget(sizes, index, height, offset) {
  const tops = [];
  let total = 0;
  for (const size of sizes) {
    tops.push(total);
    total += size;
  }
  const start = tops[index];
  const end = start + sizes[index];
  if (offset !== null && start >= offset && end <= offset + height) return null;
  const desired = offset === null ? start - (height - sizes[index]) / 2
    : start < offset ? start : end - height;
  const maxOffset = Math.max(0, total - height);
  const position = Math.max(0, Math.min(desired, maxOffset));
  const first = tops.findIndex(top => top >= position);
  const row = first < 0 ? sizes.length - 1 : Math.min(first, index);
  return { index: row, offset: Math.min(tops[row], maxOffset) };
}
