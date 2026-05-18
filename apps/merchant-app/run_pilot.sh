#!/bin/bash
# Run the merchant app pointed at the PILOT environment on your iPhone (wireless)
echo "🧪 Starting merchant app → PILOT (bazz-pilot.up.railway.app)"
flutter run \
  -d 00008150-000228A90AB8401C \
  --dart-define=API_URL=https://bazz-pilot.up.railway.app/api
