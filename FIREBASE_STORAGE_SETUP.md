# Firebase Storage Setup Guide

## ⚠️ Important: Firestore vs Firebase Storage

You have **Firestore** rules configured (for database), but you also need **Firebase Storage** rules (for file uploads like photos).

These are **two separate services** with **separate security rules**.

## 🔧 Solution: Configure Firebase Storage Security Rules

### Step 1: Open Firebase Console
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project: **travel-guide-app-68520**
3. Click on **Storage** in the left sidebar (not Firestore)
4. Click on the **Rules** tab

### Step 2: Add Storage Security Rules

You should see rules like this (these are the default/empty rules):

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if false;
    }
  }
}
```

**Replace them with these rules:**

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Allow authenticated users to upload and read their own profile photos
    match /users/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Default deny rule - deny all other paths
    match /{allPaths=**} {
      allow read, write: if false;
    }
  }
}
```

### Step 3: Publish Rules
Click **Publish** button to save the rules.

## ✅ What These Rules Do

- **Authenticated users** can read any user's photos (for displaying profile pictures)
- **Users can only write (upload/delete)** their own photos in their `users/{userId}/` folder
- All other paths are denied by default

## 📝 Your Current Setup

✅ **Firestore Rules** (Database) - Already configured ✓  
❌ **Firebase Storage Rules** (File Storage) - **NEEDS TO BE CONFIGURED** ⚠️

## 🔍 Verification

After updating the Storage rules:
1. Try uploading a photo again
2. The "object not found" error should be resolved
3. Photos will be stored at: `users/{userId}/profile_{timestamp}.jpg`

## 📍 Where to Find Storage Rules

**Firestore Rules:** Firebase Console → Firestore Database → Rules  
**Storage Rules:** Firebase Console → Storage → Rules ← **YOU NEED THIS ONE**
