// Please see this file for the latest firebase-js-sdk version:
// https://github.com/firebase/flutterfire/blob/master/packages/firebase_core/firebase_core_web/lib/src/firebase_sdk_version.dart
importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "AIzaSyBpS5SLEllgLbnghtAT6JEH7UMnQ-Tmjz4",
  authDomain: "psa-academy-65088.firebaseapp.com",
  projectId: "psa-academy-65088",
  storageBucket: "psa-academy-65088.firebasestorage.app",
  messagingSenderId: "353959379596",
  appId: "1:353959379596:web:9e2db8c46070672e6f71a9",
});

const messaging = firebase.messaging();

// Optional:
messaging.onBackgroundMessage((message) => {
  console.log("onBackgroundMessage", message);
});