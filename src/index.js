import './main.css';
import {db, auth, msging, storage} from './firebase.js'
import { Main } from './Main.elm';
import registerServiceWorker from './registerServiceWorker';

var app = Main.fullscreen({ width: window.innerWidth, height: window.innerHeight });


registerServiceWorker();

app.ports.newUser.subscribe(({username, email, password}) => {
  auth.createUserAndRetrieveDataWithEmailAndPassword(email, password)
    .then(user =>{
      console.log(user)
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

      app.ports.loggedIn.send(uid)
    })
    .catch(error =>{
      // TODO: Send back error to elm
      console.log('error', error.message)
    })
})


app.ports.login.subscribe(({email, password}) => {
  auth.signInAndRetrieveDataWithEmailAndPassword(email, password)
    .then(user =>{
      app.ports.loggedIn.send(user.user.uid)
    })
    .catch(error =>{
      // TODO: Send back error to elm
      console.log('error', error.message)
    })
})

app.ports.logout.subscribe(_ => {
  auth.signOut()
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