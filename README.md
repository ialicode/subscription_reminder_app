# Subs Reminder (Subscription Reminder App POC)

A beautiful, fully functional Proof of Concept (POC) Flutter application for managing and tracking your subscriptions.

## Overview

Subs Reminder helps you keep track of your recurring expenses, such as streaming services, utilities, and gym memberships. It provides a clean, modern dashboard to view your active subscriptions, total monthly/yearly costs, and upcoming renewals so you're never caught off guard by an auto-renewal.

## Features

- **Authentication System:** Secure local login and registration with validation (Note: POC uses local storage, no backend required).
- **Dashboard Summary:** View total active subscriptions and upcoming renewals at a glance.
- **Manage Subscriptions:** Add, Edit, and Delete subscriptions with custom names, categories, amounts, start dates, and renewal dates.
- **Categorization:** Pre-defined categories (Entertainment, Education, Utilities, Health/Fitness) plus a custom "Other" option.
- **Filtering:** Quickly filter your subscriptions by status (All, Active, Expiring soon, Expired).
- **Native Splash Screen:** Seamless app launch experience using a native splash screen.

## Technical Stack & Architecture

This app was built adhering to modern Flutter best practices:

- **Framework:** Flutter SDK
- **State Management:** `flutter_bloc` (Bloc and Cubit) for predictable state management across the app.
- **Local Storage:** `shared_preferences` to persist users and subscription data as JSON locally without needing a backend.
- **Styling:** `google_fonts` (Poppins) for modern typography, with a centralized theming engine (`AppTheme`).
- **Icons & Assets:** Custom app icons configured via `flutter_launcher_icons` and `flutter_native_splash`.

### Project Structure

The project follows a feature-based folder structure for scalability:
```
lib/
 ┣ core/              # Global constants, themes, and utilities
 ┣ data/              # Data models (User, Subscription) and repositories
 ┣ features/          
 ┃ ┣ auth/            # Bloc and UI for Login/Registration
 ┃ ┗ subscriptions/   # Bloc and UI for Dashboard and Add/Edit screens
 ┗ main.dart          # Entry point and route initialization
```

## Getting Started

To run this app locally:

1. Ensure you have the [Flutter SDK](https://docs.flutter.dev/get-started/install) installed.
2. Clone this repository.
3. Fetch the dependencies:
   ```bash
   flutter pub get
   ```
4. Run the app on your preferred emulator or physical device:
   ```bash
   flutter run
   ```

*(Note: Since this is a POC using local storage, clearing your app data or uninstalling the app will wipe your local users and subscriptions).*
