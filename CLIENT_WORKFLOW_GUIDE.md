# Durga Puja Financial Management System — Client User Guide & Workflow

A complete, technically accurate, client-facing guide explaining how the Durga Puja Financial Management System works from end to end.

---

## 🌟 Executive Overview

The **Durga Puja Financial Management System** is a secure, role-based application designed specifically for Puja Committees (~100 members) to manage public donations, vendor expenses, approval workflows, official PDF receipts, financial reports, and data exports.

The system ensures complete financial accountability through **role-based approval controls**, **self-approval prevention**, **event-level data isolation**, and **protected audit logging**.

The application is deployed as a **Production-Ready Progressive Web Application (PWA)** hosted on Firebase Hosting:
`https://durga-puja-manager.web.app`

---

## 🌐 Web & PWA Advantage (No APK Required)

### Why Web/PWA?
- **Zero APK Installation Friction**: Users open the application URL in any mobile or desktop browser without downloading APK files.
- **Instant Centralized Updates**: When a new version is released (`flutter build web --release` -> `firebase deploy --only hosting`), users automatically receive the latest version upon opening or refreshing the app.
- **Cross-Platform Compatibility**: Works identically across Android, iPhone (iOS), iPad, Mac, Windows, and Linux.

### Home Screen Installation Guide (PWA)

#### 📱 Android (Google Chrome):
1. Open `https://durga-puja-manager.web.app` in Chrome.
2. Log in with your committee email & password.
3. Tap the **3 dots (⋮)** menu in the top right.
4. Select **"Add to Home screen"** or **"Install app"**.
5. The **Durga Puja Manager** icon will appear on your phone home screen and launch like a native mobile app!

#### 🍎 iPhone / iPad (Apple Safari):
1. Open `https://durga-puja-manager.web.app` in Safari.
2. Log in with your committee credentials.
3. Tap the **Share button (square with arrow)** at the bottom.
4. Scroll down and tap **"Add to Home Screen"**.
5. Tap **Add** in the top right.

#### 💻 Desktop (Chrome / Microsoft Edge):
1. Open `https://durga-puja-manager.web.app`.
2. Click the **Install icon** in the browser address bar (or Menu → Install Durga Puja Manager).
3. The app will launch in a standalone desktop window.

---

## 👥 1. Roles & Permission Matrix

The system defines **6 distinct committee roles** with strict permission boundaries:

| Role | Dashboard | Submit Entry | Approve Entries | View Reports | Export Reports | Manage Users |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: |
| **Super Admin** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **President** | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ |
| **Treasurer** | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ |
| **Manager** | ✅ | ✅ | ❌ | ✅ | ❌ | ❌ |
| **Collection Member** | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |
| **Viewer** | ✅ | ❌ | ❌ | ✅ | ❌ | ❌ |

*Note: Viewing reports (`viewReports`) and exporting files (`exportReports`) are separate permissions. A user like a Manager can view financial reports without having authorization to export files.*

---

## 🔄 2. Complete End-to-End Operational Workflow

```
                        [ LOGIN & ROLE IDENTIFICATION ]
                                       │
                                       ▼
                             [ SELECT PUJA EVENT ]
                                       │
                                       ▼
                             [ FINANCIAL DASHBOARD ]
                                       │
                    ┌──────────────────┴──────────────────┐
                    ▼                                     ▼
          [ ADD PUBLIC COLLECTION ]               [ ADD PUJA EXPENSE ]
                    │                                     │
                    ▼                                     ▼
            (Status: PENDING)                     (Status: PENDING)
                    │                                     │
                    └──────────────────┬──────────────────┘
                                       ▼
                          [ ROLE-BASED REVIEW & APPROVAL ]
                    (Treasurer / President / Super Admin Review)
                                       │
                    ┌──────────────────┴──────────────────┐
                    ▼                                     ▼
               [ APPROVED ]                          [ REJECTED ]
                    │                                     │
         ┌──────────┴──────────┐                          ├──> Mandatory Reason Required
         │                     │                          ├──> Submitter Notified
         ▼                     ▼                          └──> Excluded from Totals
  Official Receipt     Dashboard Balance,
 (DP-2026-000001)     Reports & Audit Log
                           Updated
```

---

## 📋 3. Detailed Module Workflows

### 3.1. Public Collection & Official Donation Receipt Workflow

```
Field Collector / Committee Member
        ↓
Add Public Collection Entry
        ↓
PENDING Status (Optional Provisional Acknowledgement)
        ↓
Role-Based Review (Treasurer / President / Super Admin)
        ↓
     ┌──┴──┐
     ↓     ↓
 APPROVED REJECTED
     ↓     ↓
     │     ├──> Mandatory Rejection Reason Required
     │     ├──> Submitter Notified
     │     └──> Not Included in Financial Totals
     ↓
Official Donation Receipt Generated (DP-2026-000001)
     ↓
Financial Dashboard Updated
     ↓
Reports & Exports Updated
     ↓
Protected Audit History Logged
```

#### Official Receipt Rules:
- **Approval Prerequisite**: An official donation receipt and receipt number are generated **ONLY AFTER** a collection is officially `APPROVED` by an authorized reviewer.
- **Receipt Number Format**: Approved receipts receive a sequential official receipt number (e.g., `DP-2026-000001`).
- **No Receipt for Rejected Entries**: Rejected collection requests are **NEVER** assigned an official receipt number.
- **Provisional Acknowledgement (Optional)**: If a donor requests immediate proof of collection at the time of entry, a temporary document titled **"Provisional Donation Acknowledgement"** clearly marked **`PENDING — NOT AN OFFICIAL RECEIPT`** may be issued.

---

### 3.2. Committee Expense Workflow

```
Committee Member / Manager
        ↓
Add Expense Entry & Voucher Details
        ↓
PENDING Status
        ↓
Role-Based Review (Treasurer / President / Super Admin)
        ↓
     ┌──┴──┐
     ↓     ↓
 APPROVED REJECTED
     ↓     ↓
     │     ├──> Mandatory Rejection Reason Required
     │     ├──> Submitter Notified
     │     └──> Not Included in Financial Totals
     ↓
Financial Dashboard Updated
     ↓
Reports & Exports Updated
     ↓
Protected Audit History Logged
```

---

### 3.3. Role-Based Approval Workflow

The system uses a **Role-Based Single-Level Approval Workflow**.

- **Authorized Reviewers**: Any **ONE** authorized reviewer (**Treasurer OR President OR Super Admin**) can approve or reject a transaction.
- **Self-Approval Protection**: A user **CANNOT** approve their own submitted transaction.
  - *Example*: If Titu (Treasurer) submits a `₹5,000` collection, Titu cannot approve it. The transaction must be reviewed by the President or Super Admin.
  - *Enforcement*: Enforced both in the UI and at the database/security rule level.

---

## 💰 4. Financial Calculation & Dashboard Rules

### Approved-Only Calculation Rule
**ONLY APPROVED TRANSACTIONS COUNT IN OFFICIAL FINANCIAL TOTALS.**

$$\text{Current Balance} = \text{Total Approved Collection} - \text{Total Approved Expense}$$

- **`APPROVED` Collections**: Added to Total Approved Collection.
- **`APPROVED` Expenses**: Added to Total Approved Expense.
- **`PENDING` Transactions**: Shown separately under Pending Transaction Alerts; **NOT** included in the official balance.
- **`REJECTED` Transactions**: Excluded entirely from official totals.

---

## 📅 5. Annual Event Data Isolation

Every financial transaction is strictly bound to a specific Puja Event ID (`eventId`).

- **Annual Events**: e.g., *Durga Puja 2026*, *Durga Puja 2027*, *Durga Puja 2028*.
- **Data Filtering**: When the user selects *Durga Puja 2026* from the top event selector, only 2026 collections, expenses, balances, and reports are loaded. Financial data between years is never mixed.

---

## 🛡️ 6. Security, Audit Trail & Administrative Rules

### 6.1. Reduced Risk of Financial Fraud
Role-based permissions, single-level approval controls, self-approval prevention, and audit logging **significantly reduce the risk of unauthorized financial activity** and fraud.

### 6.2. Protected Audit History
All sensitive operations are logged in a **Protected, Non-Editable Audit History**:
- **Events Logged**: `LOGIN`, `LOGOUT`, `CREATE`, `UPDATE`, `DELETE`, `APPROVE`, `REJECT`, `ROLE_CHANGE`, `USER_ACTIVATE`, `USER_DEACTIVATE`, `EVENT_CREATE`, `EVENT_UPDATE`, `EVENT_ARCHIVE`.

### 6.3. Super Admin Safety Lockout Prevention
To prevent accidental committee lockout:
- At least one active Super Admin must always remain in the system.

---

## 🚀 7. Developer Release & Hosting Deployment Workflow

To release a new update to Firebase Hosting:

1. **Build Flutter Web**:
   ```bash
   flutter build web --release
   ```
2. **Deploy to Firebase Hosting**:
   ```bash
   firebase deploy --only hosting
   ```
3. **URL Status**: The production web application (`https://durga-puja-manager.web.app`) is updated instantly without requiring users to download APKs!
