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

**Recommended: single-service on Render (or any Node host)**

The whole app — Next.js + Socket.IO — runs in one process via `server.ts`. One service, one URL, no env vars to wire up.

1. Push this repo to GitHub.
2. Go to https://dashboard.render.com → **New +** → **Blueprint** → pick your repo.
3. Render reads `render.yaml` automatically. Click **Apply**.
4. First deploy takes 3–5 min (`npm install` + `npm run build`, then `npm start`). When status is **Live**, open the URL — the lobby should load and "Connecting to server…" disappears within a second.

That's it. Same architecture works on Railway (start command `npm start`), Fly.io (see `fly.toml.example`), or any VM.

**Why not Vercel?** Vercel runs Next.js as serverless functions, which die after each request and can't hold WebSocket connections open. The game engine needs a long-lived process with shared in-memory state. The architecture here is incompatible with Vercel's model.

**Free-tier caveat**: Render free web services sleep after 15 min idle (cold start ~30s when the next user visits, which drops any in-flight rooms). For real games among friends this is usually fine; for stable hosting upgrade to Render's $7/mo Starter tier or set `min_machines_running = 1` on Fly.io.

**Alternative: Vercel frontend + separate WS host**

If you really want to use Vercel for the frontend, keep the `ws-server.ts` entry point and run it separately. Set `NEXT_PUBLIC_SOCKET_URL` on Vercel to the WS host URL. See `vercel.json` and the `ws` npm script for the moving parts. Most setups don't need this — the single-service deploy above is simpler.

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
