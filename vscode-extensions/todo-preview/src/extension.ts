import * as vscode from "vscode";
import { parseTodoDocument } from "./todoParser";

export function activate(context: vscode.ExtensionContext): void {
  context.subscriptions.push(TodoEditorProvider.register(context));
  context.subscriptions.push(
    vscode.commands.registerCommand("mysh.todoPreview.openSource", () =>
      reopenActiveTodoWith("default")
    ),
    vscode.commands.registerCommand("mysh.todoPreview.openPreview", () =>
      reopenActiveTodoWith(TodoEditorProvider.viewType)
    ),
    vscode.commands.registerCommand("mysh.todoPreview.toggle", toggleActiveTodoView)
  );
}

function getActiveTodoTabInfo(): { uri: vscode.Uri; isPreview: boolean } | undefined {
  const tab = vscode.window.tabGroups.activeTabGroup.activeTab;
  if (!tab) {
    return undefined;
  }
  if (tab.input instanceof vscode.TabInputCustom) {
    return { uri: tab.input.uri, isPreview: tab.input.viewType === TodoEditorProvider.viewType };
  }
  if (tab.input instanceof vscode.TabInputText) {
    return { uri: tab.input.uri, isPreview: false };
  }
  return undefined;
}

async function reopenActiveTodoWith(viewType: string): Promise<void> {
  const info = getActiveTodoTabInfo();
  if (!info) {
    return;
  }
  await vscode.commands.executeCommand("vscode.openWith", info.uri, viewType);
}

async function toggleActiveTodoView(): Promise<void> {
  const info = getActiveTodoTabInfo();
  if (!info) {
    return;
  }
  await reopenActiveTodoWith(info.isPreview ? "default" : TodoEditorProvider.viewType);
}

export function deactivate(): void {}

class TodoEditorProvider implements vscode.CustomTextEditorProvider {
  public static readonly viewType = "mysh.todoPreview";

  public static register(context: vscode.ExtensionContext): vscode.Disposable {
    const provider = new TodoEditorProvider(context);
    return vscode.window.registerCustomEditorProvider(
      TodoEditorProvider.viewType,
      provider,
      { webviewOptions: { retainContextWhenHidden: true } }
    );
  }

  constructor(private readonly context: vscode.ExtensionContext) {}

  public resolveCustomTextEditor(
    document: vscode.TextDocument,
    webviewPanel: vscode.WebviewPanel,
    _token: vscode.CancellationToken
  ): void {
    webviewPanel.webview.options = { enableScripts: true };
    webviewPanel.webview.html = this.getHtml(webviewPanel.webview);

    const postUpdate = () => {
      webviewPanel.webview.postMessage({
        type: "update",
        items: parseTodoDocument(document.getText()),
      });
    };

    const changeDocSub = vscode.workspace.onDidChangeTextDocument((e) => {
      if (e.document.uri.toString() === document.uri.toString()) {
        postUpdate();
      }
    });
    webviewPanel.onDidDispose(() => changeDocSub.dispose());

    webviewPanel.webview.onDidReceiveMessage((message: { type: string; line: number }) => {
      if (message.type === "toggle") {
        this.toggleCheckbox(document, message.line);
      }
    });

    postUpdate();
  }

  private toggleCheckbox(document: vscode.TextDocument, lineIndex: number): void {
    if (lineIndex < 0 || lineIndex >= document.lineCount) {
      return;
    }
    const lineText = document.lineAt(lineIndex).text;
    const match = lineText.match(/^(\s*)\[( |x|X)\]/);
    if (!match) {
      return;
    }
    const newMark = match[2].toLowerCase() === "x" ? " " : "x";
    const markStart = match[1].length + 1;
    const range = new vscode.Range(lineIndex, markStart, lineIndex, markStart + 1);
    const edit = new vscode.WorkspaceEdit();
    edit.replace(document.uri, range, newMark);
    void vscode.workspace.applyEdit(edit);
  }

  private getHtml(webview: vscode.Webview): string {
    const scriptUri = webview.asWebviewUri(
      vscode.Uri.joinPath(this.context.extensionUri, "media", "main.js")
    );
    const styleUri = webview.asWebviewUri(
      vscode.Uri.joinPath(this.context.extensionUri, "media", "main.css")
    );
    const nonce = getNonce();

    return `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta http-equiv="Content-Security-Policy" content="default-src 'none'; style-src ${webview.cspSource}; script-src 'nonce-${nonce}';">
  <link href="${styleUri}" rel="stylesheet">
  <title>Todo Preview</title>
</head>
<body>
  <div id="root"></div>
  <script nonce="${nonce}" src="${scriptUri}"></script>
</body>
</html>`;
  }
}

function getNonce(): string {
  const possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
  let text = "";
  for (let i = 0; i < 32; i++) {
    text += possible.charAt(Math.floor(Math.random() * possible.length));
  }
  return text;
}
