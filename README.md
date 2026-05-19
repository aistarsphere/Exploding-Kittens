# Exploding Kittens — Web Multiplayer

A self-hosted multiplayer browser version of Exploding Kittens (Party Pack rules, 2–10 players). Built with **Next.js (App Router) + TypeScript + Socket.IO**.

## Run locally

Prerequisite: Node.js 18.18 or newer.

```bash
npm install
npm run dev          # development with hot reload
# or
npm run build && npm start   # production build
```

Open `http://localhost:3006` in your browser.

The server binds to `0.0.0.0:3006` by default. Override with `PORT` and `HOST` env vars.

## How to play with friends

1. **You (the master):** Open the site, enter your name, click **Create Room**. Share the 4-letter room code shown.
2. **Each friend:** Opens the site, enters their name, clicks **Join Room**, types the code.
3. When everyone is in, the master clicks **Start Game**.

### Same-WiFi / LAN play

Find your local IP (`ipconfig` on Windows or `ifconfig` / `ip a` on Linux). Friends visit `http://<your-ip>:3006`. Make sure your firewall allows incoming connections on port 3006.

### Deploy

There are two supported topologies:

**A. Single host (Render / Railway / Fly.io / your own VM)** — easiest

The combined `server.ts` runs Next.js + Socket.IO in one Node process.
- Build: `npm run build`
- Start: `npm start` (runs `tsx server.ts`)
- `PORT` is read from env automatically.
- Vercel cannot run this — its serverless functions don't keep WebSocket connections alive.

**B. Vercel frontend + separate WS host** — when you want the Next.js side on Vercel

The frontend deploys to Vercel; the Socket.IO + game engine deploys separately as `ws-server.ts` to any Node host.

1. **Push the repo to GitHub.**
2. **Deploy the WS server first.** On Render, click "New → Blueprint" and point it at this repo — `render.yaml` does the rest. (`fly.toml.example` is a Fly.io starter; for Railway, choose "Empty service" → set start command `npm run ws`.) After deploy, copy the public URL — something like `https://exploding-kittens-ws.onrender.com`.
3. **Deploy the Next.js side to Vercel.** Import the same repo. Vercel auto-detects Next.js. Add a single env var:
   ```
   NEXT_PUBLIC_SOCKET_URL = https://exploding-kittens-ws.onrender.com
   ```
4. **Lock down CORS on the WS host.** Once Vercel gives you a URL like `https://your-app.vercel.app`, set the WS service env var:
   ```
   CORS_ORIGINS = https://your-app.vercel.app
   ```
   (Comma-separated for multiple. `*` allows any origin — fine for testing, not for production.)
5. Open the Vercel URL. The lobby will say "Connecting to server…" until the socket connects to the WS host.

**Free-tier caveats**: Render's free web service sleeps after 15 min idle (cold start ~30s on next connect, which drops any in-flight room). Fly.io's `auto_stop_machines` does the same. For a stable lobby, use a paid always-on tier or set `min_machines_running = 1` on Fly.

## Project layout

```
server.ts                  Custom Next.js + Socket.IO server
app/
  layout.tsx               Root layout
  page.tsx                 Lobby (create / join / waiting room)
  game/page.tsx            Game table
  globals.css
  lobby.module.css
  game/game.module.css
components/
  Card.tsx                 Single card (CSS-styled with optional image override)
  Hand.tsx                 Player's hand
  Opponents.tsx            Other players' avatars
  NopeBanner.tsx           Pending action + Nope window UI
  PromptModal.tsx          Favor / See Future / Alter / Cat / Defuse prompts
  PickTarget.tsx           Pre-send target picker (e.g. Favor)
  GameOver.tsx             Winner splash
lib/
  cardTypes.ts             Card enum + metadata (shared client + server)
  deck.ts                  Party Pack deck composition
  gameEngine.ts            Authoritative engine (Nope window, prompts)
  roomManager.ts           In-memory rooms + host election
  useSocket.ts             Shared socket.io-client hook
public/
  images/cards/            Drop PNG card scans here to override CSS art
```

## Card images

Cards render as styled CSS by default (colored gradient, label, emoji, description). To use real card scans, drop a PNG into `public/images/cards/<TYPE>.png` (e.g. `SKIP.png`, `EXPLODING_KITTEN.png`, `CAT_TACO.png`). The client probes for it on demand — no rebuild required for new images, just refresh.

The full list of type names is in `lib/cardTypes.ts`.

## Game rules implemented

Party Pack rules with paw-print scaling:

- 2–3 players: paw-print cards only
- 4–7 players: non-paw cards only
- 8–10 players: full deck

Defuses: one per player, plus `(N+2)` shuffled into the draw pile. Exploding Kittens: `N−1` shuffled in after deal.

Card types: Exploding Kitten, Defuse, Nope, Attack, Skip, Favor, Shuffle, See the Future, Alter the Future, Draw from the Bottom, Reverse, Double Slap, Triple Slap, and Cat cards (Taco Cat, Beard Cat, Rainbow Cat, Potato Cat, Cattermelon, Feral Cat).

**Nope window**: 2.5 seconds after any action is played. Any player holding a Nope can play it during this window; Nopes can be Noped back. Drawing and Defuse cannot be Noped.

**References**:
- [Base rules](https://www.ultraboardgames.com/exploding-kittens/game-rules.php)
- [Party Pack rules](https://www.ultraboardgames.com/exploding-kittens/exploding-kittens-party-pack.php)
- [Official instructions](https://www.explodingkittens.com/pages/instructions)
- [How to play (YouTube)](https://www.youtube.com/watch?v=Gd2GLDxywT0)
