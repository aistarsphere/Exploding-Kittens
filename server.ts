// Combined dev server: Next.js + Socket.IO in one process.
// Used for local development. On Vercel, this file is ignored entirely —
// the WS layer is hosted separately via ws-server.ts on Render/Railway/Fly.

import { createServer } from 'node:http';
import { parse } from 'node:url';
import next from 'next';
import { Server as IOServer } from 'socket.io';
import { RoomManager } from './lib/roomManager';
import { setupSockets } from './lib/setupSockets';

const port = parseInt(process.env.PORT || '3006', 10);
const host = process.env.HOST || '0.0.0.0';
const dev = process.env.NODE_ENV !== 'production';

const nextApp = next({ dev, hostname: host, port });
const handle = nextApp.getRequestHandler();

const rooms = new RoomManager();

nextApp.prepare().then(() => {
  const httpServer = createServer((req, res) => {
    const parsedUrl = parse(req.url || '/', true);
    handle(req, res, parsedUrl);
  });

  const io = new IOServer(httpServer, { path: '/kittens/socket.io/', cors: { origin: '*' } });
  setupSockets(io, rooms);

  httpServer.listen(port, host, () => {
    console.log(`Exploding Kittens — Next.js + Socket.IO`);
    console.log(`Ready on http://${host}:${port}`);
    console.log(`Local:   http://localhost:${port}`);
  });
});
