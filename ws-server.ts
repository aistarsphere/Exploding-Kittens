// WebSocket-only server. Runs Socket.IO + the authoritative game engine
// without Next.js. Deploy this on Render / Railway / Fly.io while Vercel
// hosts the static Next.js frontend.

import { createServer } from 'node:http';
import { Server as IOServer } from 'socket.io';
import { RoomManager } from './lib/roomManager';
import { setupSockets } from './lib/setupSockets';

const port = parseInt(process.env.PORT || '3006', 10);
const host = process.env.HOST || '0.0.0.0';

// CORS_ORIGINS: comma-separated list, or "*" for any. Default: any.
const corsEnv = (process.env.CORS_ORIGINS || '*').trim();
const corsOrigin: string | string[] =
  corsEnv === '*' ? '*' : corsEnv.split(',').map(s => s.trim()).filter(Boolean);

const httpServer = createServer((req, res) => {
  // Plain health check so platforms like Render see a 200 on the root path.
  if (req.url === '/' || req.url === '/health' || req.url === '/healthz') {
    res.writeHead(200, { 'Content-Type': 'text/plain' });
    res.end('Exploding Kittens WS server OK');
    return;
  }
  res.writeHead(404, { 'Content-Type': 'text/plain' });
  res.end('Not found');
});

const io = new IOServer(httpServer, {
  cors: { origin: corsOrigin, credentials: false },
});

const rooms = new RoomManager();
setupSockets(io, rooms);

httpServer.listen(port, host, () => {
  console.log(`Exploding Kittens WS server`);
  console.log(`Ready on http://${host}:${port}`);
  console.log(`CORS origins: ${corsEnv}`);
});
