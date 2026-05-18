#!/bin/bash
# Run the merchant app pointed at the PILOT environment
echo "🧪 Starting merchant app → PILOT (bazz-pilot.up.railway.app)"
flutter run --dart-define=API_URL=https://bazz-pilot.up.railway.app/api
