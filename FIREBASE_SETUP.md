# Firebase Setup Guide

## ✅ Completed Steps

1. **google-services.json** file is placed in `android/app/google-services.json`
2. **Package name** matches: `com.example.travel_guide_app`
3. **Dependencies** are installed
4. **Firebase initialization** is configured in `main.dart`

## 🔧 Remaining Firebase Console Setup

### Step 1: Enable Authentication

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project: **travel-guide-app-68520**
3. Navigate to **Authentication** → **Get Started**
4. Go to **Sign-in method** tab
5. Enable the following:
   - ✅ **Email/Password** (Toggle ON)
   - ✅ **Google** (Toggle ON)
     - Add support email
     - For production: Add SHA-1 fingerprint
   - ✅ **Facebook** (Toggle ON)
     - Add Facebook App ID and App Secret (get from developers.facebook.com)

### Step 2: Create Firestore Database

1. In Firebase Console, go to **Firestore Database**
2. Click **Create database**
3. Select **Start in test mode** (for development)
4. Choose your database location (e.g., `us-central1`)
5. Click **Enable**

### Step 3: Firestore Security Rules (Recommended)

After creating the database, update the security rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      // Saved places subcollection
      match /saved_places/{placeId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
      
      // Trips subcollection
      match /trips/{tripId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
    
    // Reviews - readable by all, writable only by authenticated users
    match /reviews/{reviewId} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

## 📱 Testing the App

After enabling Authentication and Firestore:

```bash
flutter clean
flutter pub get
flutter run
```

### Test Checklist:

- [ ] App launches without errors
- [ ] Can sign up with email/password
- [ ] Can login with email/password
- [ ] Can save a place to favorites
- [ ] Can create a trip
- [ ] Can submit an app review
- [ ] Can view saved places
- [ ] Can view trips
- [ ] Can logout

## 🔐 Getting SHA-1 Key (For Google Sign-in)

For production Google Sign-in, add your SHA-1 fingerprint:

**Debug Key:**
```bash
cd android
./gradlew signingReport
```

Copy the SHA1 from the debug variant and add it in Firebase Console → Authentication → Sign-in method → Google → Add SHA certificate fingerprint

## 📝 Notes

- Test mode Firestore rules allow read/write for 30 days
- Update security rules before production
- Facebook sign-in requires Facebook App configuration
- Google sign-in may need SHA-1 for release builds

## 🐛 Troubleshooting

**"Default FirebaseApp is not initialized"**
- Ensure `google-services.json` is in `android/app/`
- Run `flutter clean && flutter pub get`

**"Permission denied" Firestore errors**
- Check Firestore security rules
- Ensure Authentication is enabled

**Login fails**
- Verify Authentication is enabled in Firebase Console
- Check email/password provider is enabled

