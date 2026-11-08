export const SIDEBAR_HEIGHT = { duration: 160, easing: "ease-out" };
export const SIDEBAR_FADE = { duration: 110, easing: "ease-out" };

function retainExits(current, previous, entries) {
  const order = [...current];
  previous.forEach((id, index) => {
    if (entries.get(id)?.phase === "exit" && !order.includes(id)) order.splice(Math.min(index, order.length), 0, id);
  });
  return order;
}

function markExit(entry, exits, group, row = null) {
  if (entry.phase === "exit") return;
  entry.phase = "exit";
  entry.epoch++;
  exits.push({ group, row, epoch: entry.epoch });
}

export class SidebarPresence {
  constructor() {
    this.groups = new Map();
    this.order = [];
    this.ready = false;
  }

  sync(current, cx) {
    const entering = [];
    const exiting = [];
    const wanted = new Set(current.map(group => group.id));
    for (const model of current) {
      let group = this.groups.get(model.id);
      if (!group) {
        group = { id: model.id, value: model.value, rows: new Map(), rowOrder: [], phase: this.ready ? "enter" : "open", epoch: 0 };
        this.groups.set(group.id, group);
        if (this.ready) entering.push({ entry: group, epoch: group.epoch });
      } else if (group.phase === "exit") {
        group.phase = "open";
        group.epoch++;
      }
      group.value = model.value;
      const rowIds = new Set(model.rows.map(row => row.id));
      for (const modelRow of model.rows) {
        let row = group.rows.get(modelRow.id);
        if (!row) {
          row = { id: modelRow.id, value: modelRow.value, phase: this.ready ? "enter" : "open", epoch: 0 };
          group.rows.set(row.id, row);
          if (this.ready) entering.push({ entry: row, epoch: row.epoch });
        } else if (row.phase === "exit") {
          row.phase = "open";
          row.epoch++;
        }
        row.value = modelRow.value;
      }
      for (const row of group.rows.values()) {
        if (!rowIds.has(row.id)) markExit(row, exiting, group, row);
      }
      group.rowOrder = retainExits(model.rows.map(row => row.id), group.rowOrder, group.rows);
    }
    for (const group of this.groups.values()) {
      if (wanted.has(group.id)) continue;
      for (const row of group.rows.values()) markExit(row, exiting, group, row);
      markExit(group, exiting, group);
    }
    this.order = retainExits(current.map(group => group.id), this.order, this.groups);
    this.ready = true;
    if (entering.length) cx.timer.after(16, cx => {
      let changed = false;
      for (const { entry, epoch } of entering) {
        if (entry.phase !== "enter" || entry.epoch !== epoch) continue;
        entry.phase = "open";
        changed = true;
      }
      if (changed) cx.notify();
    });
    if (exiting.length) cx.timer.after(180, cx => {
      let changed = false;
      for (const { group, row, epoch } of exiting) {
        const entry = row ?? group;
        if (this.groups.get(group.id) !== group || entry.phase !== "exit" || entry.epoch !== epoch) continue;
        if (row) {
          group.rows.delete(row.id);
          group.rowOrder = group.rowOrder.filter(id => id !== row.id);
        } else {
          this.groups.delete(group.id);
          this.order = this.order.filter(id => id !== group.id);
        }
        changed = true;
      }
      if (changed) cx.notify();
    });
    return this.order.map(id => this.groups.get(id));
  }

  rows(group) {
    return group.rowOrder.map(id => group.rows.get(id));
  }
}
