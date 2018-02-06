import './main.css';
import {db, auth, msging, storage} from './firebase.js'
import { Main } from './Main.elm';
import registerServiceWorker from './registerServiceWorker';

var app = Main.fullscreen({ width: window.innerWidth, height: window.innerHeight });
registerServiceWorker();

app.ports.newUser.subscribe(({username, email, password}) => {
  auth.createUserAndRetrieveDataWithEmailAndPassword(email, password)
    .then(user =>{
      const uid = user.user.uid
      const newUser = {username,
        defaultPhotoUrls:{couple: null,
                          his: null,
                          hers: null}}

      db.doc(`users/${uid}`).set(newUser)
      db.doc(`users/${uid}/profile/settings`).set({})
      db.doc(`users/${uid}/profile/base0`).set({})
      db.doc(`users/${uid}/profile/base1`).set({})
      db.doc(`users/${uid}/profile/base2`).set({})
      db.doc(`users/${uid}/profile/base3`).set({})
      db.doc(`users/${uid}/profile/base4`).set({})
      db.doc(`userNotifications/${uid}`).set({})

      app.ports.loggedIn.send(uid)                 //  TO ELM
    })
    .catch(error =>{
      // TODO: Send back error to elm
      console.log('error', error.message)
    })
})

app.ports.getAllUsers.subscribe(() => {
  db.collection('users').get().then(snapshot => {
    const users = snapshot.docs.map(doc => {
      const user = {
        id: doc.id, 
        username: doc.data().username,
        photoUrl: doc.data().defaultPhotoUrls.couple
      }
      console.log('user', user)
      return user
    })

    app.ports.usersReceived.send(users)

  })

})

app.ports.login.subscribe(({email, password}) => {
  auth.signInAndRetrieveDataWithEmailAndPassword(email, password)
    .then(user =>{
      app.ports.loggedIn.send(user.user.uid)      // TO ELM
    })
    .catch(error =>{
      // TODO: Send back error to elm
      console.log('error', error.message)
    })
})

app.ports.logout.subscribe( _ => {
  auth.signOut()
})

app.ports.createConversation.subscribe(({myUserId, otherUserId}) =>{
   // store conversation details record
   const convDocRef = db.collection('conversations').doc()
   convDocRef.set({
     conversatonOwner: { [myUserId] : true },
     conversationType: ['secret', 'public', 'privileged', ],
     members: {
       [myUserId] : Object.assign({display: true}, myUserId),
       [otheruser.id] : Object.assign({display: true}, otherUserId)
     },
     lastMessage : {content: '', timestamp: 0}
   })

   // add first message bundle and typers docs
   convDocRef.collection(`messageBundles`).add({timestamp: firebase.firestore.FieldValue.serverTimestamp()})
   convDocRef.collection('extra').doc('typers').set({})

   // add conversation to user notifications
   db.doc(`userNotifications/${myUserId}`).update({ [`conversations.${convDocRef.id}`]: true, })
   // TODO:  cannot do this!!! make user only one who can update notifications
   db.doc(`userNotifications/${otherUserId}`).update({ [`conversations.${convDocRef.id}`]: true, })
})


auth.onAuthStateChanged(
  user => {
    if (user)
      app.ports.loggedIn.send(user.uid)
    else 
      app.ports.loggedOut.send("")
  },
  error => {}
)