const functions = require('firebase-functions');
// Import and initialize the Firebase Admin SDK.
const admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);
const db = admin.firestore()
var _ =  require( 'lodash')

// exports.sdfnNotification = functions.firestore.document('/conversations/{conversationId}/extraDocs/pendingUsers').onUpdate(event =>{
//   const conversationId = event.params.conversationId
//   const pendingUsers = event.data.data()

// })
// Sends a notifications to all users when a new message is posted.
exports.sendNotification = functions.firestore.document('/conversations/{conversationId}/messageBundles/{bundleId}').onUpdate(event =>{
  const conversationId = event.params.conversationId
  const messages = _.sortBy(event.data.data().messages, 'timestamp')

  if(messages.length >= 100) db.collection(`conversations/${conversationId}/messageBundles`).add({timestamp: admin.firestore.FieldValue.serverTimestamp()})

  const message = _.last(messages)
  const text = message.content
  let username = null
  let userOfToken = {}

  // get tokens for this conversation and package message
  return db.doc(`users/${message.userId}`).get()
    // get username then query for tokens
    .then(snap =>{
      username = snap.data().username
      return db.collection('userNotifications').where(`conversations.${conversationId}`, '==', true).get()
    })
    .then(querySnap =>{
      // build userOfToken object where each member is: token:uid
      querySnap.forEach(snap =>{
        const userId = snap.id
        if(userId != message.userId){
          Object.keys(snap.data().tokens).forEach(token => {userOfToken[token] = userId})
        }
      })
      const tokens = Object.keys(userOfToken)
      const payload = {
        notification: {
          title: `${username} posted a message`,
          tag: username,
          body: text.length <= 100 ? text : text.substring(0, 97) + '...',
          // icon: snapshot.val().photoUrl || '/images/profile_placeholder.png',
          // click_action: `https://${functions.config().firebase.authDomain}/conversations/${conversationId}`
          click_action: `https://whisber.com/conversations/${conversationId}`
        }
      }
      // send message
      return admin.messaging().sendToDevice(tokens, payload, {collapse_key: 'collapse_high', priority: 'high'})

    })
    .then(response => {
      // For each message check if there was an error.
      let updates = {}
      let promises = []
      response.results.forEach((result, index) => {
        const error = result.error;
        if (error) {
          console.error('Failure sending notification to', tokens[index], error);
          // Cleanup the tokens who are not registered anymore.
          if (error.code === 'messaging/invalid-registration-token' ||
              error.code === 'messaging/registration-token-not-registered') {
            const token = tokens[index]
            const uid = userOfToken[token]
            promises.push(
              db.doc(`userNotifications/${uid}`).update({
                [`tokens.${token}`] : admin.firestore.FieldValue.delete() })
            )
          }
        }
      });
      return Promise.all(promises)
    })
})
