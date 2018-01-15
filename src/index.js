import './main.css';
import {db, auth, msging, storage} from './firebase.js'
import { Main } from './Main.elm';
import registerServiceWorker from './registerServiceWorker';

// Main.embed(document.getElementById('root'));
var app = Main.fullscreen({ width: window.innerWidth, height: window.innerHeight });

registerServiceWorker();


app.ports.newUser.subscribe(({email, password}) => {
  auth.createUserAndRetrieveDataWithEmailAndPassword(email, password)
    .then(user =>{
      console.log(user)
      // app.ports.userRetrieved.send()
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