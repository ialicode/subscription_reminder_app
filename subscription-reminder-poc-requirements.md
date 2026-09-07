# Smart Package & Subscription Reminder App

## Proof-of-Concept Requirements

### 1. Project goal

Build a simple Android mobile application that lets a user create an account, sign in, and manually manage personal subscriptions such as Netflix, Jazz packages, gym memberships, and utility bills.

The proof of concept only needs to demonstrate the main user flow. It is not intended for production use.

### 2. POC scope

The POC contains two modules:

1. User Management
2. Subscription Management

### 3. User Management

#### Registration

The registration form must contain only:

- First name
- Last name
- Email address
- Password
- Confirm password
- Gender: Male or Female

Required behavior:

- All fields are required.
- Email must use a valid format and must not already be registered.
- Password must contain at least 6 characters.
- Confirm password must match the password.
- Successful registration creates the account and takes the user to the dashboard.

#### Login

- A registered user can log in with email and password.
- Invalid credentials display a clear error.
- Successful login opens the subscription dashboard.

#### Authentication and logout

- Subscription screens are available only to a logged-in user.
- A user can log out from the application.
- After logout, the user returns to the login screen and cannot access protected screens.

### 4. Subscription Management

#### Add a subscription

The user can create a subscription with:

- Subscription name, required
- Category, required
- Start date, required
- Expiry or renewal date, required
- Amount, optional
- Notes, optional

Suggested categories:

- Entertainment
- Education
- Utilities / Bills
- Health / Fitness
- Finance
- Other

If `Other` is selected, the user can type a custom category.

Validation:

- Subscription name cannot be empty.
- Expiry or renewal date cannot be earlier than the start date.
- Amount, when entered, must be zero or greater.

#### View subscriptions

The dashboard displays the logged-in user's subscriptions only.

It includes:

- Total active subscriptions
- Total expired subscriptions
- Expiring-soon subscriptions
- A list showing subscription name, category, expiry or renewal date, amount when available, and status

The user can filter the list by:

- All
- Active
- Expiring soon
- Expired

#### Subscription status rules

Status is calculated automatically from the expiry or renewal date:

- `Expired`: the date is before today
- `Expiring Soon`: the date is today or within the next 3 days
- `Active`: the date is more than 3 days away
- `Inactive`: manually archived by the user

No AI or external prediction is required.

#### View details

Selecting a subscription displays all saved fields and its current calculated status.

#### Edit a subscription

The user can update:

- Subscription name
- Category
- Expiry or renewal date
- Amount
- Notes

The same validation rules used when adding a subscription apply when editing it.

#### Remove a subscription

The user can either:

- Mark the subscription as inactive for record keeping, or
- Permanently delete it after confirming the action

### 5. Main screens

1. Login
2. Registration
3. Dashboard and subscription list
4. Add subscription
5. Subscription details
6. Edit subscription

Logout can be available from the dashboard menu. Delete and mark-inactive actions can be available from the details screen.

### 6. Simple data model

#### User

- id
- firstName
- lastName
- email
- gender

The authentication service stores the password securely. The application must not store a plain-text password.

#### Subscription

- id
- userId
- name
- category
- customCategory, optional
- startDate
- expiryOrRenewalDate
- amount, optional
- notes, optional
- isInactive
- createdAt
- updatedAt

Status can be calculated when data is displayed and does not need to be stored.

### 7. Suggested POC technology

- Flutter for the Android application
- Firebase Authentication for registration, login, and sessions
- Cloud Firestore for user and subscription data
- Android Studio or VS Code for development

This keeps the POC small and avoids building a separate backend server.

### 8. Acceptance criteria

The POC is complete when:

- A new user can register with exactly the required registration fields.
- Duplicate or invalid registration data is rejected.
- A registered user can log in and log out.
- Protected screens cannot be opened after logout.
- A user can add a subscription with required and optional fields.
- The dashboard lists only the current user's subscriptions.
- Active, expiring-soon, expired, and inactive states are shown correctly.
- Dashboard active and expired counts are correct.
- A user can view and edit a subscription.
- A user can mark a subscription inactive.
- A user can permanently delete a subscription after confirmation.
- Data remains available after closing and reopening the app.

### 9. Out of scope

The POC does not include:

- Push notifications or Firebase Cloud Messaging
- Background reminder scheduling
- Payment records or payment processing
- Subscription payment history
- Usage tracking
- Smart or AI recommendations
- Service-provider or carrier APIs
- Automatic subscription discovery
- Admin portal
- Social login
- Password reset or email verification
- Multi-language support
- iOS release
- Production deployment, analytics, monitoring, backups, scaling, or security hardening

### 10. Demo flow

1. Register a user.
2. Log in.
3. Add one active, one expiring-soon, and one expired subscription.
4. Verify the dashboard counters and filters.
5. Open and edit a subscription.
6. Mark one subscription inactive.
7. Permanently delete another subscription.
8. Log out and confirm the dashboard is no longer accessible.
