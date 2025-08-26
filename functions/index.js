// index.js

/**
 * The core `firebase-functions` module is used for triggers.
 * `firebase-admin` is used to interact with Firestore and other
 * Firebase services.
 */
const functions = require("firebase-functions/v1");
const admin = require("firebase-admin");

// These are from your original boilerplate, used for configuration and
// logging.
const {setGlobalOptions} = require("firebase-functions");
const logger = require("firebase-functions/logger");

// Initialize Firebase Admin SDK
// This is required to access Firestore and send messages
admin.initializeApp();

// Get a reference to the Firestore database
const firestore = admin.firestore();

// Set global options for cost control and performance.
// The maxInstances limit is a per-function limit.
setGlobalOptions({maxInstances: 10});

// Our custom Cloud Function to send chat notifications
// It triggers whenever a new message is written to Firestore.
exports.sendChatNotification = functions.firestore
    .document("chatRooms/{chatRoomId}/messages/{messageId}")
    .onCreate(async (snapshot, context) => {
      const messageData = snapshot.data();
      const {chatId} = context.params;

      // Extract the sender and recipient UIDs from the message data.
      const senderUid = messageData.senderId;
      const recipientUid = messageData.receiverId;
      const messageText = messageData.text;

      // Do not send a notification if the sender and recipient are the same.
      if (senderUid === recipientUid) {
        return null;
      }

      // 1. Get the recipient's FCM token from Firestore.
      let recipientToken;
      try {
        const recipientDoc =
          await firestore.collection("users").doc(recipientUid).get();
        if (!recipientDoc.exists) {
          logger.info("Recipient user document not found.",
              {userId: recipientUid});
          return null;
        }
        recipientToken = recipientDoc.data().fcmToken;
        if (!recipientToken) {
          logger.info(
              "Recipient does not have a valid FCM token.",
              {userId: recipientUid},
          );
          return null;
        }
      } catch (error) {
        logger.error("Error fetching recipient token:", error);
        return null;
      }

      // 2. Get the sender's name for the notification.
      let senderName = "A new message";
      try {
        const senderDoc =
          await firestore.collection("users").doc(senderUid).get();
        if (senderDoc.exists) {
          senderName = senderDoc.data().name || "A new message";
        }
      } catch (error) {
        logger.error("Error fetching sender name:", error);
      }

      // 3. Construct the notification payload.
      const payload = {
        notification: {
          title: `New message from ${senderName}`,
          body: messageText,
        },
        data: {
          chatId: String(chatId),
          senderId: String(senderUid),
        },
      };

      // 4. Send the notification using the Firebase Admin SDK.
      try {
        const response =
    await admin.messaging().sendToDevice(recipientToken, payload);
        logger.info("Successfully sent message:", {response});

        // Check for invalid tokens and remove them.
        const invalidTokens = [];
        response.results.forEach((result) => {
          const error = result.error;
          if (error && (
            error.code === "messaging/invalid-registration-token" ||
        error.code === "messaging/registration-token-not-registered"
          )) {
            invalidTokens.push(recipientToken);
          }
        });

        if (invalidTokens.length > 0) {
          logger.info(`Removing ${invalidTokens.length} invalid tokens.`);
        }

        return null;
      } catch (error) {
        logger.error("Error sending message:", error);
        return null;
      }
    });
