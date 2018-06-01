const functions = require('firebase-functions');

// The Firebase Admin SDK to access the Firebase Realtime Database.
const admin = require('firebase-admin');
admin.initializeApp();

exports.observeWrittenReview = functions.database
  .ref('/reviews/{reviewID}/text')
  .onCreate((change, context) => {
    const reviewID = context.params.reviewID;

    const timestamp = new Date().getTime();

    return admin
      .database()
      .ref('/reviews/' + reviewID)
      .once('value', snapshot => {
        const review = snapshot.val();

        return admin
          .database()
          .ref('/users/' + review.reviewerID)
          .once('value', snapshot => {
            const reviewer = snapshot.val();

            return admin
              .database()
              .ref('/recipes/' + review.recipeID)
              .once('value', snapshot => {
                const recipe = snapshot.val();
                const creatorID = recipe.creatorID;

                return admin
                  .database()
                  .ref('/users/' + creatorID)
                  .once('value', snapshot => {
                    const creator = snapshot.val();

                    const newBadgeValue = creator.badgeCount + 1;

                    admin
                      .database()
                      .ref('/users/' + creatorID + '/badgeCount')
                      .set(newBadgeValue);

                    const notification = {
                      message:
                        reviewer.username +
                        ' wrote a review of your ' +
                        recipe.name +
                        ' recipe.',
                      recipeID: review.recipeID,
                      type: 'review',
                      photoURL: recipe.photoURL,
                      userID: review.reviewerID,
                      isUnread: true,
                      timestamp: timestamp
                    };

                    admin
                      .database()
                      .ref('/users/' + creatorID + '/notifications')
                      .push(notification);

                    const payload = {
                      notification: {
                        title: '',
                        body:
                          reviewer.username +
                          ' wrote a review of your ' +
                          recipe.name +
                          ' recipe.',
                        badge: String(newBadgeValue)
                      },
                      data: {
                        recipeID: review.recipeID
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
  });

exports.observeFavorites = functions.database
  .ref('/recipes/{recipeID}/favoritedBy/{userID}')
  .onCreate((change, context) => {
    const recipeID = context.params.recipeID;
    const userID = context.params.userID;

    const timestamp = new Date().getTime();

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
                  userID: userID,
                  isUnread: true,
                  timestamp: timestamp
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
    const timestamp = new Date().getTime();

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
                  userID: reviewerID,
                  isUnread: true,
                  timestamp: timestamp
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
