#!/bin/bash
# Run the merchant app pointed at the PRODUCTION environment on your iPhone (wireless)
echo "🚀 Starting merchant app → PRODUCTION (api.bazzmarket.com)"
flutter run \
  -d 00008150-000228A90AB8401C \
  --dart-define=API_URL=https://api.bazzmarket.com/api
