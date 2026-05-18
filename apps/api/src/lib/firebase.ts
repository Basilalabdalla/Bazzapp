import admin from 'firebase-admin';

let initialized = false;

export function initFirebase() {
  if (initialized || !process.env.FIREBASE_SERVICE_ACCOUNT_JSON) {
    if (!process.env.FIREBASE_SERVICE_ACCOUNT_JSON) {
      console.warn('⚠️  FIREBASE_SERVICE_ACCOUNT_JSON not set — push notifications disabled');
    }
    return;
  }

  try {
    const serviceAccount = JSON.parse(
      Buffer.from(process.env.FIREBASE_SERVICE_ACCOUNT_JSON, 'base64').toString('utf-8'),
    );
    admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });
    initialized = true;
    console.log('🔥 Firebase Admin initialized');
  } catch (err) {
    console.error('❌ Firebase init failed:', err);
  }
}

export async function sendPushNotification(fcmToken: string, title: string, body: string, data?: Record<string, string>) {
  if (!initialized) return;

  try {
    await admin.messaging().send({
      token: fcmToken,
      notification: { title, body },
      data,
      android: { priority: 'high' },
      apns: { payload: { aps: { sound: 'default' } } },
    });
  } catch (err) {
    console.error('FCM send error:', err);
  }
}
