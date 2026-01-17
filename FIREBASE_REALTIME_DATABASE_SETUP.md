# Firebase Realtime Database Setup Guide

## Step 1: Enable Realtime Database

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: `plantdisease-e827d`
3. Navigate to **Realtime Database** (in the left sidebar)
4. Click **Create Database**
5. Choose your database location (select closest to your users)
6. Choose **Start in test mode** (we'll update rules later)
7. Click **Enable**

## Step 2: Get Your Database URL

After creating the database, you'll see the database URL. It will be in one of these formats:

**New Format:**
```
https://plantdisease-e827d-default-rtdb.<REGION>.firebasedatabase.app
```

**Legacy Format:**
```
https://plantdisease-e827d.firebaseio.com
```

**Example:**
- `https://plantdisease-e827d-default-rtdb.asia-south1.firebasedatabase.app`
- `https://plantdisease-e827d.firebaseio.com`

## Step 3: Update Database URL in Code

1. Open `lib/services/auth_service.dart`
2. Find the line: `static const String databaseURL = '...';`
3. Replace with your actual database URL from Step 2

## Step 4: Set Database Rules

Go to Firebase Console → Realtime Database → Rules tab

**For Development (Test Mode):**
```json
{
  "rules": {
    ".read": true,
    ".write": true
  }
}
```

**For Production (Secure):**
```json
{
  "rules": {
    "users": {
      "$role": {
        "$userId": {
          ".read": "auth != null || $role == 'farmers' || $role == 'buyers'",
          ".write": "auth != null || !data.exists()"
        }
      }
    }
  }
}
```

## Step 5: Test the Connection

Run your app and try to register a new user. Check Firebase Console → Realtime Database → Data tab to see if data is being saved.

## Troubleshooting

### Error: "Cannot parse Firebase url"
- Make sure you've enabled Realtime Database in Firebase Console
- Check that the database URL is correct
- The URL should start with `https://` and end with `.firebaseio.com` or `.firebasedatabase.app`

### Error: "Permission denied"
- Check your database rules in Firebase Console
- Make sure rules allow read/write for your use case

### Database URL Not Found
- Go to Firebase Console → Realtime Database
- The URL is shown at the top of the Data tab
- Copy the full URL including `https://`

## Database Structure

Your data will be stored as:
```
users/
  ├── farmers/
  │   └── {farmerId}/
  │       ├── id
  │       ├── name
  │       ├── email
  │       ├── password
  │       ├── phone
  │       ├── role
  │       ├── address
  │       └── createdAt
  └── buyers/
      └── {buyerId}/
          ├── id
          ├── name
          ├── email
          ├── password
          ├── phone
          ├── role
          ├── address
          └── createdAt
```

## Admin Credentials

Admin login is predefined (not stored in database):
- **Email:** `admin@farmtech.com`
- **Password:** `admin123`

You can change these in `lib/services/auth_service.dart`:
```dart
static const String adminEmail = 'admin@farmtech.com';
static const String adminPassword = 'admin123';
```
