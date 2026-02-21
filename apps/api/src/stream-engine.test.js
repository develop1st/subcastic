import test from 'node:test';
import assert from 'node:assert/strict';
import { buildPersonalQueue } from './stream-engine.js';

test('buildPersonalQueue interleaves followed feeds deterministically for default user', () => {
  const result = buildPersonalQueue({ userId: 'user_123' });
  assert.deepEqual(
    result.queue.map((item) => item.segment_id),
    ['seg_003', 'seg_002', 'seg_004', 'seg_001']
  );
});

test('buildPersonalQueue respects single-feed follows', () => {
  const result = buildPersonalQueue({ userId: 'user_news_only' });
  assert.deepEqual(
    result.queue.map((item) => item.segment_id),
    ['seg_003', 'seg_001']
  );
});

test('buildPersonalQueue applies limit', () => {
  const result = buildPersonalQueue({ userId: 'user_123', limit: 2 });
  assert.equal(result.queue.length, 2);
  assert.deepEqual(result.queue.map((item) => item.segment_id), ['seg_003', 'seg_002']);
});
