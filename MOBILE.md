# Playing on Mobile

The game is a browser app, so any modern phone browser works — no install, no app store.

## Quick start

1. On your phone, open: **http://52.58.22.19/kittens**
2. Type your name.
3. **Host (one player):** tap **Create Room**. Share the 4-letter code shown.
4. **Everyone else:** tap **Join Room**, type the code.
5. Once everyone is in the lobby, the host taps **Start Game**.

That's it. Hold the phone in portrait — the table, hand, and prompts are laid out for narrow screens.

## What to expect

- **Connection indicator** — the lobby shows "Connecting to server…" for ~1s on first load. If it stays longer than 5s, you're either offline or the server is asleep (cold start ~30s on free hosting).
- **Stays awake on its own** — the page uses WebSockets, so background tabs may pause. Keep the tab in the foreground during a game. If you tab away and come back to a stale view, just refresh — your seat is held by your player ID.
- **Disconnects** — losing signal for under ~30s usually reconnects you to your seat automatically. Longer than that and the host can reassign your slot.

## Adding the game to your home screen

Treat it like a PWA — gives you a one-tap launch.

- **iOS Safari:** tap Share → **Add to Home Screen**.
- **Android Chrome:** tap ⋮ → **Add to Home screen** (or **Install app** if offered).

Launching from the home-screen icon opens full-screen without the URL bar, which gives the table more vertical room.

## Tips for a smooth game

- **Same Wi-Fi is fastest.** If everyone's on the same network, latency is near-zero — the Nope window (2.5s) feels generous. Over mobile data it's still playable but tighter.
- **Lock orientation to portrait.** Rotating mid-turn re-flows the hand and you may misclick.
- **Disable "Reader Mode."** Safari's auto-reader can strip the game UI; if it triggers, tap the URL bar and turn it off.
- **Battery saver throttles WebSockets** on some Androids — disable battery saver for the browser while playing, or your Nopes will fire late.

## Troubleshooting

| Symptom | Fix |
| --- | --- |
| "Connecting to server…" never goes away | Refresh once. Still stuck → server is down or you're offline. |
| Room code says "not found" | Code is case-insensitive but must be exactly 4 letters. Re-check with the host. |
| Cards don't render, just colored rectangles | Network is too slow to fetch card art. The fallback CSS art is the intended experience — no fix needed. |
| Tapped a card by accident | The Nope window applies to your own actions too — anyone (including you) can Nope your play within 2.5s. |
| Kicked back to the lobby mid-game | Your tab was backgrounded long enough to drop the socket. Re-join with the same room code. |

## For the host

You don't need a special device — the host role is just "whoever clicked Create Room." Any player can be the host. If the host disconnects, the next-joined player automatically takes over (host election is automatic).
