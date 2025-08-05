// sqflite_sw.js - https://github.com/tekartik/sqflite/blob/master/packages_web/sqflite_common_ffi_web/assets/sqflite_sw.js

self.importScripts('https://unpkg.com/idb@7/build/umd.js');

const DB_NAME = 'sqflite_ffi_web';
const STORE_NAME = 'sqflite';

self.addEventListener('install', function(event) {
  self.skipWaiting();
});

self.addEventListener('activate', function(event) {
  event.waitUntil(self.clients.claim());
});

self.addEventListener('fetch', function(event) {
  // This service worker does not handle fetch events
});

// Listen for messages from the main thread
self.addEventListener('message', async function(event) {
  const { command, dbName, storeName, key, value } = event.data;
  if (command === 'put') {
    const db = await idb.openDB(DB_NAME, 1, {
      upgrade(db) {
        db.createObjectStore(STORE_NAME);
      },
    });
    await db.put(STORE_NAME, value, key);
    db.close();
    event.ports[0].postMessage({ result: true });
  } else if (command === 'get') {
    const db = await idb.openDB(DB_NAME, 1, {
      upgrade(db) {
        db.createObjectStore(STORE_NAME);
      },
    });
    const result = await db.get(STORE_NAME, key);
    db.close();
    event.ports[0].postMessage({ result });
  } else if (command === 'delete') {
    const db = await idb.openDB(DB_NAME, 1, {
      upgrade(db) {
        db.createObjectStore(STORE_NAME);
      },
    });
    await db.delete(STORE_NAME, key);
    db.close();
    event.ports[0].postMessage({ result: true });
  }
}); 