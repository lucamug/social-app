import './main.css';
import * as _ from 'lodash'
import { db, auth, msging, storage } from './firebase.js'
import { Main } from './Main.elm';
import registerServiceWorker from './registerServiceWorker';
import idbKeyval from 'idb-keyval'
console.log('idb', idbKeyval)

var app = Main.fullscreen({ width: window.innerWidth, height: window.innerHeight });
registerServiceWorker();

let myUserId = null;
let unsubscribe = null;

app.ports.newUser.subscribe(async ({ username, email, password }) => {
  try {
    const uid = (await auth.createUserAndRetrieveDataWithEmailAndPassword(email, password)).user.uid
    const newUser = { username, photoUrlCouple: null, photoUrlHis: null, photoUrlHers: null }

    db.doc(`users/${uid}`).set(newUser)
    db.doc(`users/${uid}/profile/settings`).set({})
    db.doc(`users/${uid}/profile/base0`).set({})
    db.doc(`users/${uid}/profile/base1`).set({})
    db.doc(`users/${uid}/profile/base2`).set({})
    db.doc(`users/${uid}/profile/base3`).set({})
    db.doc(`users/${uid}/profile/base4`).set({})
    db.doc(`userNotifications/${uid}`).set({})

  } catch (error) {
    // TODO: Send back error to elm
    console.log('new_user_error', error.message)
  }
})

app.ports.getAllOtherUsers.subscribe(async () => {
  const userDocs = (await db.collection('users').get()).docs
  app.ports.usersReceived.send(userDocs
    .filter(doc => doc.id != myUserId)
    .map(
      doc => ({
        id: doc.id,
        username: doc.data().username,
        photoUrlCouple: doc.data().photoUrlCouple
      })
    ))
})

app.ports.listenToConvMetas.subscribe(() => {
  if (unsubscribe) {
    unsubscribe()
  }
  unsubscribe = db.collection('conversations').where(`members.${myUserId}.display`, '==', true).onSnapshot(snap => {
    const docs = snap.docs.map(doc => {
      doc = _.assign(doc.data(), { id: doc.id })
      doc.conversationOwner = Object.keys(doc.conversationOwner)[0]
      doc.members = _.map(doc.members, (member, key) => _.assign(member, { id: key }))
      return doc
    })
    app.ports.convsReceived.send(docs)

  })
})

app.ports.login.subscribe(({ email, password }) => {
  auth.signInAndRetrieveDataWithEmailAndPassword(email, password)
})

app.ports.logout.subscribe(() => {
  auth.signOut()
})

app.ports.createConversation.subscribe(async otherUserId => {
  // store conversation details record

  // first see if in a conversation

  const querySnap = await db.collection('conversations')
    .where(`members.${myUserId}.display`, '==', true)
    .where(`members.${otherUserId}.display`, '==', true).get()

  if (querySnap.docs.length) return


  const myUser = (await db.doc('users/' + myUserId).get()).data()
  const otherUser = (await db.doc('users/' + otherUserId).get()).data()

  const convDocRef = db.collection('conversations').doc()
  convDocRef.set({
    conversationOwner: { [myUserId]: true },
    conversationType: ['secret', 'public', 'privileged',],
    members: {
      [myUserId]: Object.assign({ display: true }, myUser),
      [otherUserId]: Object.assign({ display: true }, otherUser)
    },
    lastMessage: null
  })

  // add first message bundle and typers docs
  convDocRef.collection(`messageBundles`).add({ timestamp: firebase.firestore.FieldValue.serverTimestamp() })
  convDocRef.collection('extra').doc('typers').set({})

  // add conversation to user notifications
  db.doc(`userNotifications/${myUserId}`).update({ [`conversations.${convDocRef.id}`]: true, })
  // TODO:  cannot do this!!! make user only one who can update notifications
  db.doc(`userNotifications/${otherUserId}`).update({ [`conversations.${convDocRef.id}`]: true, })
})

auth.onAuthStateChanged(
  async user => {
    if (user) {
      // query database for my info.  Note:  __name__ is the key of the field in firestore
      myUserId = user.uid
      const me = _.assign({ id: user.uid }, (await db.collection('users').where('__name__', '==', user.uid).get()).docs[0].data())
      app.ports.loggedIn.send(me)
    } else {
      app.ports.loggedOut.send(null)
    }
  },
  error => { console.log('autherr') }
)