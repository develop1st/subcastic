import { DEFAULT_USER_ID } from '@subcastic/shared';

const segments = [
  {
    segment_id: 'seg_002',
    feed_id: 'feed_tech',
    publisher_id: 'pub_techwire',
    audio_url: 'https://cdn.example.com/audio/seg_002.mp3',
    duration: 55,
    created_at: '2026-01-02T08:00:00.000Z',
    metadata: {
      title: 'Tech Minute',
      description: 'Daily product and startup headlines.',
      tags: ['tech', 'news']
    }
  },
  {
    segment_id: 'seg_003',
    feed_id: 'feed_news',
    publisher_id: 'pub_daily',
    audio_url: 'https://cdn.example.com/audio/seg_003.mp3',
    duration: 48,
    created_at: '2026-01-02T08:05:00.000Z',
    metadata: {
      title: 'Top Stories',
      description: 'A quick global news roundup.',
      tags: ['news', 'world']
    }
  },
  {
    segment_id: 'seg_001',
    feed_id: 'feed_news',
    publisher_id: 'pub_daily',
    audio_url: 'https://cdn.example.com/audio/seg_001.mp3',
    duration: 42,
    created_at: '2026-01-01T00:00:00.000Z',
    metadata: {
      title: 'Morning Brief',
      description: 'Stub segment for stream API bootstrapping.',
      tags: ['news', 'mvp']
    }
  },
  {
    segment_id: 'seg_004',
    feed_id: 'feed_sports',
    publisher_id: 'pub_sportline',
    audio_url: 'https://cdn.example.com/audio/seg_004.mp3',
    duration: 36,
    created_at: '2026-01-02T07:55:00.000Z',
    metadata: {
      title: 'Scoreline Snapshot',
      description: 'Morning sports highlights.',
      tags: ['sports']
    }
  }
];

const followsByUser = {
  [DEFAULT_USER_ID]: {
    user_id: DEFAULT_USER_ID,
    followed_feed_ids: ['feed_news', 'feed_tech', 'feed_sports']
  },
  user_news_only: {
    user_id: 'user_news_only',
    followed_feed_ids: ['feed_news']
  }
};

const groupSegmentsByFeed = (allSegments) => {
  const byFeed = new Map();

  for (const segment of allSegments) {
    const feedSegments = byFeed.get(segment.feed_id) ?? [];
    feedSegments.push(segment);
    byFeed.set(segment.feed_id, feedSegments);
  }

  for (const feedSegments of byFeed.values()) {
    feedSegments.sort((a, b) => Date.parse(b.created_at) - Date.parse(a.created_at));
  }

  return byFeed;
};

export const buildPersonalQueue = ({ userId, limit = 10 }) => {
  const follow = followsByUser[userId] ?? {
    user_id: userId,
    followed_feed_ids: ['feed_news']
  };

  const normalizedLimit = Number.isFinite(limit) ? Math.max(1, Math.min(50, Math.floor(limit))) : 10;

  const segmentsByFeed = groupSegmentsByFeed(segments);
  const queue = [];

  const feedPointers = new Map(follow.followed_feed_ids.map((feedId) => [feedId, 0]));

  while (queue.length < normalizedLimit) {
    let appended = false;

    for (const feedId of follow.followed_feed_ids) {
      const feedSegments = segmentsByFeed.get(feedId) ?? [];
      const pointer = feedPointers.get(feedId) ?? 0;

      if (pointer < feedSegments.length) {
        queue.push(feedSegments[pointer]);
        feedPointers.set(feedId, pointer + 1);
        appended = true;

        if (queue.length === normalizedLimit) {
          break;
        }
      }
    }

    if (!appended) {
      break;
    }
  }

  return {
    user_id: userId,
    generated_at: new Date().toISOString(),
    queue
  };
};
