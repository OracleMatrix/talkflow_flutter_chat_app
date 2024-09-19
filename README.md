# TalkFlow Chat App(Real-Time)

A real-time chat application built with Flutter and Firebase.

## Features

* **Real-time messaging:** Send and receive messages in real-time using Firebase Firestore.
* **User authentication:** Authenticate users using Firebase Authentication.
* **User profiles:** View and edit user profiles, including profile pictures and display names.
* **Friend system:** Add and manage friends, and view their profiles.
* **Chat rooms:** Create and join chat rooms with friends.
* **Media sharing:** Share images and other media files in chat rooms.
* **Settings:** View and edit app settings, including theme and notification preferences.
* **Delete account:** Delete your account and all associated data.

## ScreenShots

|                               |                               |                               |
|---|---|---|
| ![login_page.png](screenshots%2Flogin_page.png) | ![signup_page.png](screenshots%2Fsignup_page.png) | ![homepage_dark.png](screenshots%2Fhomepage_dark.png) |
| ![homepage_light.png](screenshots%2Fhomepage_light.png) | ![empty_search.png](screenshots%2Fempty_search.png) | ![searchpage.png](screenshots%2Fsearchpage.png) |
| ![empty_chatpage.png](screenshots%2Fempty_chatpage.png) | ![chatpage.png](screenshots%2Fchatpage.png) | ![drawer.png](screenshots%2Fdrawer.png) || ![settings.png](screenshots%2Fsettings.png) | ![change_profile_info.png](screenshots%2Fchange_profile_info.png) | ![friends_profile_info.png](screenshots%2Ffriends_profile_info.png) |

## Getting Started

To get started with the TalkFlow Chat App, follow these steps:

1- Clone the repository: git clone https://github.com/OracleMatrix/talkflow-flutter-chat-app.git
2- Install dependencies: flutter pub get
3- Configure Firebase: Create a Firebase project and enable the Firestore and Authentication
services. Then, create a firebase_options.dart file in the lib directory with your Firebase
configuration.
4- get the google-services.json and put it in /android/app
5- Run the app: flutter run
**Note:** it's better after create project in your firebase console install flutterfire and run the
command "flutterfire configure" in your project path, there is lots of videos about flutterfire on
internet if you don't know!


## Code Structure

The code is organized into the following directories:

* lib: Contains the main application code.
* models: Contains data models for the app, such as user and message models.
* pages: Contains the different pages of the app, such as the home page and chat page.
* provider: Contains the Firebase provider, which handles Firebase authentication and data storage.
* services: Contains services for handling tasks such as sending messages and uploading media.

## Dependencies

The app uses the following dependencies:

* flutter: The Flutter framework.
* firebase_core: The Firebase Core SDK for Flutter.
* firebase_auth: The Firebase Authentication SDK for Flutter.
* cloud_firestore: The Firebase Firestore SDK for Flutter.
* firebase_storage: The Firebase Storage SDK for Flutter.
* provider: A state management library for Flutter.
* adaptive_theme: A library for adaptive themes in Flutter.
* google_fonts: A library for Google Fonts in Flutter.
* cached_network_image: A library for caching network images in Flutter.
* loading_animation_widget: A library for loading animations in Flutter.
* file_picker: A library for file picking in Flutter.

## Contributing
<<<<<<< HEAD

Contributions are welcome! If you'd like to contribute to the TalkFlow Chat App, please fork the
repository and submit a pull request with your changes.
=======
Contributions are welcome! If you'd like to contribute to the TalkFlow Chat App, please fork the repository and submit a pull request with your changes.
>>>>>>> 7f0b43679d33eb5711dc1a58e541eb6136d87488
