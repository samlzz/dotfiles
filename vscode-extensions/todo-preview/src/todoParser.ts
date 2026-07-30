export type TodoLineType = "item" | "text" | "blank";

export interface TodoLine {
  line: number;
  type: TodoLineType;
  indent: number;
  checked: boolean;
  text: string;
}

const ITEM_RE = /^(\s*)\[( |x|X)\]\s?(.*)$/;
const INDENT_WIDTH = 4;

export function parseTodoDocument(raw: string): TodoLine[] {
  return raw.split(/\r?\n/).map((line, i) => parseLine(line, i));
}

function parseLine(line: string, index: number): TodoLine {
  const itemMatch = line.match(ITEM_RE);
  if (itemMatch) {
    const [, indentSpaces, mark, text] = itemMatch;
    return {
      line: index,
      type: "item",
      indent: Math.floor(indentSpaces.length / INDENT_WIDTH),
      checked: mark.toLowerCase() === "x",
      text,
    };
  }

  if (line.trim().length === 0) {
    return { line: index, type: "blank", indent: 0, checked: false, text: "" };
  }

  const indentMatch = line.match(/^(\s*)/);
  const indentSpaces = indentMatch ? indentMatch[1].length : 0;
  return {
    line: index,
    type: "text",
    indent: Math.floor(indentSpaces / INDENT_WIDTH),
    checked: false,
    text: line.trim(),
  };
}
