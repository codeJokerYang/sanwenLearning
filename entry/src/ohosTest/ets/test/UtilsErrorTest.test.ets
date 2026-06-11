/**
 * Unit tests for ErrorCode mapping and mapToCanvas utility
 */
import { ErrorCode, errorCodeToResource } from '../../../main/ets/common/ErrorCode';
import { mapToCanvas, Position } from '../../../main/ets/common/utils';

// Test errorCodeToResource
function testErrorCodeMapping(): void {
  // Test all defined error codes have mappings
  const allCodes = Object.values(ErrorCode) as string[];
  let passed = 0;
  let failed = 0;

  for (const code of allCodes) {
    try {
      const result = errorCodeToResource(code);
      if (result !== null && result !== undefined) {
        passed++;
      } else {
        console.error(`FAIL: errorCodeToResource('${code}') returned null/undefined`);
        failed++;
      }
    } catch (e) {
      console.error(`FAIL: errorCodeToResource('${code}') threw: ${e}`);
      failed++;
    }
  }

  // Test unknown error code returns fallback
  try {
    const result = errorCodeToResource('ERR_UNKNOWN_FAKE_CODE');
    if (result !== null && result !== undefined) {
      passed++;
    } else {
      console.error('FAIL: errorCodeToResource(unknown) returned null');
      failed++;
    }
  } catch (e) {
    console.error(`FAIL: errorCodeToResource(unknown) threw: ${e}`);
    failed++;
  }

  console.info(`ErrorCode mapping tests: ${passed} passed, ${failed} failed`);
}

// Test mapToCanvas
function testMapToCanvas(): void {
  let passed = 0;
  let failed = 0;

  // Test origin maps to center offset
  const originResult = mapToCanvas({ x: 0, y: 0 }, 600, 600);
  if (originResult.x === 0 && originResult.y === 0) {
    passed++;
  } else {
    console.error(`FAIL: mapToCanvas(0,0,600,600) = (${originResult.x},${originResult.y}), expected (0,0)`);
    failed++;
  }

  // Test max layout space maps to canvas edge
  const maxResult = mapToCanvas({ x: 600, y: 600 }, 600, 600);
  if (maxResult.x === 600 && maxResult.y === 600) {
    passed++;
  } else {
    console.error(`FAIL: mapToCanvas(600,600,600,600) = (${maxResult.x},${maxResult.y}), expected (600,600)`);
    failed++;
  }

  // Test center maps to center
  const centerResult = mapToCanvas({ x: 300, y: 300 }, 600, 600);
  if (centerResult.x === 300 && centerResult.y === 300) {
    passed++;
  } else {
    console.error(`FAIL: mapToCanvas(300,300,600,600) = (${centerResult.x},${centerResult.y}), expected (300,300)`);
    failed++;
  }

  // Test smaller canvas scales down
  const scaledResult = mapToCanvas({ x: 300, y: 300 }, 300, 300);
  if (scaledResult.x === 150 && scaledResult.y === 150) {
    passed++;
  } else {
    console.error(`FAIL: mapToCanvas(300,300,300,300) = (${scaledResult.x},${scaledResult.y}), expected (150,150)`);
    failed++;
  }

  // Test non-square canvas (wider)
  const wideResult = mapToCanvas({ x: 300, y: 300 }, 800, 400);
  // scale = min(800/600, 400/600) = min(1.33, 0.67) = 0.67
  // offsetX = (800 - 600*0.67)/2 = (800-400)/2 = 200
  // offsetY = (400 - 600*0.67)/2 = (400-400)/2 = 0
  // x = 300*0.67 + 200 = 200 + 200 = 400
  // y = 300*0.67 + 0 = 200
  if (Math.abs(wideResult.x - 400) < 1 && Math.abs(wideResult.y - 200) < 1) {
    passed++;
  } else {
    console.error(`FAIL: mapToCanvas(300,300,800,400) = (${wideResult.x},${wideResult.y}), expected (~400,~200)`);
    failed++;
  }

  // Test negative coordinates
  const negResult = mapToCanvas({ x: -10, y: -10 }, 600, 600);
  if (negResult.x === -10 && negResult.y === -10) {
    passed++;
  } else {
    console.error(`FAIL: mapToCanvas(-10,-10,600,600) = (${negResult.x},${negResult.y}), expected (-10,-10)`);
    failed++;
  }

  console.info(`mapToCanvas tests: ${passed} passed, ${failed} failed`);
}

// Run all tests
testErrorCodeMapping();
testMapToCanvas();
