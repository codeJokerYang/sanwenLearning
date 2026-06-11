export interface Position {
  x: number
  y: number
}

const LAYOUT_SPACE: number = 600

export function mapToCanvas(
  pos: Position,
  canvasWidth: number,
  canvasHeight: number,
  layoutSpace: number = LAYOUT_SPACE
): Position {
  const scale = Math.min(canvasWidth / layoutSpace, canvasHeight / layoutSpace)
  const offsetX = (canvasWidth - layoutSpace * scale) / 2
  const offsetY = (canvasHeight - layoutSpace * scale) / 2
  return {
    x: pos.x * scale + offsetX,
    y: pos.y * scale + offsetY
  }
}
