import './main.css';
import * as _ from 'lodash'
import idbKeyval from 'idb-keyval'
import moment from 'moment'

import { db, auth, msging, storage } from './firebase.js'
import { Main } from './Main.elm';
import registerServiceWorker from './registerServiceWorker';

console.log('idb', idbKeyval)

var app = Main.fullscreen({ width: window.innerWidth, height: window.innerHeight });
registerServiceWorker();

let myUserId = null
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
  unsubscribeFromConvsMeta = db.collection('conversations').where(`members.${myUserId}.display`, '==', true).onSnapshot(snap => {
    const docs = snap.docs.map(doc => {
      doc = _.assign(doc.data(), { id: doc.id })
      doc.conversationOwner = Object.keys(doc.conversationOwner)[0]
      doc.members = _.map(doc.members, (member, key) => _.assign(member, { id: key }))
      return doc
    })
    app.ports.convsMetaReceived.send(docs)

  })
})

app.ports.cancelConversation.subscribe(() => {
  unsubscribeFromConv()
  unsubscribeFromConv = null
  app.ports.messagesReceived.send(null)
})

app.ports.listenToConversation.subscribe(convId => {

  let numBundles = 2
  let latestBundleId = null
  // subscribe to firebase convSnaps
  function subscribeNumBundles(numBundles) {
    return db.collection(`conversations/${convId}/messageBundles`).orderBy('timestamp', 'desc').limit(numBundles).onSnapshot(snap => {
      const bundles = _.reverse(snap.docs)

      // if a new bundle was started, increment num bundles we're subscribe to
      if (latestBundleId && latestBundleId != _.last(bundles).id) {
        numBundles += 1
        unsubscribeFromConv()
        unsubscribeFromConv = subscribeNumBundles(numBundles)
      } else {
        const rawMsgs = _.flatMap(bundles, bundleDoc => _.map(bundleDoc.data().messages, (msg, id) => _.assign({ id }, msg)))
          .sort((a, b) => {
            if (a.timestamp == null) { return 1 }
            if (b.timestamp == null) { return -1 }
            return a.timestamp - b.timestamp
          })

        // update last message seen
        // const prevLastSeen = this.members[this.myId].lastMessageSeen
        // const lastMsg = rawMsgs.length ? _.last(rawMsgs).id : null
        // if(lastMsg && prevLastSeen != lastMsg) this.convRef.update({[`members.${this.myId}.lastMessageSeen`]: lastMsg})

        // LOOP: process messages add: 1. did I send, 2. who seen it and  3. if in a new day and sender compared to prev message
        const messages = rawMsgs.map((msg, index, msgs) => {
          msg.timestamp = msg.timestamp.getTime()

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
        console.log('messages', messages)
        app.ports.messagesReceived.send(messages)
      }
      latestBundleId = _.last(bundles).id
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
      const me = _.assign({ id: user.uid }, (await db.collection('users').where('__name__', '==', user.uid).get()).docs[0].data())
      app.ports.loggedIn.send(me)
    } else {
      app.ports.loggedOut.send(null)
    }
  },
  error => { console.log('autherr') }
)