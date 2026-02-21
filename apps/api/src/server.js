import http from 'node:http';

const port = Number(process.env.PORT ?? 3001);

const stubQueue = [
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
  }
];

const sendJson = (res, statusCode, payload) => {
  res.writeHead(statusCode, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify(payload));
};

const server = http.createServer((req, res) => {
  if (req.method === 'GET' && req.url === '/health') {
    return sendJson(res, 200, { status: 'ok' });
  }

  if (req.method === 'GET' && req.url?.startsWith('/stream/')) {
    const [, , userId] = req.url.split('/');

    if (!userId) {
      return sendJson(res, 400, { error: 'user_id is required' });
    }

    return sendJson(res, 200, {
      user_id: userId,
      generated_at: new Date().toISOString(),
      queue: stubQueue
    });
  }

  return sendJson(res, 404, { error: 'not_found' });
});

server.listen(port, () => {
  console.log(`@subcastic/api listening on http://localhost:${port}`);
});
