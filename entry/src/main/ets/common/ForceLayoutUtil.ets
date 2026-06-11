/**
 * ForceLayoutUtil — 力导向布局计算工具
 * 基于 FORCE_LAYOUT_CONFIG 配置，对知识图谱节点进行力学模拟
 * 已激活节点锁定坐标，不参与迭代；未激活节点坐标 -1 时先随机初始化
 */
import { KnowledgeNode, KnowledgeEdge, NodeType } from '../models/Models';
import { FORCE_LAYOUT_CONFIG } from './Config';
import { Logger } from './Logger';

const TAG = 'FORCE_LAYOUT';

export interface LayoutPosition {
  x: number;
  y: number;
}

interface LayoutDisplacement {
  dx: number;
  dy: number;
}

/**
 * computeForceDirectedLayout — 运行力导向布局算法
 * @param nodes 知识节点数组
 * @param edges 知识边数组
 * @returns Map<nodeId, {x, y}> 所有节点计算后的坐标
 */
export function computeForceDirectedLayout(
  nodes: KnowledgeNode[],
  edges: KnowledgeEdge[]
): Map<string, LayoutPosition> {
  const positions: Map<string, LayoutPosition> = new Map();
  const startMs: number = Date.now();

  if (nodes.length === 0) {
    return positions;
  }

  // Step 1: Initialize positions
  for (const node of nodes) {
    if (node.is_activated && node.x_pos !== FORCE_LAYOUT_CONFIG.INITIAL_POS) {
      // Activated nodes: lock at current position
      positions.set(node.id, { x: node.x_pos, y: node.y_pos });
    } else if (node.x_pos === FORCE_LAYOUT_CONFIG.INITIAL_POS) {
      // Uninitialized nodes: random within 100~500 range
      const rx: number = Math.floor(
        Math.random() * (FORCE_LAYOUT_CONFIG.POS_RANGE_MAX - FORCE_LAYOUT_CONFIG.POS_RANGE_MIN + 1)
      ) + FORCE_LAYOUT_CONFIG.POS_RANGE_MIN;
      const ry: number = Math.floor(
        Math.random() * (FORCE_LAYOUT_CONFIG.POS_RANGE_MAX - FORCE_LAYOUT_CONFIG.POS_RANGE_MIN + 1)
      ) + FORCE_LAYOUT_CONFIG.POS_RANGE_MIN;
      positions.set(node.id, { x: rx, y: ry });
    } else {
      // Previously positioned but not activated: keep current
      positions.set(node.id, { x: node.x_pos, y: node.y_pos });
    }
  }

  // Step 2: Force-directed iterations (skip activated nodes)
  const repulsionStrength: number = 5000;
  const attractionStrength: number = 0.01;
  const damping: number = 0.9;
  const centerX: number = 300;
  const centerY: number = 300;

  // Pre-compute adjacency for O(1) lookups
  const adjacency: Map<string, Set<string>> = new Map();
  for (const node of nodes) {
    adjacency.set(node.id, new Set());
  }
  for (const edge of edges) {
    const srcSet = adjacency.get(edge.source);
    const tgtSet = adjacency.get(edge.target);
    if (srcSet) {
      srcSet.add(edge.target);
    }
    if (tgtSet) {
      tgtSet.add(edge.source);
    }
  }

  // Collect movable node IDs
  const movableIds: string[] = [];
  for (const node of nodes) {
    if (!node.is_activated) {
      movableIds.push(node.id);
    }
  }

  if (movableIds.length === 0) {
    const elapsed: number = Date.now() - startMs;
    Logger.getInstance().info(TAG, `[PERF] Force layout computed in ${elapsed}ms (no movable nodes)`);
    return positions;
  }

  for (let iter: number = 0; iter < FORCE_LAYOUT_CONFIG.MAX_ITERATIONS; iter++) {
    const displacements: Map<string, LayoutDisplacement> = new Map();
    for (const id of movableIds) {
      displacements.set(id, { dx: 0, dy: 0 });
    }

    // Repulsion: each pair of movable nodes
    for (let i: number = 0; i < movableIds.length; i++) {
      for (let j: number = i + 1; j < movableIds.length; j++) {
        const a = movableIds[i];
        const b = movableIds[j];
        const pa = positions.get(a)!;
        const pb = positions.get(b)!;
        let dx: number = pa.x - pb.x;
        let dy: number = pa.y - pb.y;
        let dist: number = Math.sqrt(dx * dx + dy * dy);
        if (dist < 1) {
          dist = 1;
          dx = Math.random() - 0.5;
          dy = Math.random() - 0.5;
        }
        const force: number = repulsionStrength / (dist * dist);
        const fx: number = (dx / dist) * force;
        const fy: number = (dy / dist) * force;
        const da = displacements.get(a)!;
        const db = displacements.get(b)!;
        da.dx += fx;
        da.dy += fy;
        db.dx -= fx;
        db.dy -= fy;
      }
    }

    // Attraction: along edges between movable nodes
    for (const edge of edges) {
      if (movableIds.indexOf(edge.source) === -1 && movableIds.indexOf(edge.target) === -1) {
        continue;
      }
      const ps = positions.get(edge.source);
      const pt = positions.get(edge.target);
      if (!ps || !pt) {
        continue;
      }
      const dx: number = pt.x - ps.x;
      const dy: number = pt.y - ps.y;
      const dist: number = Math.sqrt(dx * dx + dy * dy);
      if (dist < 1) {
        continue;
      }
      const force: number = dist * attractionStrength;
      const fx: number = (dx / dist) * force;
      const fy: number = (dy / dist) * force;
      if (movableIds.indexOf(edge.source) !== -1) {
        const d = displacements.get(edge.source)!;
        d.dx += fx;
        d.dy += fy;
      }
      if (movableIds.indexOf(edge.target) !== -1) {
        const d = displacements.get(edge.target)!;
        d.dx -= fx;
        d.dy -= fy;
      }
    }

    // Center gravity: pull toward center
    for (const id of movableIds) {
      const p = positions.get(id)!;
      const d = displacements.get(id)!;
      d.dx += (centerX - p.x) * 0.01;
      d.dy += (centerY - p.y) * 0.01;
    }

    // Apply displacements with damping
    let maxDisp: number = 0;
    for (const id of movableIds) {
      const p = positions.get(id)!;
      const d = displacements.get(id)!;
      const dx: number = d.dx * damping;
      const dy: number = d.dy * damping;
      p.x = Math.max(0, Math.min(600, p.x + dx));
      p.y = Math.max(0, Math.min(600, p.y + dy));
      maxDisp = Math.max(maxDisp, Math.abs(dx), Math.abs(dy));
    }

    // Early exit if converged
    if (maxDisp < 0.5) {
      break;
    }
  }

  const elapsed: number = Date.now() - startMs;
  Logger.getInstance().info(TAG, `[PERF] Force layout computed in ${elapsed}ms`);

  return positions;
}
