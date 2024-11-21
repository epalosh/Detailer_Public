/* 

Code by Ethan Palosh for the iOS App "Detailer"

This file contains the 3 primary cloud functions for the app. They are deployed on Google Cloud servers.

  - These funtions detect new notification requests in the database, and securely execute them.
  - Notification types are "new message", "new connection", and "new comment"
  - Push-notifications are executed, and then requests are deleted from the associated database bucket.

Published for portfolio purposes only.

*/

const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const {getFirestore} = require("firebase-admin/firestore");
const {getMessaging} = require("firebase-admin/messaging");
const {initializeApp} = require("firebase-admin/app");

initializeApp();

exports.sendNewMessageNotification2 =
onDocumentCreated("newMessageNotifs/{docId}",
    async (event) => {
      const data = event.data.data();
      const docId = event.params.docId;

      console.log("New document added:", data);

      const message = {
        notification: {
          title: `📨 - New Message!`,
          body:
            `You have received a message from ` +
            `${data.senderNickname}.`,
        },
        token: "", // Placeholder for the user's FCM token, added below.
        android: {
          notification: {
            sound: "default",
            priority: "high",
          },
        },
        apns: {
          payload: {
            aps: {
              sound: "default",
              badge: 1,
            },
          },
        },
      };

      const userId = data.toUID; // Assuming the document has a toUID
      const userDoc = getFirestore().collection("user-data").doc(userId);

      try {
        const doc = await userDoc.get();
        if (doc.exists) {
          const user = doc.data();
          const token = user.fcmToken; // Assuming the document has an fcmToken

          if (token) {
            console.log("Sending notification to token:", token);

            // Set the token in the message object
            message.token = token;

            // Send the message
            const response = await getMessaging().send(message);
            console.log("Successfully sent message:", response);

            // Delete the document after sending the notification
            await getFirestore().collection(
                "newMessageNotifs").doc(docId).delete();
            console.log("Document deleted:", docId);
          } else {
            console.log("No FCM token for user:", userId);
          }
        } else {
          console.log("No user document for user:", userId);
        }
      } catch (error) {
        console.error("Error getting user document:", error);
      }
    });

exports.sendNewConnectionNotification2 =
onDocumentCreated("newConnectionNotifs/{docId}",
    async (event) => {
      const data = event.data.data();
      const docId = event.params.docId;

      console.log("New document added:", data);

      const message = {
        notification: {
          title: `👥 - New connection request!`,
          body: `${data.senderNickname} wants ` +
          `to connect with you! Open the app to accept.`,
        },
        token: "", // Placeholder for the user's FCM token, added below
        android: {
          notification: {
            sound: "default",
            priority: "high",
          },
        },
        apns: {
          payload: {
            aps: {
              sound: "default",
              badge: 1,
            },
          },
        },
      };

      const userId = data.toUID; // Assuming the document has a toUID
      const userDoc = getFirestore().collection("user-data").doc(userId);

      try {
        const doc = await userDoc.get();
        if (doc.exists) {
          const user = doc.data();
          const token = user.fcmToken; // Assuming the document has an fcmToken

          if (token) {
            console.log("Sending notification to token:", token);

            // Set the token in the message object
            message.token = token;

            // Send the message
            const response = await getMessaging().send(message);
            console.log("Successfully sent message:", response);

            // Delete the document after sending the notification
            await getFirestore().collection(
                "newConnectionNotifs").doc(docId).delete();
            console.log("Document deleted:", docId);
          } else {
            console.log("No FCM token for user:", userId);
          }
        } else {
          console.log("No user document for user:", userId);
        }
      } catch (error) {
        console.error("Error getting user document:", error);
      }
    });

exports.sendNewCommentNotification2 =
onDocumentCreated("newCommentNotifs/{docId}",
    async (event) => {
      const data = event.data.data();
      const docId = event.params.docId;

      console.log("New document added:", data);

      const message = {
        notification: {
          title: `💬 - New comment!`,
          body: `${data.senderNickname} left a comment.`,
        },
        token: "", // Placeholder for the user's FCM token, added below
        android: {
          notification: {
            sound: "default",
            priority: "high",
          },
        },
        apns: {
          payload: {
            aps: {
              sound: "default",
              badge: 1,
            },
          },
        },
      };

      const userId = data.toUID; // Assuming the document has a toUID
      const userDoc = getFirestore().collection("user-data").doc(userId);

      try {
        const doc = await userDoc.get();
        if (doc.exists) {
          const user = doc.data();
          const token = user.fcmToken; // Assuming the document has an fcmToken

          if (token) {
            console.log("Sending notification to token:", token);

            // Set the token in the message object
            message.token = token;

            // Send the message
            const response = await getMessaging().send(message);
            console.log("Successfully sent message:", response);

            // Delete the document after sending the notification
            await getFirestore().collection(
                "newCommentNotifs").doc(docId).delete();
            console.log("Document deleted:", docId);
          } else {
            console.log("No FCM token for user:", userId);
          }
        } else {
          console.log("No user document for user:", userId);
        }
      } catch (error) {
        console.error("Error getting user document:", error);
      }
    });