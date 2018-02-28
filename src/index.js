import './main.css';
import map from 'lodash/fp/map'
import filter from 'lodash/fp/filter'
import reverse from 'lodash/fp/reverse'
import last from 'lodash/fp/last'
import flow from 'lodash/fp/flow'
import flatMap from 'lodash/fp/flatMap'
import assign from 'lodash/fp/assign'
import merge from 'lodash/fp/merge'
import keyBy from 'lodash/fp/keyBy'
import idbKeyval from 'idb-keyval'
import moment from 'moment'

import { db, auth, msging, storage } from './firebase.js'
import { Main } from './Main.elm';
import registerServiceWorker from './registerServiceWorker';

// console.log('idb', idbKeyval)

var app = Main.fullscreen({ width: window.innerWidth, height: window.innerHeight });
registerServiceWorker();

let myUserId = null
let myUserInfo = null
let unsubscribeFromConv = null
let unsubscribeFromConvsMeta = null

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
  console.log('userDocs', userDocs)
  let userDict =
    flow(
      filter(doc => doc.id != myUserId),
      map(doc => (assign({ id: doc.id }, doc.data()))),
      keyBy(doc => doc.id)
    )
      (userDocs)
  console.log('ud', userDict)

  app.ports.usersReceived.send(userDict)
})




app.ports.listenToConvMetas.subscribe(async () => {
  unsubscribeFromConvsMeta = db.collection('conversations').where(`members.${myUserId}.display`, '==', true).onSnapshot(snap => {
    let docs = snap.docs.map(doc => {
      const data = doc.data()
      data.conversationOwner = Object.keys(data.conversationOwner)[0]
      data.id = doc.id
      return data
    })
    docs = keyBy(doc => doc.id)(docs)
    console.log('doc', docs)
    app.ports.convsMetaReceived.send(docs)

  })
})





app.ports.cancelConversation.subscribe(() => {
  unsubscribeFromConv()
  unsubscribeFromConv = null
})




app.ports.listenToMessages.subscribe(convId => {

  let numBundles = 2
  let latestBundleId = null
  // subscribe to firebase convSnaps
  function subscribeNumBundles(numBundles) {
    return db.collection(`conversations/${convId}/messageBundles`).orderBy('timestamp', 'desc').limit(numBundles).onSnapshot(snap => {
      const bundles = snap.docs

      // if a new bundle was started, increment num bundles we're subscribe to
      if (latestBundleId && latestBundleId != bundles[0].id) {
        numBundles += 1
        unsubscribeFromConv()
        unsubscribeFromConv = subscribeNumBundles(numBundles)
      } else {
        let messTup = map(bundleDoc => [bundleDoc.id, bundleDoc.data().messages])(bundles)
        let rawMsgs = flatMap(([bundleId, messages]) => map.convert({ 'cap': false })((message, id) => assign({ bundleId, id }, message))(messages))(messTup)
          .sort((a, b) => {
            if (a.timestamp == null) { return 1 }
            if (b.timestamp == null) { return -1 }
            return a.timestamp - b.timestamp
          })


        // update last message seen
        // const prevLastSeen = this.members[this.myId].lastMessageSeen
        // const lastMsg = rawMsgs.length ? _.last(rawMsgs).id : null
        // if(lastMsg && prevLastSeen != lastMsg) this.convRef.update({[`members.${this.myId}.lastMessageSeen`]: lastMsg})

        // LOOP: process messages add: 1. isNewSender, 2. isNewDay 
        const messages = rawMsgs.map((msg, index, msgs) => {

          const prevMsg = msgs[index - 1]
          if (!prevMsg) {
            msg.isNewSender = true
            msg.isNewDay = true
          } else {
            msg.isNewSender = msg.userId != prevMsg.userId

            const curr = moment(msg.timestamp)
            const prev = moment(prevMsg.timestamp)
            msg.isNewDay = `${curr.dayOfYear()}${curr.year()}` != `${prev.dayOfYear()}${prev.year()}`
          }
          return msg
        })
        app.ports.messagesReceived.send({ convId, messages })
      }
      latestBundleId = bundles[0].id
    })
  }

  unsubscribeFromConv = subscribeNumBundles(numBundles)

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
      myUserInfo = (await db.collection('users').where('__name__', '==', myUserId).get()).docs[0].data()
      app.ports.loggedIn.send({ myUserId, myUserInfo })

    } else {
      app.ports.loggedOut.send(null)
    }
  },
  error => { console.log('autherr') }
)