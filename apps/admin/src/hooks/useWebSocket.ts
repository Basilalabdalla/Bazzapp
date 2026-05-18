import { useEffect, useRef, useCallback } from 'react';
import { useQueryClient } from '@tanstack/react-query';
import { useAuthStore } from '../store/auth';
import toast from 'react-hot-toast';

interface WebSocketEvent {
  type: string;
  data?: unknown;
}

interface UseWebSocketOptions {
  onOrderUpdate?: (data: unknown) => void;
}

export function useWebSocket({ onOrderUpdate }: UseWebSocketOptions = {}) {
  const queryClient = useQueryClient();
  const { accessToken } = useAuthStore();
  const wsRef = useRef<WebSocket | null>(null);
  const reconnectTimeoutRef = useRef<ReturnType<typeof setTimeout> | null>(null);
  const reconnectAttempts = useRef(0);
  const maxReconnectAttempts = 10;

  const connect = useCallback(() => {
    if (!accessToken) return;

    const wsBase =
      import.meta.env.VITE_WS_URL ||
      (import.meta.env.VITE_API_URL || 'http://localhost:3000').replace(
        /^http/,
        'ws'
      );

    const url = `${wsBase}/ws?token=${encodeURIComponent(accessToken)}`;

    try {
      const ws = new WebSocket(url);
      wsRef.current = ws;

      ws.onopen = () => {
        reconnectAttempts.current = 0;
      };

      ws.onmessage = (event) => {
        try {
          const msg: WebSocketEvent = JSON.parse(event.data as string);

          if (msg.type === 'order:updated') {
            // Invalidate all order-related queries
            queryClient.invalidateQueries({ queryKey: ['orders'] });
            queryClient.invalidateQueries({ queryKey: ['stats'] });

            toast('An order was just updated', { icon: '📦' });

            if (onOrderUpdate) {
              onOrderUpdate(msg.data);
            }
          }
        } catch {
          // ignore malformed messages
        }
      };

      ws.onclose = () => {
        wsRef.current = null;
        scheduleReconnect();
      };

      ws.onerror = () => {
        ws.close();
      };
    } catch {
      scheduleReconnect();
    }
  }, [accessToken, queryClient, onOrderUpdate]);

  const scheduleReconnect = useCallback(() => {
    if (reconnectAttempts.current >= maxReconnectAttempts) return;

    const delay = Math.min(1000 * 2 ** reconnectAttempts.current, 30000);
    reconnectAttempts.current += 1;

    reconnectTimeoutRef.current = setTimeout(() => {
      connect();
    }, delay);
  }, [connect]);

  useEffect(() => {
    connect();

    return () => {
      if (reconnectTimeoutRef.current) {
        clearTimeout(reconnectTimeoutRef.current);
      }
      if (wsRef.current) {
        wsRef.current.close();
      }
    };
  }, [connect]);

  return { isConnected: wsRef.current?.readyState === WebSocket.OPEN };
}
