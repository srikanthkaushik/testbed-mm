export const environment = {
  production: true,

  // In production, the Angular app is served behind the same origin as the
  // API gateway, so relative paths work without a proxy.
  authServiceUrl: '/auth',
  crashServiceUrl: '/crashes',
  referenceServiceUrl: '/lookups',
  reportServiceUrl:    '/reports',

  firebase: {
    apiKey:            'PROD_API_KEY',
    authDomain:        'PROD_PROJECT_ID.firebaseapp.com',
    projectId:         'PROD_PROJECT_ID',
    storageBucket:     'PROD_PROJECT_ID.appspot.com',
    messagingSenderId: 'PROD_MESSAGING_SENDER_ID',
    appId:             'PROD_APP_ID',
  },
};
