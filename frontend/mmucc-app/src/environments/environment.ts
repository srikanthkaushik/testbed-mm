export const environment = {
  production: false,

  // Backend services (proxied via proxy.conf.json in dev)
  authServiceUrl: '/auth',
  crashServiceUrl: '/crashes',

  // Firebase project configuration
  // Replace these values with your actual Firebase project settings.
  // See: https://firebase.google.com/docs/web/setup
  firebase: {
    apiKey: "AIzaSyCArZ8gSlSQkT-WYZzVutB1aDWmXTLq41I",
	authDomain: "mm5-test.firebaseapp.com",
	projectId: "mm5-test",
	storageBucket: "mm5-test.firebasestorage.app",
	messagingSenderId: "604687779949",
	appId: "1:604687779949:web:d6ca295c24e4a17d771764"
  },
};
