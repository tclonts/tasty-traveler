const functions = require('firebase-functions');

// The Firebase Admin SDK to access the Firebase Realtime Database.
const admin = require('firebase-admin');
admin.initializeApp();

// Listen for new reviews and then trigger a push notification
exports.observeReviews = functions.database
  .ref('/recipes/{recipeID}/reviews/{reviewerID}')
  .onCreate((change, context) => {
    const recipeID = context.params.recipeID;
    const reviewerID = context.params.reviewerID;

    console.log(recipeID);
    return admin
      .database()
      .ref('/recipes/' + recipeID)
      .once('value', snapshot => {
        const reviewedRecipe = snapshot.val();

        return admin
          .database()
          .ref('/users/' + reviewerID)
          .once('value', snapshot => {
            const reviewer = snapshot.val();

            return admin
              .database()
              .ref('/users/' + reviewedRecipe.creatorID)
              .once('value', snapshot => {
                const recipeCreator = snapshot.val();

                const newBadgeValue = recipeCreator.badgeCount + 1;

                admin
                  .database()
                  .ref('/users/' + reviewedRecipe.creatorID + '/badgeCount')
                  .set(newBadgeValue);

                const payload = {
                  notification: {
                    title: '',
                    body:
                      reviewer.username +
                      ' cooked your ' +
                      reviewedRecipe.name +
                      ' recipe!',
                    badge: String(newBadgeValue)
                  },
                  data: {
                    recipeID: recipeID
                  }
                };

                admin
                  .messaging()
                  .sendToDevice(recipeCreator.notificationToken, payload)
                  .then(response => {
                    console.log('Successfully sent message: ', response);
                    return null;
                  })
                  .catch(error => {
                    console.log('Error sending message: ', error);
                  });
              });
          });
      });
  });

// Listen for new messages and then trigger a push notification
exports.observeMessages = functions.database
  .ref('/userMessages/{recipientID}/{senderID}/{messageID}')
  .onCreate((change, context) => {
    const recipientID = context.params.recipientID;
    const senderID = context.params.senderID;
    const messageID = context.params.messageID;

    return admin
      .database()
      .ref('/messages/' + messageID)
      .once('value', snapshot => {
        const message = snapshot.val();

        return admin
          .database()
          .ref('/users/' + recipientID)
          .once('value', snapshot => {
            const recipient = snapshot.val();

            return admin
              .database()
              .ref('/users/' + senderID)
              .once('value', snapshot => {
                const sender = snapshot.val();

                const newBadgeValue = recipient.badgeCount + 1;

                admin
                  .database()
                  .ref('/users/' + recipientID + '/badgeCount')
                  .set(newBadgeValue);

                const payload = {
                  notification: {
                    title: '',
                    body: sender.username + ' sent you a message.',
                    badge: String(newBadgeValue)
                  },
                  data: {
                    recipeID: message.recipeID,
                    withUserID: senderID
                  }
                };

                admin
                  .messaging()
                  .sendToDevice(recipient.notificationToken, payload)
                  .then(response => {
                    console.log('Successfully sent message: ', response);
                    return null;
                  })
                  .catch(error => {
                    console.log('Error sending message: ', error);
                  });
              });
          });
      });
  });
