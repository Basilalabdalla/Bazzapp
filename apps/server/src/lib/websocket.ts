import { WebSocketServer, WebSocket } from 'ws';
import { Server } from 'http';
import jwt from 'jsonwebtoken';

interface WsClient {
  ws: WebSocket;
  merchantId: string;
}

const clients = new Map<string, WsClient>();

export function initWebSocket(server: Server) {
  const wss = new WebSocketServer({ server, path: '/ws' });

  wss.on('connection', (ws, req) => {
    const url = new URL(req.url!, `http://${req.headers.host}`);
    const token = url.searchParams.get('token');

    if (!token) {
      ws.close(1008, 'Missing token');
      return;
    }

    try {
      const payload = jwt.verify(token, process.env.JWT_SECRET!) as { sub: string };
      const merchantId = payload.sub;
      const clientId = `${merchantId}-${Date.now()}`;

      clients.set(clientId, { ws, merchantId });
      console.log(`🔌 WS connected: merchant ${merchantId}`);

      ws.send(JSON.stringify({ type: 'connected', merchantId }));

      ws.on('close', () => {
        clients.delete(clientId);
        console.log(`🔌 WS disconnected: merchant ${merchantId}`);
      });

      ws.on('error', (err) => {
        console.error('WS error:', err.message);
        clients.delete(clientId);
      });
    } catch {
      ws.close(1008, 'Invalid token');
    }
  });

  console.log('🔌 WebSocket server ready at /ws');
}

export function broadcastToMerchant(merchantId: string, event: object) {
  const payload = JSON.stringify(event);
  for (const client of clients.values()) {
    if (client.merchantId === merchantId && client.ws.readyState === WebSocket.OPEN) {
      client.ws.send(payload);
    }
  }
}

export function broadcastOrderUpdate(merchantId: string, order: object) {
  broadcastToMerchant(merchantId, { type: 'order:updated', data: order });
}
