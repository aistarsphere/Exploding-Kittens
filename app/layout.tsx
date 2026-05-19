import type { Metadata } from 'next';
import './globals.css';

export const metadata: Metadata = {
  title: 'Exploding Kittens — Online',
  description: 'Web multiplayer Exploding Kittens (Party Pack rules, 2–10 players)',
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
