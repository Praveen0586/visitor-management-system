# Sumadhura VMS (Visitor Management System)

A production-grade, enterprise **Offline-First** Flutter application engineered for Sumadhura Group's Front-Desk Concierge and Security Gate operations. It enables front-desk receptionists and security personnel to register incoming visitors, generate instant optical QR access passes, scan visitor passes at security checkpoints, seamlessly manage check-in/check-out status transitions, and monitor real-time gate occupancy via an interactive dashboard—**with full offline capability and automated cloud synchronization**.

---

## 📑 Table of Contents
- [Overview](#sumadhura-vms-visitor-management-system)
- [Screenshots](#-screenshots)
- [Offline-First Architecture](#-offline-first-architecture)
- [Application Features](#-application-features)
- [Tech Stack & Environment Versions](#-tech-stack--environment-versions)
- [Architecture & State Management](#-architecture--state-management)
- [Project Directory Structure](#-project-directory-structure)
- [Packages & Dependencies](#-packages--dependencies)
- [Mock API Specification](#-mock-api-specification)
- [Setup & Execution Instructions](#-setup--execution-instructions)
- [Building the APK](#-building-the-apk)
- [Quality Assurance & Test Coverage](#-quality-assurance--test-coverage)
- [How to Test (Step-by-Step Evaluator Guide)](#-how-to-test-step-by-step-evaluator-guide)
- [Design Considerations & Constraints](#-design-considerations--constraints)

---

## 📸 Screenshots

| 1. Gate Dashboard | 2. Visitor Registry & Filters | 3. Quick Entry Form |
| :---: | :---: | :---: |
| ![Dashboard](screenshots/dashboard.png) | ![Visitor List](screenshots/visitor_list.png) | ![Visitor Registration](screenshots/visitor_registration.png) |

| 4. Digital Express Pass (QR) | 5. Optical QR Scanner |
| :---: | :---: |
| ![Visitor Details with QR](screenshots/visitor_details_qr.png) | ![QR Scanner](screenshots/qr_scanner.png) |

> *Note: Place device screenshots in the `screenshots/` directory matching the filenames above.*

---

## ⚡ Offline-First Architecture

Sumadhura VMS is designed from the ground up as an **Offline-First** system to guarantee uninterrupted security gate operations regardless of network fluctuations:

1. **Local-First Data Authority**:
   - All visitor registries, status updates, check-ins, check-outs, and new registrations commit immediately to local device storage (`SharedPreferences`).
   - The UI updates instantly with zero latency (optimistic UI), ensuring security personnel never face loading spinners during high gate traffic.

2. **Zero-Latency Startup**:
   - On app launch, cached records are rendered immediately from disk before any remote network call is made.

3. **Autonomous Offline Operations**:
   - **Registration**: New walk-in visitors can be registered without an internet connection. The app automatically assigns local identifiers and formatted pass codes (`SUM-YYYY-XXX`).
   - **Status Transitions**: Check-in and check-out operations are processed locally in real time.
   - **QR Pass Generation & Scanning**: Digital passes and optical QR codes are rendered and verified entirely on-device without cloud dependencies.

4. **Resilient Synchronization & Conflict Reconciliation**:
   - Mutations made offline are flagged with `isPendingSync: true`.
   - Deleted visitor records are queued in a persistent tombstone list (`pending_deleted_ids_v1`) to prevent re-creation during subsequent remote syncs.
   - When network connectivity is active or when the user initiates pull-to-refresh, the local store harmonizes with MockAPI.io, pushing local changes and fetching remote updates cleanly.

---

## ✨ Application Features

- **Real-Time Security Dashboard**:
  - Live metric KPI cards: **Total Visitors Today**, **Currently Checked In**, and **Checked Out Today**.
  - Dynamic sync indicator displaying timestamp of the latest cloud refresh.
  - Quick action shortcuts for walk-in visitor registration and one-tap camera scanning.
  - Recent activity feed showing the latest 4 visitors with status badges and timestamps.

- **Searchable & Filterable Visitor Registry**:
  - Instant live search matching visitor name or 10-digit mobile number.
  - Segmented status filter tabs: `All`, `Checked In`, `Registered`, and `Checked Out`.
  - Informative empty state views with a one-tap shortcut to add a walk-in visitor.
  - Pull-to-refresh integration synchronizing remote MockAPI records with local cache.

- **Quick Entry Registration**:
  - Centralized field validation with an error summary alert for incomplete submissions.
  - Real-time progressive feedback on phone number input (e.g., *"Enter a valid 10-digit mobile number (4 remaining)"*).
  - Visitor category selector (`Customer`, `Vendor`, `Other`).
  - Pre-filled premises selection (`Project A (Sumadhura Horizon)`, `Project B (Sumadhura Epitome)`, `Corporate HQ`).
  - Quick-pick purpose suggestion chips (*Site Visit*, *Interview*, *Meeting*, *Delivery*, *Maintenance*).
  - Physical badge printing toggle option.

- **Digital Express Pass & Gate Access Log**:
  - High-fidelity vector-rendered optical QR pass with central Sumadhura gold diamond brand badge.
  - Pass details: Visitor Name, 10-digit Mobile, Purpose, Category, Destination Unit, and Pass Code (`SUM-YYYY-XXX`).
  - Dynamic primary action button:
    - `CHECK IN VISITOR` (Green) when status is `Registered`.
    - `CHECK OUT VISITOR` (Red) when status is `Checked In`.
  - Gate Access Log tracking entry timestamps, exit timestamps, and security clearance events.
  - Native system share sheet support to export and share passes.

- **Dual-Mode Optical QR Pass Scanner**:
  - **Live Camera Feed**: Powered by `mobile_scanner` with hardware torch toggle and front/back camera switching.
  - **Simulator Quick Test Mode**: Emulator-friendly test chips enabling evaluators to test QR verification without physical camera hardware.
  - Smart code detection resolving both standard pass codes (`SUM-YYYY-XXX`) and numeric IDs.

---

## 🛠️ Tech Stack & Environment Versions

Exact development environment versions:

```text
Flutter 3.41.9 • channel stable • https://github.com/flutter/flutter.git
Framework • revision 00b0c91f06 (2026-04-29 10:03:19 -0700)
Engine    • hash 9161402dc0e134b3fb5adee5046b6e84b1a5e1c1
Tools     • Dart 3.11.5 • DevTools 2.54.2
```

- **Target Platform**: Android (primary test platform) & iOS
- **Android Min SDK**: `21` (Android 5.0 Lollipop — required for `mobile_scanner`)
- **Android Target SDK**: `34` (Android 14) / `35`
- **Java / Kotlin Target**: Java 17

---

## 🏛️ Architecture & State Management

### Architectural Pattern: MVVM (Model-View-ViewModel)
The application strictly enforces separation of concerns:
- **Model**: `Visitor` data model with immutable `copyWith`, JSON serialization/deserialization, and status helpers (`lib/features/dashboard/models/visitor_model.dart`).
- **Services**: `ApiServices` (Dio HTTP client) and `LocalStorageService` (SharedPreferences offline cache and synchronization manager).
- **ViewModel**: `DashboardViewModel` (`ChangeNotifier`) acting as the single source of truth for UI state, metric calculations, search query filtering, and API orchestration.
- **Views**: Stateless & Stateful UI screens and atomic widgets listening to ViewModel state.

### Why Provider?
1. **Simplicity & Predictability**: Provider offers clean dependency injection and reactive state notification without boilerplate code or heavy code generation.
2. **Single Source of Truth**: A single central store (`DashboardViewModel`) holds the reactive visitor list. When a visitor is checked in via the QR Scanner or Detail Screen, the central store updates immediately; the Dashboard counters, Visitor Directory list badges, and Express Pass instantly reflect the change.
3. **Decoupled Architecture**: ViewModels remain completely independent of Flutter UI components, making unit and integration testing straightforward.

---

## 📁 Project Directory Structure

```text
vms/
├── lib/
│   ├── main.dart                                # MultiProvider initialization & App entry point
│   ├── core/
│   │   ├── configs/
│   │   │   ├── api/
│   │   │   │   ├── api_endpoints.dart           # MockAPI REST endpoints and URL builder
│   │   │   │   └── api_services.dart            # Dio HTTP networking client
│   │   │   ├── storage/
│   │   │   │   └── local_storage_service.dart   # SharedPreferences offline persistence layer
│   │   │   └── theme/
│   │   │       └── app_theme.dart               # Sumadhura Navy (#0F172A) & Gold (#D97706) design system
│   │   ├── utils/
│   │   │   ├── share_service.dart               # Native pass export and sharing
│   │   │   └── validators.dart                  # RegEx patterns for Name, 10-digit Mobile, & Email
│   │   └── widgets/                             # Central reusable design system components
│   │       ├── app_header.dart                  # Header bar with emblem & sync status
│   │       ├── category_badge.dart              # Badges for Customer, Vendor, and Other
│   │       ├── custom_bottom_nav.dart           # Indexed navigation bar (Dashboard, Scan, Visitors)
│   │       ├── custom_text_field.dart           # Form text fields with real-time feedback
│   │       ├── empty_state_view.dart            # Visual empty state with quick CTA
│   │       ├── metric_card.dart                 # Dashboard metric KPI card widget
│   │       ├── qr_pass_card.dart                # Vector-rendered QR pass card
│   │       ├── registration_success_dialog.dart # Registration confirmation dialog
│   │       ├── status_chip.dart                 # Visual status indicator chip
│   │       └── visitor_tile.dart                # Directory & compact visitor list tile
│   └── features/
│       └── dashboard/
│           ├── models/
│           │   └── visitor_model.dart           # Visitor model, schema, & JSON parsers
│           ├── viewmodels/
│           │   └── dashboard_view_model.dart    # ChangeNotifier managing metrics, filters, and CRUD
│           └── views/
│               ├── main_navigation_shell.dart   # IndexedStack navigation host
│               ├── dashboard_screen.dart        # Screen 1: KPIs, actions, & recent activity
│               ├── visitors_list_screen.dart    # Screen 2: Searchable registry & status filters
│               ├── visitor_form_screen.dart     # Screen 3: New visitor registration form
│               ├── visitor_detail_screen.dart   # Screen 4: Digital Express Pass & access log
│               └── scan_screen.dart             # Screen 5: QR scanner with simulator fallback
├── test/
│   ├── validators_test.dart                     # RegEx input validation unit tests
│   ├── local_storage_test.dart                  # SharedPreferences cache unit tests
│   └── widget_test.dart                         # Model serialization & ViewModel test suite
├── screenshots/                                 # App screenshots for documentation
└── pubspec.yaml                                 # Dependencies & asset declarations
```

---

## 📦 Packages & Dependencies

| Package | Version | Purpose & Rationale |
|---|---|---|
| `dio` | `^5.11.1` | Robust HTTP networking client with timeouts, request interception, and REST MockAPI handling. |
| `provider` | `^6.1.5+1` | Centralized state management providing single source of truth across all views via `ChangeNotifier`. |
| `qr_flutter` | `^4.1.0` | High-fidelity vector QR code rendering for visitor pass badges based on pass number. |
| `mobile_scanner` | `^5.2.3` | Hardware-accelerated camera barcode and QR scanning engine with torch and lens controls. |
| `google_fonts` | `^8.2.1` | Standardized typography across platforms using the Inter font family. |
| `shared_preferences` | `^2.5.6` | Lightweight key-value persistence for offline-first caching of visitor records and sync state. |
| `permission_handler` | `^11.3.1` | Cross-platform runtime permission management for camera and scanner hardware. |
| `share_plus` | `^10.1.4` | Share digital visitor passes and access codes via native OS share dialogs. |
| `path_provider` | `^2.1.5` | Platform-specific file system access for cache directories. |
| `url_launcher` | `^6.3.3` | External deep-linking and web url launching. |
| `cupertino_icons` | `^1.0.8` | Standard iOS-style icon assets. |

---

## 🌐 Mock API Specification

- **Backend Provider**: [MockAPI.io](https://mockapi.io)
- **Base URL**: `https://6ae04ff4be3bc8fead96dfd7.mockapi.io/api/v1`

### Endpoints Table

| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/visitors` | Retrieve all visitor records |
| `POST` | `/visitors` | Create a new visitor registration (returns server ID) |
| `GET` | `/visitors/:id` | Fetch details of a specific visitor by ID |
| `PUT` | `/visitors/:id` | Update visitor record details |
| `PUT` | `/visitors/:id` | Patch visitor status (`Checked In` / `Checked Out`) and timestamps |
| `DELETE` | `/visitors/:id` | Delete a visitor record |

### Sample JSON Record

```json
{
  "id": "1",
  "name": "Vikram Malhotra",
  "mobile": "9876543210",
  "email": "vikram.m@example.com",
  "visitor_type": "Customer",
  "project": "Project A (Sumadhura Horizon)",
  "purpose": "Site Visit",
  "status": "Checked In",
  "created_at": "2026-10-28T09:30:00.000Z",
  "check_in_time": "2026-10-28T09:35:12.000Z",
  "check_out_time": null,
  "pass_number": "SUM-2026-001",
  "unit": "Tower 2 - Unit 402",
  "print_physical_pass": false
}
```

> [!NOTE]
> **Offline Resiliency & Cloud Sync**: Data is saved to the local offline cache first and then synchronized with MockAPI.io when connectivity is available. Unique pass codes (`SUM-YYYY-XXX`) are immediately assigned and encoded into the optical QR pass so passes can be generated, shared, and scanned offline without delay.
>
> [!WARNING]
> If you have admin dashboard access to MockAPI.io, **please do not click "Reset" or "Generate"**, as doing so will overwrite existing test records.

---

## 🚀 Setup & Execution Instructions

### Prerequisites
- Flutter SDK `^3.11.5` / Flutter `3.41.x` installed
- Android SDK installed with `cmdline-tools` and platform-tools
- Physical Android device with USB debugging enabled OR an Android Emulator running API 21+

### Step-by-Step Setup

1. **Clone the repository**:
   ```bash
   git clone <repository_url>
   cd vms
   ```

2. **Install project dependencies**:
   ```bash
   flutter pub get
   ```

3. **Verify connected devices**:
   ```bash
   flutter devices
   ```

4. **Run the application**:
   ```bash
   flutter run
   ```

---

## 📦 Building the APK

To build a standalone Android APK:

```bash
flutter build apk
```

- **Output APK Path**:
  `build/app/outputs/flutter-apk/app-release.apk`

- **APK Distribution**:
  Evaluators can download the pre-compiled APK directly from the [GitHub Releases](https://github.com/your-username/vms/releases) page or via the provided public Google Drive link:
  > *Download Link*: `[Release APK Download Link]` *(Replace with public URL)*

---

## 🧪 Quality Assurance & Test Coverage

Comprehensive unit, storage, and widget test suites are organized in `test/`:

### Coverage Overview:
- `test/validators_test.dart`: Validates Full Name regex, 10-digit Indian mobile regex, email RFC 5322 compliance, and purpose character limits.
- `test/local_storage_test.dart`: Validates JSON serialization/deserialization, offline caching, and persistence mechanisms via SharedPreferences.
- `test/widget_test.dart`:
  - `Visitor` JSON serialization, deserialization, and immutability (`copyWith`).
  - `DashboardViewModel` metric counting, dynamic search filtering, sorting by recent activity, and check-in / check-out state transitions.
  - Widget tree smoke test verifying navigation shell, app headers, KPI cards, and action buttons.

---

## 📋 How to Test (Step-by-Step Evaluator Guide)

Follow this walkthrough to test all features:

### 1. Explore Dashboard & KPIs
- Launch the app. The **Dashboard** loads with 3 live KPI cards: *Total Visitors Today*, *Currently Checked In*, and *Checked Out Today*.
- Note the *Live Sync* badge indicating cloud sync status and last updated timestamp.

### 2. Register a New Visitor (Online or Offline)
- Tap the **+ REGISTER NEW VISITOR** button or navigate to the **Visitors** tab and tap **Register Visitor**.
- Fill in:
  - **Full Name**: e.g., `Aditya Varma`
  - **Mobile Number**: e.g., `9876543210` (observe the dynamic validation feedback counter)
  - **Visitor Type**: Select `Customer`, `Vendor`, or `Other`
  - **Project & Purpose**: Choose from the project dropdown and click a purpose chip (e.g., `Site Visit`)
- Tap **CONFIRM & GENERATE PASS**. The record is saved locally and synced to MockAPI, immediately opening the Digital Express Pass.

### 3. Verify Digital Express Pass & QR Code
- The **Visitor Detail** screen displays the vector-rendered QR pass containing the unique pass number (`SUM-YYYY-XXX`).
- Check the gate log at the bottom showing the visitor's registration timestamp.
- Optionally tap the share button to test native pass export.

### 4. Test QR Code Scanning & Check-In
You can test the optical QR scanner using either method:
- **Method A (Physical Camera / Two Screens)**:
  1. Open the QR Pass on one screen or device.
  2. On the scanner device, navigate to the **Scan** tab (center icon on the bottom navigation bar).
  3. Point the camera at the QR code.
  4. The app instantly recognizes the code and navigates to the Visitor Detail screen.
- **Method B (Simulator Quick Test Mode)**:
  1. If running on an Android Emulator without a camera, navigate to the **Scan** tab.
  2. In the "Simulator Quick Test" section, tap any of the visitor ID chips.
  3. The app simulates an optical scan and opens the corresponding visitor record.

### 5. Check-In & Check-Out Status Transitions
- On the Visitor Detail screen:
  - Tap **CHECK IN VISITOR** (Green button). The status changes to `Checked In`, and an entry log timestamp is recorded.
  - Return to the **Dashboard**: observe that *Currently Checked In* has incremented by 1.
  - Return to the visitor pass and tap **CHECK OUT VISITOR** (Red button).
  - Status transitions to `Checked Out`, and the exit timestamp is recorded.
  - Return to the **Dashboard**: observe *Checked Out Today* has incremented.

### 6. Test Directory Search & Filtering
- Open the **Visitors** tab.
- Enter a visitor's name or mobile digits in the search bar.
- Tap through the filter chips (`All`, `Checked In`, `Registered`, `Checked Out`) to observe real-time list filtering.

### 7. Test Offline First Behavior
- Turn on Airplane Mode or disconnect from the internet.
- Notice the app remains fully functional: browse existing visitors, register walk-in visitors, check-in, and check-out.
- When reconnected, pull down on the **Visitors** list to synchronize pending updates with the remote MockAPI.

---

## ⚠️ Design Considerations & Constraints

1. **Single Visit Session per Registration**:
   In accordance with the assignment scope, each registration represents a single visit session (Registered → Checked In → Checked Out). Re-entry requires generating a new visitor pass.
2. **Client-Side Business Logic Enforcement**:
   Because MockAPI.io is a schema-less REST mock without custom server-side functions or triggers, state transitions and input validation rules are strictly enforced client-side within the Flutter application.
3. **Background Cloud Synchronization**:
   The application is fully offline-first. When network connectivity is active, local updates, status patches, and pending deletes automatically harmonize with MockAPI.io.
4. **MockAPI Free Plan Constraints**:
   MockAPI.io free tier rate limits (100 requests per minute, maximum 100 resources per project) apply.
5. **Platform Testing Focus**:
   The app includes full Android and iOS configurations; however, primary physical hardware and automated test suite verification was conducted on Android.
