/**
 * Cloud Function to send chat notifications
 * Updated for Firebase Functions v2
 */
const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const {initializeApp} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");
const {getMessaging} = require("firebase-admin/messaging");
const logger = require("firebase-functions/logger");

// Initialize Firebase Admin SDK
initializeApp();

// Get references to Firebase services
const firestore = getFirestore();
const messaging = getMessaging();

// Cloud Function to send chat notifications
exports.sendChatNotification = onDocumentCreated(
  {
    document: "chatRooms/{chatRoomId}/messages/{messageId}",
    region: "us-central1", // Set your preferred region
  },
  async (event) => {
    try {
      // Get the document data and context
      const messageData = event.data && event.data.data();
      const chatRoomId = event.params.chatRoomId;
      const messageId = event.params.messageId;

      if (!messageData) {
        logger.error("No message data found");
        return;
      }

      // Extract the sender and recipient UIDs from the message data
      const senderUid = messageData.senderId;
      const recipientUid = messageData.receiverId;
      const messageText = messageData.text;

      logger.info("Processing message", {
        chatRoomId: chatRoomId,
        messageId: messageId,
        senderUid: senderUid,
        recipientUid: recipientUid,
        messageText: messageText,
      });

      // Validate required fields
      if (!senderUid || !recipientUid || !messageText) {
        logger.error("Missing required fields", {
          senderUid,
          recipientUid,
          messageText,
        });
        return;
      }

      // Do not send a notification if the sender and recipient are the same
      if (senderUid === recipientUid) {
        logger.info("Sender and recipient are the same, skipping notification");
        return;
      }

      // 1. Get the recipient's FCM token from Firestore
      let recipientToken;
      let recipientData;

      try {
        const recipientDoc = await firestore
          .collection("users")
          .doc(recipientUid)
          .get();

        if (!recipientDoc.exists) {
          logger.info("Recipient user document not found", {
            userId: recipientUid,
          });
          return;
        }

        recipientData = recipientDoc.data();
        recipientToken = recipientData.fcmToken;

        if (!recipientToken) {
          logger.info("Recipient does not have a valid FCM token", {
            userId: recipientUid,
          });
          return;
        }

        logger.info("Found recipient FCM token", {
          userId: recipientUid,
          tokenExists: !!recipientToken,
        });
      } catch (error) {
        logger.error("Error fetching recipient token:", error);
        return;
      }

      // 2. Get the sender's name for the notification
      let senderName = "Someone";
      try {
        const senderDoc = await firestore
          .collection("users")
          .doc(senderUid)
          .get();

        if (senderDoc.exists) {
          const senderData = senderDoc.data();
          senderName = senderData.name || "Someone";
        }
      } catch (error) {
        logger.error("Error fetching sender name:", error);
        // Continue with default name
      }

      // 3. Construct the notification message
      const message = {
        token: recipientToken,
        notification: {
          title: `New message from ${senderName}`,
          body: messageText.length > 100 ?
            messageText.substring(0, 100) + "..." :
            messageText,
        },
        data: {
          chatId: String(chatRoomId),
          senderId: String(senderUid),
          receiverId: String(recipientUid),
          type: "chat_message",
          click_action: "FLUTTER_NOTIFICATION_CLICK",
        },
        android: {
          notification: {
            channelId: "chat_notifications",
            priority: "high",
            defaultSound: true,
            defaultVibrateTimings: true,
            icon: "ic_notification",
          },
          data: {
            chatId: String(chatRoomId),
            senderId: String(senderUid),
            receiverId: String(recipientUid),
            type: "chat_message",
          },
        },
        apns: {
          payload: {
            aps: {
              alert: {
                title: `New message from ${senderName}`,
                body: messageText.length > 100 ?
                  messageText.substring(0, 100) + "..." :
                  messageText,
              },
              sound: "default",
              badge: 1,
            },
          },
          fcmOptions: {
            imageUrl: recipientData.imageUrl || undefined,
          },
        },
      };

      // 4. Send the notification using Firebase Admin SDK
      try {
        const response = await messaging.send(message);
        logger.info("Successfully sent message", {
          response: response,
          messageId: response,
        });

        return;
      } catch (error) {
        logger.error("Error sending message:", error);

        // Handle invalid token errors
        if (error.code === "messaging/invalid-argument" ||
            error.code === "messaging/registration-token-not-registered") {
          logger.info("Invalid token detected, removing from user document", {
            token: recipientToken,
            error: error.code,
          });

          try {
            await firestore.collection("users").doc(recipientUid).update({
              fcmToken: firestore.FieldValue.delete(),
            });
            logger.info("Removed invalid FCM token from user document");
          } catch (updateError) {
            logger.error("Error removing invalid token:", updateError);
          }
        }

        return;
      }
    } catch (error) {
      logger.error("Unexpected error in sendChatNotification:", error);
      return;
    }
  },
);

// Optional: Add a test function for manual testing
exports.testNotification = onDocumentCreated(
  {
    document: "test/{testId}",
    region: "us-central1",
  },
  async (event) => {
    logger.info("Test function triggered", {
      data: event.data && event.data.data(),
    });
    return;
  },
);

