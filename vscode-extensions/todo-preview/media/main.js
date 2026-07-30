(function () {
  const vscode = acquireVsCodeApi();
  const root = document.getElementById("root");

  window.addEventListener("message", (event) => {
    const message = event.data;
    if (message.type === "update") {
      render(message.items);
    }
  });

  function render(items) {
    root.innerHTML = "";
    for (const item of items) {
      const row = document.createElement("div");
      row.className = "row";
      row.style.marginLeft = item.indent * 20 + "px";

      if (item.type === "item") {
        const checkbox = document.createElement("input");
        checkbox.type = "checkbox";
        checkbox.checked = !!item.checked;
        checkbox.addEventListener("change", () => {
          vscode.postMessage({ type: "toggle", line: item.line });
        });

        const label = document.createElement("span");
        label.className = "label" + (item.checked ? " done" : "");
        label.textContent = item.text;

        row.appendChild(checkbox);
        row.appendChild(label);
      } else if (item.type === "text") {
        const label = document.createElement("span");
        label.className = "comment";
        label.textContent = item.text;
        row.appendChild(label);
      } else {
        row.classList.add("blank");
      }

      root.appendChild(row);
    }
  }
})();
