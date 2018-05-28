const functions = require('firebase-functions');

// The Firebase Admin SDK to access the Firebase Realtime Database.
const admin = require('firebase-admin');
admin.initializeApp();

exports.observeFavorites = functions.database
  .ref('/recipes/{recipeID}/favoritedBy/{userID}')
  .onCreate((change, context) => {
    const recipeID = context.params.recipeID;
    const userID = context.params.userID;

    return admin
      .database()
      .ref('/recipes/' + recipeID)
      .once('value', snapshot => {
        const recipe = snapshot.val();

        return admin
          .database()
          .ref('/users/' + userID)
          .once('value', snapshot => {
            const user = snapshot.val();

            return admin
              .database()
              .ref('/users/' + recipe.creatorID)
              .once('value', snapshot => {
                const creator = snapshot.val();

                const newBadgeValue = creator.badgeCount + 1;

                admin
                  .database()
                  .ref('/users/' + recipe.creatorID + '/badgeCount')
                  .set(newBadgeValue);

                const notification = {
                  message:
                    user.username +
                    ' favorited your ' +
                    recipe.name +
                    ' recipe.',
                  recipeID: recipeID,
                  type: 'favorited',
                  photoURL: recipe.photoURL,
                  userID: userID
                };

                admin
                  .database()
                  .ref('/users/' + recipe.creatorID + '/notifications')
                  .push(notification);

                const payload = {
                  notification: {
                    title: '',
                    body:
                      user.username +
                      ' favorited your ' +
                      recipe.name +
                      ' recipe.',
                    badge: String(newBadgeValue)
                  },
                  data: {
                    recipeID: recipeID
                  }
                };

                admin
                  .messaging()
                  .sendToDevice(creator.notificationToken, payload)
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

                const notification = {
                  message:
                    reviewer.username +
                    ' cooked your ' +
                    reviewedRecipe.name +
                    ' recipe!',
                  recipeID: recipeID,
                  type: 'cooked',
                  photoURL: reviewedRecipe.photoURL,
                  userID: reviewerID
                };

                admin
                  .database()
                  .ref('/users/' + reviewedRecipe.creatorID + '/notifications')
                  .push(notification);

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
  .ref('/messages/{messageID}')
  .onCreate((snap, context) => {
    const messageID = context.params.messageID;
    const message = snap.val();

    const recipientID = message.toID;
    const senderID = message.fromID;

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

            const unreadMessagesCount = recipient.unreadMessagesCount + 1;

            admin
              .database()
              .ref('/users/' + recipientID + '/unreadMessagesCount')
              .set(unreadMessagesCount);

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
