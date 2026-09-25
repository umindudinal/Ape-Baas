const path = require('path');
const fs = require('fs');

let admin = null;
let firebaseApp = null;

try {
    admin = require('firebase-admin');
    const serviceAccountPath = path.join(__dirname, '../../config/firebase-service-account.json');

    if (fs.existsSync(serviceAccountPath)) {
        const serviceAccount = require(serviceAccountPath);
        firebaseApp = admin.initializeApp({
            credential: admin.credential.cert(serviceAccount)
        });
        console.log('🔥 Firebase Admin initialized with service account file.');
    } else if (process.env.FIREBASE_SERVICE_ACCOUNT) {
        const serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT);
        firebaseApp = admin.initializeApp({
            credential: admin.credential.cert(serviceAccount)
        });
        console.log('🔥 Firebase Admin initialized with ENV credentials.');
    } else {
        console.warn('⚠️ Firebase service account file not found. Push notifications will activate once firebase-service-account.json is added.');
    }
} catch (error) {
    if (error.code === 'MODULE_NOT_FOUND') {
        console.warn("⚠️ 'firebase-admin' package is not installed yet. Run 'npm install' in backend terminal.");
    } else {
        console.error('❌ Failed to initialize Firebase Admin:', error.message);
    }
}

/**
 * Send FCM Push Notification to a single device token
 */
const sendPushNotification = async (fcmToken, title, body, data = {}) => {
    if (!admin || !firebaseApp || !fcmToken) {
        if (!fcmToken) console.log('ℹ️ Push notification skipped: Target user has no fcm_token.');
        return false;
    }

    try {
        const message = {
            token: fcmToken,
            notification: {
                title: title,
                body: body,
            },
            data: data,
            android: {
                priority: 'high',
                notification: {
                    sound: 'default',
                    channelId: 'high_importance_channel',
                },
            },
            apns: {
                payload: {
                    aps: {
                        sound: 'default',
                    },
                },
            },
        };

        const response = await admin.messaging().send(message);
        console.log('✉️ Push Notification sent successfully:', response);
        return true;
    } catch (error) {
        console.error('❌ Error sending FCM Push Notification:', error.message);
        return false;
    }
};

module.exports = {
    sendPushNotification,
    admin
};
