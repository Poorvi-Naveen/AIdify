# Aidify
## Simplifying First Aid
![alt text](assets/images/logo_image2.png)


**Aidify** is a Flutter-based mobile application designed to offer quick, reliable, and accessible first aid guidance. Whether it's burns, fractures, allergies, or CPR, Aidify helps users take immediate and informed action during emergencies.
---
## Features
- **Splash Screen**  
  Displays the Aidify logo and branding on app launch with a smooth transition.

- **Login & Signup Pages**  
  Secure user authentication using Firebase. Allows new user registration and login for returning users.

- **Home Screen**  
  A visually rich dashboard showing various first aid topics as clickable cards. Each topic leads to detailed step-by-step instructions.

- **Bookmarks Page**  
  Lets users save important or frequently accessed first aid topics for quick reference.

- **Chatbot**  
  An AI-powered assistant that answers first aid-related queries through natural conversation.

- **Profile Page**  
  Displays user information (username, email, DOB) retrieved from Firestore. Includes a logout option.

- **Emergency Call Screen**  
  One-tap access to emergency service numbers like Ambulance, Police, and Fire. Also supports adding a custom emergency contact.

## Tech Stack
 - **Flutter** for frontend UI
 - **Firebase Authentication** for user login/signup
 - **Cloud Firestore** for user data and topic management

## Project Structure
```lib/
├── main.dart
├── splash_screen.dart
├── login_screen.dart
├── signup_screen.dart
├── home_screen.dart
├── bookmarks_screen.dart
├── chatbot_screen.dart
├── emergency_screen.dart
├── profile_screen.dart
├── topic_detail_screen.dart
├── models/
│ └── first_aid_topic.dart
├── data/
│ └── topics.json
└── widgets/
└── topic_card.dart
--- 
## Firebase Configuration
To use Firebase in your app:

1. Set up Firebase project at [Firebase Console](https://console.firebase.google.com/).
2. Enable **Authentication** and **Firestore Database**.
3. Download `google-services.json` (for Android) and place it in `android/app/`.
4. Update `android/build.gradle` and `android/app/build.gradle` as per Firebase instructions.

## How to Use
- Clone the repo:
   ```bash
   git clone https://github.com/Poorvi-Naveen/Aidify.git
- Navigate to the project: 
   ```cd Aidify
- Get dependencies:
   ```flutter pub get
- Run the app:
   ```flutter run

## Contributions
Pull requests are welcome! For major changes, please open an issue first to discuss what you'd like to change.

