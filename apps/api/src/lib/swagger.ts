import swaggerJsdoc from 'swagger-jsdoc';
import swaggerUi from 'swagger-ui-express';
import { Express } from 'express';

const options: swaggerJsdoc.Options = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: 'BazZ API',
      version: '1.0.0',
      description: 'BazZ delivery platform API — Jordan',
    },
    servers: [{ url: '/api', description: 'API base' }],
    components: {
      securitySchemes: {
        bearerAuth: {
          type: 'http',
          scheme: 'bearer',
          bearerFormat: 'JWT',
        },
      },
      schemas: {
        Merchant: {
          type: 'object',
          properties: {
            id: { type: 'string' },
            phone: { type: 'string' },
            name: { type: 'string' },
            nameAr: { type: 'string', nullable: true },
            role: { type: 'string', enum: ['MERCHANT', 'ADMIN'] },
            isActive: { type: 'boolean' },
            createdAt: { type: 'string', format: 'date-time' },
          },
        },
        Order: {
          type: 'object',
          properties: {
            id: { type: 'string' },
            orderId: { type: 'string', example: '#BZ-2401' },
            merchantId: { type: 'string' },
            recipientName: { type: 'string' },
            recipientPhone: { type: 'string' },
            address: { type: 'string' },
            area: { type: 'string' },
            governorate: { type: 'string' },
            packageSize: { type: 'string', enum: ['SMALL', 'MEDIUM', 'LARGE'] },
            isFragile: { type: 'boolean' },
            isCod: { type: 'boolean' },
            codAmount: { type: 'number' },
            status: { type: 'string', enum: ['PENDING', 'PROCESSING', 'IN_DELIVERY', 'DELIVERED', 'CANCELLED'] },
            driverName: { type: 'string', nullable: true },
            driverPhone: { type: 'string', nullable: true },
            createdAt: { type: 'string', format: 'date-time' },
          },
        },
        Pagination: {
          type: 'object',
          properties: {
            page: { type: 'integer' },
            limit: { type: 'integer' },
            total: { type: 'integer' },
            totalPages: { type: 'integer' },
          },
        },
        Error: {
          type: 'object',
          properties: { error: { type: 'string' } },
        },
      },
    },
    security: [{ bearerAuth: [] }],
    tags: [
      { name: 'Auth', description: 'Authentication & profile' },
      { name: 'Orders', description: 'Merchant order management' },
      { name: 'Reports', description: 'Merchant analytics' },
      { name: 'Admin — Merchants', description: 'Admin: merchant management' },
      { name: 'Admin — Orders', description: 'Admin: order management' },
      { name: 'Admin — Stats', description: 'Admin: platform statistics' },
      { name: 'Areas', description: 'Jordan governorates & areas (public)' },
    ],
    paths: {
      // ── Auth ──────────────────────────────────────────────────────────────
      '/auth/login': {
        post: {
          tags: ['Auth'],
          summary: 'Merchant login',
          security: [],
          requestBody: {
            required: true,
            content: {
              'application/json': {
                schema: {
                  type: 'object',
                  required: ['phone', 'password'],
                  properties: { phone: { type: 'string' }, password: { type: 'string' } },
                },
              },
            },
          },
          responses: {
            200: { description: 'Login successful — returns access + refresh tokens' },
            401: { description: 'Invalid credentials', content: { 'application/json': { schema: { $ref: '#/components/schemas/Error' } } } },
          },
        },
      },
      '/auth/refresh': {
        post: {
          tags: ['Auth'],
          summary: 'Refresh access token',
          security: [],
          requestBody: {
            required: true,
            content: { 'application/json': { schema: { type: 'object', required: ['refreshToken'], properties: { refreshToken: { type: 'string' } } } } },
          },
          responses: { 200: { description: 'New access + refresh tokens' }, 401: { description: 'Invalid token' } },
        },
      },
      '/auth/logout': {
        post: {
          tags: ['Auth'],
          summary: 'Logout (revoke refresh token)',
          security: [],
          requestBody: {
            required: true,
            content: { 'application/json': { schema: { type: 'object', required: ['refreshToken'], properties: { refreshToken: { type: 'string' } } } } },
          },
          responses: { 200: { description: 'Logged out' } },
        },
      },
      '/auth/me': {
        get: {
          tags: ['Auth'],
          summary: 'Get current merchant profile',
          responses: { 200: { description: 'Merchant profile', content: { 'application/json': { schema: { $ref: '#/components/schemas/Merchant' } } } }, 401: { description: 'Unauthorized' } },
        },
      },
      '/auth/profile': {
        patch: {
          tags: ['Auth'],
          summary: 'Update merchant name',
          requestBody: {
            content: { 'application/json': { schema: { type: 'object', properties: { name: { type: 'string' }, nameAr: { type: 'string' } } } } },
          },
          responses: { 200: { description: 'Updated profile' } },
        },
      },
      '/auth/password': {
        patch: {
          tags: ['Auth'],
          summary: 'Change merchant password',
          requestBody: {
            required: true,
            content: { 'application/json': { schema: { type: 'object', required: ['currentPassword', 'newPassword'], properties: { currentPassword: { type: 'string' }, newPassword: { type: 'string', minLength: 6 } } } } },
          },
          responses: { 200: { description: 'Password changed' }, 401: { description: 'Wrong current password' } },
        },
      },
      '/auth/fcm-token': {
        patch: {
          tags: ['Auth'],
          summary: 'Register/update FCM push token',
          requestBody: {
            required: true,
            content: { 'application/json': { schema: { type: 'object', required: ['fcmToken'], properties: { fcmToken: { type: 'string' } } } } },
          },
          responses: { 200: { description: 'Token registered' } },
        },
      },
      // ── Orders ────────────────────────────────────────────────────────────
      '/orders': {
        get: {
          tags: ['Orders'],
          summary: 'List orders (paginated, filtered)',
          parameters: [
            { in: 'query', name: 'status', schema: { type: 'string', enum: ['PENDING', 'PROCESSING', 'IN_DELIVERY', 'DELIVERED', 'CANCELLED'] } },
            { in: 'query', name: 'search', schema: { type: 'string' } },
            { in: 'query', name: 'page', schema: { type: 'integer', default: 1 } },
            { in: 'query', name: 'limit', schema: { type: 'integer', default: 20 } },
            { in: 'query', name: 'from', schema: { type: 'string', format: 'date' } },
            { in: 'query', name: 'to', schema: { type: 'string', format: 'date' } },
          ],
          responses: { 200: { description: 'Paginated order list' } },
        },
        post: {
          tags: ['Orders'],
          summary: 'Create a new order',
          requestBody: {
            required: true,
            content: {
              'application/json': {
                schema: {
                  type: 'object',
                  required: ['recipientName', 'recipientPhone', 'address', 'area', 'governorate'],
                  properties: {
                    recipientName: { type: 'string' },
                    recipientPhone: { type: 'string' },
                    address: { type: 'string' },
                    area: { type: 'string' },
                    areaAr: { type: 'string' },
                    governorate: { type: 'string' },
                    governorateAr: { type: 'string' },
                    packageSize: { type: 'string', enum: ['SMALL', 'MEDIUM', 'LARGE'] },
                    isFragile: { type: 'boolean' },
                    isCod: { type: 'boolean' },
                    codAmount: { type: 'number' },
                    notes: { type: 'string' },
                  },
                },
              },
            },
          },
          responses: { 201: { description: 'Order created', content: { 'application/json': { schema: { $ref: '#/components/schemas/Order' } } } } },
        },
      },
      '/orders/{id}': {
        get: {
          tags: ['Orders'],
          summary: 'Get order by id or orderId (#BZ-XXXX)',
          parameters: [{ in: 'path', name: 'id', required: true, schema: { type: 'string' } }],
          responses: { 200: { description: 'Order detail' }, 404: { description: 'Not found' } },
        },
      },
      '/orders/{id}/status': {
        patch: {
          tags: ['Orders'],
          summary: 'Update order status',
          parameters: [{ in: 'path', name: 'id', required: true, schema: { type: 'string' } }],
          requestBody: {
            required: true,
            content: { 'application/json': { schema: { type: 'object', required: ['status'], properties: { status: { type: 'string', enum: ['PENDING', 'PROCESSING', 'IN_DELIVERY', 'DELIVERED', 'CANCELLED'] }, note: { type: 'string' } } } } },
          },
          responses: { 200: { description: 'Updated order' } },
        },
      },
      // ── Reports ───────────────────────────────────────────────────────────
      '/reports/summary': {
        get: {
          tags: ['Reports'],
          summary: 'Order counts + success rate for period',
          parameters: [{ in: 'query', name: 'period', schema: { type: 'string', enum: ['today', 'week', 'month', 'year'], default: 'month' } }],
          responses: { 200: { description: 'Summary stats' } },
        },
      },
      '/reports/orders-chart': {
        get: {
          tags: ['Reports'],
          summary: 'Daily order chart data for period',
          parameters: [{ in: 'query', name: 'period', schema: { type: 'string', enum: ['today', 'week', 'month', 'year'], default: 'month' } }],
          responses: { 200: { description: 'Chart data array' } },
        },
      },
      '/reports/areas': {
        get: {
          tags: ['Reports'],
          summary: 'Orders grouped by governorate',
          parameters: [{ in: 'query', name: 'period', schema: { type: 'string', enum: ['today', 'week', 'month', 'year'], default: 'month' } }],
          responses: { 200: { description: 'Area stats' } },
        },
      },
      '/reports/drivers': {
        get: {
          tags: ['Reports'],
          summary: 'Orders grouped by driver',
          parameters: [{ in: 'query', name: 'period', schema: { type: 'string', enum: ['today', 'week', 'month', 'year'], default: 'month' } }],
          responses: { 200: { description: 'Driver stats' } },
        },
      },
      '/reports/time': {
        get: {
          tags: ['Reports'],
          summary: 'Orders grouped by hour of day',
          parameters: [{ in: 'query', name: 'period', schema: { type: 'string', enum: ['today', 'week', 'month', 'year'], default: 'month' } }],
          responses: { 200: { description: 'Hourly distribution' } },
        },
      },
      // ── Admin — Merchants ─────────────────────────────────────────────────
      '/admin/merchants': {
        get: {
          tags: ['Admin — Merchants'],
          summary: 'List all merchants',
          parameters: [
            { in: 'query', name: 'search', schema: { type: 'string' } },
            { in: 'query', name: 'isActive', schema: { type: 'boolean' } },
            { in: 'query', name: 'page', schema: { type: 'integer' } },
            { in: 'query', name: 'limit', schema: { type: 'integer' } },
          ],
          responses: { 200: { description: 'Paginated merchant list' }, 403: { description: 'Admin only' } },
        },
        post: {
          tags: ['Admin — Merchants'],
          summary: 'Create a merchant account',
          requestBody: {
            required: true,
            content: {
              'application/json': {
                schema: {
                  type: 'object',
                  required: ['phone', 'name', 'password'],
                  properties: {
                    phone: { type: 'string' },
                    name: { type: 'string' },
                    nameAr: { type: 'string' },
                    password: { type: 'string', minLength: 6 },
                    role: { type: 'string', enum: ['MERCHANT', 'ADMIN'] },
                  },
                },
              },
            },
          },
          responses: { 201: { description: 'Merchant created' }, 409: { description: 'Phone already exists' } },
        },
      },
      '/admin/merchants/{id}': {
        patch: {
          tags: ['Admin — Merchants'],
          summary: 'Update merchant name/phone',
          parameters: [{ in: 'path', name: 'id', required: true, schema: { type: 'string' } }],
          requestBody: { content: { 'application/json': { schema: { type: 'object', properties: { name: { type: 'string' }, nameAr: { type: 'string' }, phone: { type: 'string' } } } } } },
          responses: { 200: { description: 'Updated merchant' } },
        },
      },
      '/admin/merchants/{id}/status': {
        patch: {
          tags: ['Admin — Merchants'],
          summary: 'Toggle merchant active/inactive',
          parameters: [{ in: 'path', name: 'id', required: true, schema: { type: 'string' } }],
          responses: { 200: { description: 'Toggled status' } },
        },
      },
      // ── Admin — Orders ────────────────────────────────────────────────────
      '/admin/orders': {
        get: {
          tags: ['Admin — Orders'],
          summary: 'List ALL orders across all merchants',
          parameters: [
            { in: 'query', name: 'merchantId', schema: { type: 'string' } },
            { in: 'query', name: 'status', schema: { type: 'string', enum: ['PENDING', 'PROCESSING', 'IN_DELIVERY', 'DELIVERED', 'CANCELLED'] } },
            { in: 'query', name: 'search', schema: { type: 'string' } },
            { in: 'query', name: 'page', schema: { type: 'integer' } },
            { in: 'query', name: 'limit', schema: { type: 'integer' } },
            { in: 'query', name: 'from', schema: { type: 'string', format: 'date' } },
            { in: 'query', name: 'to', schema: { type: 'string', format: 'date' } },
          ],
          responses: { 200: { description: 'Paginated order list with merchant info' } },
        },
      },
      '/admin/orders/{id}': {
        get: {
          tags: ['Admin — Orders'],
          summary: 'Get any order by id',
          parameters: [{ in: 'path', name: 'id', required: true, schema: { type: 'string' } }],
          responses: { 200: { description: 'Order detail' }, 404: { description: 'Not found' } },
        },
      },
      '/admin/orders/{id}/status': {
        patch: {
          tags: ['Admin — Orders'],
          summary: 'Update any order status',
          parameters: [{ in: 'path', name: 'id', required: true, schema: { type: 'string' } }],
          requestBody: { required: true, content: { 'application/json': { schema: { type: 'object', required: ['status'], properties: { status: { type: 'string', enum: ['PENDING', 'PROCESSING', 'IN_DELIVERY', 'DELIVERED', 'CANCELLED'] }, note: { type: 'string' } } } } } },
          responses: { 200: { description: 'Updated' } },
        },
      },
      '/admin/orders/{id}/driver': {
        patch: {
          tags: ['Admin — Orders'],
          summary: 'Assign driver to order',
          parameters: [{ in: 'path', name: 'id', required: true, schema: { type: 'string' } }],
          requestBody: { required: true, content: { 'application/json': { schema: { type: 'object', required: ['driverName', 'driverPhone'], properties: { driverName: { type: 'string' }, driverNameAr: { type: 'string' }, driverPhone: { type: 'string' } } } } } },
          responses: { 200: { description: 'Driver assigned, status auto-advances to PROCESSING' } },
        },
      },
      // ── Admin — Stats ─────────────────────────────────────────────────────
      '/admin/stats': {
        get: {
          tags: ['Admin — Stats'],
          summary: 'Platform-wide statistics',
          responses: { 200: { description: 'Merchants count, orders by status, COD collected' } },
        },
      },
      // ── Areas ─────────────────────────────────────────────────────────────
      '/areas': {
        get: {
          tags: ['Areas'],
          summary: 'All Jordan governorates with areas (public)',
          security: [],
          responses: { 200: { description: 'List of governorates and their areas' } },
        },
      },
      '/areas/{governorate}': {
        get: {
          tags: ['Areas'],
          summary: 'Areas for a specific governorate',
          security: [],
          parameters: [{ in: 'path', name: 'governorate', required: true, schema: { type: 'string' }, example: 'Amman' }],
          responses: { 200: { description: 'Governorate with areas' }, 404: { description: 'Not found' } },
        },
      },
    },
  },
  apis: [],
};

export function setupSwagger(app: Express) {
  const spec = swaggerJsdoc(options);
  app.use('/api/docs', swaggerUi.serve, swaggerUi.setup(spec, { customSiteTitle: 'BazZ API Docs' }));
  app.get('/api/docs.json', (_req, res) => res.json(spec));
  console.log('📚 Swagger docs at /api/docs');
}
