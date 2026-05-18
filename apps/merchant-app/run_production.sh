#!/bin/bash
# Run the merchant app pointed at the PRODUCTION environment
echo "🚀 Starting merchant app → PRODUCTION (bazz-production.up.railway.app)"
flutter run --dart-define=API_URL=https://bazz-production.up.railway.app/api
