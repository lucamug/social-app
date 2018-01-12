import * as firebase from 'firebase'
import 'firebase/firestore'


// initialize firebase
firebase.initializeApp(
  {
    apiKey: "AIzaSyAg5qG6IY9-1mlWqy-UG9ZntRhk9VCOB_0",
    authDomain: "whisber-547f1.firebaseapp.com",
    databaseURL: "https://whisber-547f1.firebaseio.com",
    projectId: "whisber-547f1",
    storageBucket: "whisber-547f1.appspot.com",
    messagingSenderId: "627883058975"
  })

  firebase.firestore().enablePersistence()
  .then(() => {
      // Initialize Cloud Firestore through firebase
      // console.log('enabled?')
  })
  .catch((err) => {
      if (err.code == 'failed-precondition') {
          // Multiple tabs open, persistence can only be enabled
          // in one tab at a a time.
          // ...
      } else if (err.code == 'unimplemented') {
          // The current browser does not support all of the
          // features required to enable persistence
          // ...
      }
  });

export const db = firebase.firestore()
export const auth = firebase.auth()
export const msging = firebase.messaging()
export const storage = firebase.storage()
