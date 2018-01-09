importScripts('https://www.gstatic.com/firebasejs/3.9.0/firebase-app.js');
importScripts('https://www.gstatic.com/firebasejs/3.9.0/firebase-messaging.js');

const CACHE_NAME = new Date().toISOString()
const DEBUG = false

const { assets } = global.serviceWorkerOption
let assetsToCache = [...assets, './']

assetsToCache = assetsToCache.map(path => {
  return new URL(path, global.location).toString()
})

firebase.initializeApp(
  {
    apiKey: "AIzaSyAg5qG6IY9-1mlWqy-UG9ZntRhk9VCOB_0",
    authDomain: "whisber-547f1.firebaseapp.com",
    databaseURL: "https://whisber-547f1.firebaseio.com",
    projectId: "whisber-547f1",
    storageBucket: "whisber-547f1.appspot.com",
    messagingSenderId: "627883058975"
  })

const messaging = firebase.messaging()

self.addEventListener('install', event => {
  console.log('installing service worker...')
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then(cache => {
        try{
          cache.addAll(assetsToCache)
        }catch(err){
          console.log('error', err)
        }
      })
  )
})
// After the install event.
self.addEventListener('activate', event => {
  if (DEBUG) {
    console.log('[SW] Activate event')
  }

  // Clean the caches
  event.waitUntil(
    global.caches.keys().then(cacheNames => {
      return Promise.all(
        cacheNames.map(cacheName => {
          // Delete the caches that are not the current one.
          if (cacheName.indexOf(CACHE_NAME) === 0) {
            return null
          }

          return global.caches.delete(cacheName)
        })
      )
    })
  )
})// After the install event.

self.addEventListener('fetch', event => {
  const request = event.request


  // Ignore not GET request.
  if (request.method !== 'GET') {
    if (DEBUG) {
      console.log(`[SW] Ignore non GET request ${request.method}`)
    }
    return
  }

  const requestUrl = new URL(request.url)

  // Ignore difference origin.
  // if (requestUrl.origin !== location.origin) {
  //   if (DEBUG) {
  //     console.log(`[SW] Ignore difference origin ${requestUrl.origin}`)
  //   }
  //   return
  // }

  const resource = global.caches.match(request).then(response => {
    if (response) {
      if (DEBUG) {
        console.log(`[SW] fetch URL ${requestUrl.href} from cache`)
      }

      return response
    }

    // Load and cache known assets.
    return fetch(request)
      .then(responseNetwork => {
        // if (!responseNetwork || !responseNetwork.ok) {
        //   if (DEBUG) {
        //     console.log(
        //       `[SW] URL [${requestUrl.toString()}] wrong responseNetwork: ${responseNetwork.status} ${responseNetwork.type}`
        //     )
        //   }

        //   return responseNetwork
        // }

        if (DEBUG) {
          console.log(`[SW] URL ${requestUrl.href} fetched`)
        }

        const responseCache = responseNetwork.clone()

        global.caches
          .open(CACHE_NAME)
          .then(cache => {
            return cache.put(request, responseCache)
          })
          .then(() => {
            if (DEBUG) {
              console.log(`[SW] Cache asset: ${requestUrl.href}`)
            }
          })

        return responseNetwork
      })
      .catch(() => {
        // User is landing on our page.
        if (event.request.mode === 'navigate') {
          return global.caches.match('./')
        }

        return null
      })
  })

  event.respondWith(resource)
})
