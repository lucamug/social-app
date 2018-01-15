// import * as firebase from 'firebase'
// import 'firebase/firestore'

// initialize firebase
firebase.initializeApp(
  { apiKey: "AIzaSyDsVG_kHJs_5xUr4oByMftZdnyUZsWPYZw"
  , authDomain: "wysber-9cc6a.firebaseapp.com"
  , databaseURL: "https://wysber-9cc6a.firebaseio.com"
  , projectId: "wysber-9cc6a"
  , storageBucket: "wysber-9cc6a.appspot.com"
  , messagingSenderId: "422220864628"
  }
)

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
