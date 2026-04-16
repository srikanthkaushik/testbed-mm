export const environment = {
  production: true,

  // In production, the Angular app is served behind the same origin as the
  // API gateway, so relative paths work without a proxy.
  authServiceUrl: '/auth',
  crashServiceUrl: '/crashes',
  referenceServiceUrl: '/lookups',
  reportServiceUrl:    '/reports',

  firebase: {
	  apiKey: "AIzaSyCArZ8gSlSQkT-WYZzVutB1aDWmXTLq41I",
	  authDomain: "mm5-test.firebaseapp.com",
	  projectId: "mm5-test",
	  storageBucket: "mm5-test.firebasestorage.app",
	  messagingSenderId: "604687779949",
	  appId: "1:604687779949:web:d6ca295c24e4a17d771764"
  },
};
