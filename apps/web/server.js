import http from 'node:http';
import { readFile } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const port = Number(process.env.PORT ?? 3000);

const server = http.createServer(async (req, res) => {
  if (req.url !== '/') {
    res.writeHead(404);
    res.end('Not Found');
    return;
  }

  const html = await readFile(path.join(__dirname, 'src/index.html'), 'utf8');
  res.writeHead(200, { 'Content-Type': 'text/html' });
  res.end(html);
});

server.listen(port, () => {
  console.log(`@subcastic/web listening on http://localhost:${port}`);
});
