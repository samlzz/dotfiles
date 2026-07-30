(function () {
  const vscode = acquireVsCodeApi();
  const root = document.getElementById("root");

  window.addEventListener("message", (event) => {
    const message = event.data;
    if (message.type === "update") {
      render(message.items);
    }
  });

  // Whether the item at `index` is the last non-blank sibling at its own
  // indent level (i.e. no later item at the same indent before the subtree
  // closes). Determines the tree connector shape (├ vs └).
  function isLastSibling(items, index) {
    const depth = items[index].indent;
    for (let j = index + 1; j < items.length; j++) {
      if (items[j].type === "blank") {
        continue;
      }
      if (items[j].indent < depth) {
        return true;
      }
      if (items[j].indent === depth) {
        return false;
      }
    }
    return true;
  }

  function render(items) {
    root.innerHTML = "";

    const isLast = items.map((_, i) => isLastSibling(items, i));
    // ancestorAtLevel[k] = index of the nearest preceding item at indent k
    const ancestorAtLevel = [];

    for (let i = 0; i < items.length; i++) {
      const item = items[i];
      const row = document.createElement("div");
      row.className = "row";

      if (item.type !== "blank") {
        for (let level = 0; level < item.indent; level++) {
          const lane = document.createElement("span");
          lane.className = "lane";
          const ancestorIdx = ancestorAtLevel[level];
          if (ancestorIdx !== undefined && !isLast[ancestorIdx]) {
            lane.classList.add("guide");
          }
          row.appendChild(lane);
        }

        const elbow = document.createElement("span");
        elbow.className = "elbow" + (isLast[i] ? "" : " continue");
        elbow.innerHTML =
          '<i class="v-top"></i><i class="h"></i><i class="v-bottom"></i>';
        row.appendChild(elbow);

        ancestorAtLevel[item.indent] = i;
        ancestorAtLevel.length = item.indent + 1;
      }

      if (item.type === "item") {
        const checkbox = document.createElement("div");
        checkbox.className = "checkbox" + (item.checked ? " checked" : "");
        checkbox.setAttribute("role", "checkbox");
        checkbox.setAttribute("aria-checked", String(!!item.checked));
        checkbox.tabIndex = 0;
        checkbox.innerHTML =
          '<svg viewBox="0 0 16 16" width="10" height="10" aria-hidden="true"><path d="M2 8.5l3.5 3.5L14 3" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"/></svg>';

        const toggle = () => vscode.postMessage({ type: "toggle", line: item.line });
        checkbox.addEventListener("click", toggle);
        checkbox.addEventListener("keydown", (e) => {
          if (e.key === "Enter" || e.key === " ") {
            e.preventDefault();
            toggle();
          }
        });

        const label = document.createElement("span");
        label.className = "label" + (item.checked ? " done" : "");
        label.textContent = item.text;

        row.appendChild(checkbox);
        row.appendChild(label);
      } else if (item.type === "text") {
        const label = document.createElement("span");
        label.className = "heading";
        label.textContent = item.text;
        row.appendChild(label);
      } else {
        row.classList.add("blank");
      }

      root.appendChild(row);
    }
  }
})();
