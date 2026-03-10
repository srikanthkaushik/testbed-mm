export const environment = {
  production: false,

  // Backend services (proxied via proxy.conf.json in dev)
  authServiceUrl: '/auth',
  crashServiceUrl: '/crashes',

  // Firebase project configuration
  // Replace these values with your actual Firebase project settings.
  // See: https://firebase.google.com/docs/web/setup
  firebase: {
    apiKey:            'YOUR_API_KEY',
    authDomain:        'YOUR_PROJECT_ID.firebaseapp.com',
    projectId:         'YOUR_PROJECT_ID',
    storageBucket:     'YOUR_PROJECT_ID.appspot.com',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    appId:             'YOUR_APP_ID',
  },
};
