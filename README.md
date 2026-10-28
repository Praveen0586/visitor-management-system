# Visitor Management App

An offline-first Flutter app for front-desk and security staff at Sumadhura to register visitors, generate and scan QR passes, and record check-in / check-out. Data is stored through a mock REST API (MockAPI.io) and cached on the device.

## Screenshots

| Dashboard | Visitor List | Registration |
| :---: | :---: | :---: |
| <img src="https://github.com/user-attachments/assets/1046fa6a-9c13-45da-bc31-e133acdf9010" alt="Dashboard" width="220"> | <img src="https://github.com/user-attachments/assets/35a00f07-7e7e-465f-b567-7af531b6a95b" alt="Visitor List" width="220"> | <img src="https://github.com/user-attachments/assets/46c7d971-044e-4760-bbc1-56abcd961489" alt="Registration" width="220"> |

| Visitor Details (Check-in) | Visitor Details (Check-out) |
| :---: | :---: |
| <img src="https://github.com/user-attachments/assets/5dc8a912-48f8-4331-9c1d-48d50c023554" alt="Visitor Details - Check-in" width="220"> | <img src="https://github.com/user-attachments/assets/d43d5fd2-15f2-42bf-8723-9adc61037867" alt="Visitor Details - Check-out" width="220"> |

| QR Scanner | Camera Permission |
| :---: | :---: |
| <img src="https://github.com/user-attachments/assets/e82f47b8-9921-4273-9692-c03dcb5e4cf0" alt="QR Scanner" width="220"> | <img src="https://github.com/user-attachments/assets/c926aa19-b1a1-44a7-aa8f-afe9ea5b7f14" alt="Camera Permission Handling" width="220"> |

## Features

- **Dashboard:** Total Visitors Today, Currently Checked In, Checked Out Today, with shortcuts to Register, Visitors and Scan.
- **Registration / Edit:** validated form (name, 10-digit mobile, optional email, type, project, purpose). Default status is `Registered`.
- **Visitor list:** search by name or mobile, status filter, pull-to-refresh, view, edit and delete (with confirmation).
- **QR pass:** generated after registration and shown on the details screen.
- **QR scanner:** camera scan, visitor lookup, error messages for invalid QR and unknown visitor, duplicate-scan protection, camera-permission message.
- **Check-in / Check-out:** `Registered -> Checked In -> Checked Out`. Invalid transitions are blocked, and the list and dashboard update immediately.
- **Offline cache:** visitors are cached locally and synced with the API when online.

## Offline-First Design

The app keeps working without internet and syncs with the API when it is back.

- **Local first:** visitors are saved to local storage (`SharedPreferences`) and the UI updates immediately.
- **Fast startup:** cached visitors are shown first, then refreshed from the API.
- **Offline actions:** registration, check-in, check-out and QR generation work without internet.
- **Sync:** offline changes are flagged as pending (`isPendingSync`) and pushed to MockAPI when online or on pull-to-refresh. Deletes made offline are queued so they are not re-created by the next sync.

## Environment

```text
Flutter  : 3.41.9 (stable channel)
Dart     : 3.11.5
JDK      : OpenJDK 25.0.2 LTS (Temurin-25.0.2+10)
Android  : Min SDK 21 (tested on Android)
```

## Setup

```bash
git clone https://github.com/Praveen0586/visitor-management-system.git
cd visitor-management-system
flutter pub get
flutter run
```

Build the APK:

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

## Packages

| Package | Purpose |
|---|---|
| `dio` | REST API calls |
| `provider` | State management |
| `qr_flutter` | QR generation |
| `mobile_scanner` | QR scanning |
| `shared_preferences` | Local cache |
| `google_fonts` | Typography |

## Architecture and State Management

MVVM with Provider.

- **Model:** `Visitor` (JSON parsing, status helpers)
- **Services:** `ApiServices` (Dio) and `LocalStorageService` (cache)
- **ViewModel:** `DashboardViewModel` (`ChangeNotifier`)
- **Views:** screens and reusable widgets in `core/widgets`

```
Views (screens, widgets)  ->  ViewModel (Provider)  ->  Services (Dio, local cache)  ->  MockAPI
```

### State Management

Provider was chosen for its simplicity. One ViewModel owns the visitor list, so the list, details screen and dashboard counts stay in sync after every check-in or check-out.

- Screens read state with `context.watch` and trigger actions with `context.read`.
- Dashboard counts, search results and the status filter are computed from the same list, so they cannot drift out of sync.
- API errors are caught in the service, and the ViewModel exposes a message that the UI shows in a SnackBar or error view.

### Folder Structure

```
lib/
├── main.dart                 # App entry, Provider setup
├── core/
│   ├── configs/
│   │   ├── api/              # API endpoints and Dio service
│   │   ├── storage/          # Local cache (SharedPreferences)
│   │   └── theme/            # Light and dark theme
│   ├── utils/                # Validators, share helper
│   └── widgets/              # Reusable UI components
└── features/
    └── dashboard/
        ├── models/           # Visitor model
        ├── viewmodels/       # DashboardViewModel (state + business rules)
        └── views/            # Dashboard, list, form, details, scanner screens
test/                         # Unit and widget tests
screenshots/                  # Images used in this README
```

## Mock API

- **Provider:** MockAPI.io
- **Base URL:** `https://6ae04ff4be3bc8fead96dfd7.mockapi.io/api/v1`

| Method | Endpoint | Purpose |
|---|---|---|
| GET | `/visitors` | List visitors |
| GET | `/visitors/{id}` | Visitor details |
| POST | `/visitors` | Register visitor |
| PUT | `/visitors/{id}` | Edit visitor |
| PATCH | `/visitors/{id}` | Check-in / check-out |
| DELETE | `/visitors/{id}` | Delete visitor |

Sample record:

```json
{
  "id": "1",
  "name": "Rahul Sharma",
  "mobile": "9876543210",
  "email": "rahul@example.com",
  "visitor_type": "Customer",
  "project": "Project A",
  "purpose": "Site Visit",
  "status": "Registered",
  "created_at": "2026-10-28T09:30:00+05:30",
  "check_in_time": null,
  "check_out_time": null
}
```

The API stays online during evaluation. Please do not press **Reset** or **Generate** in the MockAPI dashboard, as it overwrites the records.

## How to Test

1. Open the app and check the dashboard counts.
2. Register a visitor. The QR pass opens.
3. Show the QR on one screen, then scan it from the **Scan** tab on another device.
4. Tap **Check In**, then **Check Out**. Confirm the dashboard counts change.
5. Search by name or mobile in the **Visitors** tab.

## Known Limitations

- One visit session per registration; no visit history.
- Validation and status rules are enforced in the app, because the mock API has no server logic.
- Needs internet to sync with the API; offline changes sync later.
- Tested on Android only.

## Submission

- **APK:** [Download](https://drive.google.com/file/d/1qq1JFe5NXPTSyZDm3MPKeY9iXPon4m0O/view?usp=sharing)
