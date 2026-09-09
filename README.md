# Durga Puja Management App (durgapuja_manager)

A production-ready financial management system for Durga Puja committees (~100 users), built with **Flutter**, **Clean Architecture**, **Riverpod**, and **Firebase**.

---

## Technical Stack & Architecture

- **Framework:** Flutter stable (3.41.1+) / Dart 3.11+
- **Architecture:** Clean Architecture + Feature-First structure (`lib/features/`)
- **State Management:** Riverpod (`flutter_riverpod`)
- **Backend:** Firebase Auth, Cloud Firestore, Firebase Storage, FCM Notifications
- **UI & Navigation:** Material 3 & GoRouter
- **Formatting:** Indian Currency formatting (`₹5,000`, `₹1,25,000`) & English number-to-words (`Five Thousand Rupees Only`)
- **Exports & Documents:** PDF Donation Receipts, Financial Summary PDF, Excel (.xlsx) Export, CSV Export

---

## Complete Step-by-Step Firebase Account & Project Setup Guide

Follow these simple steps to connect your Firebase account:

### 1. Create a Firebase Project
1. Open the [Firebase Console](https://console.firebase.google.com/).
2. Log in with your Google account.
3. Click **Add project** (or **Create a project**).
4. Enter your project name (e.g. `durgapuja-manager-2026`) and click **Continue**.
5. Enable or disable Google Analytics as preferred, then click **Create project**.

### 2. Enable Firebase Authentication
1. In the left navigation menu, go to **Build** → **Authentication**.
2. Click **Get Started**.
3. Under **Sign-in method**, select **Email/Password**.
4. Toggle **Enable** for Email/Password and click **Save**.

### 3. Setup Cloud Firestore Database
1. In the left navigation menu, go to **Build** → **Cloud Firestore**.
2. Click **Create database**.
3. Select your database location (e.g., `asia-south1 (Mumbai)` for India).
4. Select **Start in production mode** and click **Create**.
5. Go to the **Rules** tab in Firestore and replace the content with the production rules from `firestore.rules`. Click **Publish**.
6. Go to the **Indexes** tab and deploy indexes from `firestore.indexes.json`.

### 4. Setup Firebase Storage
1. In the left menu, go to **Build** → **Storage**.
2. Click **Get Started**, choose default settings, and click **Done**.
3. Go to the **Rules** tab and paste rules from `storage.rules`. Click **Publish**.

### 5. Connect Flutter Project to Your Firebase Account
Run the following commands in your shell terminal:
```bash
# 1. Install FlutterFire CLI globally
dart pub global activate flutterfire_cli

# 2. Configure project with your Firebase account
cd "c:\AB Project\Durga Puja Management App"
flutterfire configure
```
This command will prompt you to select your Firebase project and automatically generate `lib/firebase_options.dart` and `android/app/google-services.json`!

### 6. Create First Super Admin User
1. In Firebase Console → **Authentication** → **Users** tab, click **Add user**.
2. Enter email (e.g., `admin@durgapuja.org`) and password.
3. Copy the generated User **UID** (e.g., `abc123xyz456`).
4. Go to **Cloud Firestore** → **`users`** collection.
5. Click **Add document**, set Document ID to the copied UID (`abc123xyz456`), and add fields:
   ```json
   {
     "uid": "abc123xyz456",
     "name": "Super Admin",
     "email": "admin@durgapuja.org",
     "mobile": "9876543210",
     "roleId": "super_admin",
     "status": "ACTIVE",
     "profileImageUrl": null,
     "createdAt": "2026-08-10T12:00:00.000Z",
     "updatedAt": "2026-08-10T12:00:00.000Z",
     "createdBy": "system"
   }
   ```
6. You can now log into the application with full Super Admin privileges!

---

## Role & Permission Matrix

| Role | Dashboard | Collection CRUD | Approve Collection | Expense CRUD | Approve Expense | Reports | Export | Manage Events | Manage Users |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **Super Admin** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **President** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Treasurer** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ | ❌ |
| **Manager** | ✅ | ✅ | ❌ | ✅ | ❌ | ✅ | ❌ | ❌ | ❌ |
| **Collection Member** | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| **Viewer** | ✅ | View Only | ❌ | View Only | ❌ | ✅ | ❌ | ❌ | ❌ |

---

## How to Run & Test

1. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

2. **Run Static Code Analyzer**:
   ```bash
   flutter analyze
   ```

3. **Run Unit & Widget Test Suite**:
   ```bash
   flutter test
   ```

4. **Launch Application**:
   ```bash
   flutter run
   ```
