import http from 'node:http';
import { buildPersonalQueue } from './stream-engine.js';

const port = Number(process.env.PORT ?? 3001);

const sendJson = (res, statusCode, payload) => {
  res.writeHead(statusCode, {
    'Content-Type': 'application/json',
    'Access-Control-Allow-Origin': '*'
  });
  res.end(JSON.stringify(payload));
};

const server = http.createServer((req, res) => {
  const requestUrl = new URL(req.url ?? '/', `http://${req.headers.host ?? 'localhost'}`);

  if (req.method === 'GET' && requestUrl.pathname === '/health') {
    return sendJson(res, 200, { status: 'ok' });
  }

  if (req.method === 'GET' && requestUrl.pathname.startsWith('/stream/')) {
    const userId = decodeURIComponent(requestUrl.pathname.replace('/stream/', ''));

    if (!userId) {
      return sendJson(res, 400, { error: 'user_id is required' });
    }

    const limit = Number.parseInt(requestUrl.searchParams.get('limit') ?? '10', 10);
    return sendJson(res, 200, buildPersonalQueue({ userId, limit }));
  }

  return sendJson(res, 404, { error: 'not_found' });
});

server.listen(port, () => {
  console.log(`@subcastic/api listening on http://localhost:${port}`);
});
