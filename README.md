# ROKON Coffee | رُكن
### Smart Coffee Ordering & Order Management Application

<p align="center">

**ROKON Coffee – رُكن**

A Flutter-based coffee ordering application designed for the Yemeni market.

Built with Flutter, Dart, and Supabase.

</p>

---

## 1. Project Overview

ROKON Coffee is a coffee ordering application developed to simplify the pre-ordering experience for specialty coffee customers.

The application allows customers to explore coffee products, customize their orders, select pickup methods, and track order progress.

It also provides an employee interface for managing incoming orders and updating their statuses.

The application supports Arabic RTL interfaces and both light and dark themes.

### Project Objectives

- Simplify the coffee pre-ordering process.
- Improve communication between customers and employees.
- Provide clear and accessible order tracking.
- Reduce waiting time at the coffee shop.
- Deliver a responsive and user-friendly mobile experience.

---

## 2. Application Features

### Customer Features

- Browse available coffee products.
- Filter products by category.
- View product descriptions and prices.
- Select products and quantities.
- Customize coffee options, including size, milk, sugar, and extras.
- Create new orders.
- Select a pickup method.
- Track order progress.
- View order status updates.
- Cancel orders with a cancellation reason.
- View notification history.
- Manage application preferences.

### Employee Features

- View incoming customer orders.
- Access order details.
- Monitor order status.
- Update order status.
- Mark orders as ready.
- Cancel orders and record cancellation reasons.

### Additional Features

- Light and dark themes.
- Arabic RTL support.
- QR code generation for order identification.
- Branch and pickup preferences.
- Payment preferences.
- Coffee preference settings.

---

## 3. Technology Stack

| Technology | Purpose |
|---|---|
| Flutter | Cross-platform application development |
| Dart | Programming language |
| Supabase | Backend and database services |
| PostgreSQL | Relational database |
| QR Flutter | QR code generation |
| Cached Network Image | Network image caching |
| Package Info Plus | Application information |
| IBM Plex Sans Arabic | Arabic typography |

---

## 4. Application Requirements

Before running the project, ensure that you have:

- Flutter SDK compatible with the project's SDK constraints.
- Dart SDK compatible with Flutter.
- Android Studio or Visual Studio Code.
- Android SDK for Android development.
- Xcode for iOS development on macOS.
- A Supabase account if using the remote backend.

Check the installed versions:

```bash
flutter --version
dart --version
```

---

## 5. Project Setup

### Step 1 – Get the Project

Open the project directory using Android Studio or Visual Studio Code.

If the project is hosted on GitHub, clone it using the actual repository URL:

```bash
git clone YOUR_REPOSITORY_URL
cd rokon-coffee
```

### Step 2 – Install Dependencies

Run:

```bash
flutter pub get
```

### Step 3 – Configure Supabase

The application uses Supabase for backend services and database management.

Supabase Project Information:

| Property | Value |
|---|---|
| Project Name | ROKON Coffee |
| Project URL | https://ldbmjaxuluuonofldipw.supabase.co |
| Region | eu-west-2 |
| Plan | Free |

To configure the connection:

1. Open your Supabase dashboard.
2. Navigate to Project Settings.
3. Open API settings.
4. Copy the Project URL.
5. Copy the public client key.
6. Update the configuration in:

`lib/services/supabase_service.dart`

Example:

```dart
class SupabaseConfig {
  static const url = 'YOUR_SUPABASE_URL';
  static const anonKey = 'YOUR_SUPABASE_PUBLIC_KEY';
}
```

Never include the Supabase service role key in the Flutter application.

### Step 4 – Initialize Supabase

Ensure that Supabase is initialized before using its services.

Example:

```dart
await Supabase.initialize(
  url: SupabaseConfig.url,
  anonKey: SupabaseConfig.anonKey,
);
```

---

## 6. Database Structure

The application uses PostgreSQL through Supabase.

The main database tables are:

### Categories

Stores coffee product categories.

| Column | Type | Description |
|---|---|---|
| id | UUID | Category identifier |
| name_ar | TEXT | Arabic category name |
| name_en | TEXT | English category name |
| sort_order | INT4 | Display order |

### Products

Stores available coffee products.

| Column | Type | Description |
|---|---|---|
| id | UUID | Product identifier |
| category_id | UUID | Related category |
| name_ar | TEXT | Arabic product name |
| name_en | TEXT | English product name |
| description_ar | TEXT | Product description |
| price | NUMERIC | Product price |
| image_url | TEXT | Product image |
| is_available | BOOLEAN | Availability status |
| is_featured | BOOLEAN | Featured product |

### Orders

Stores customer orders and their details.

| Column | Type | Description |
|---|---|---|
| id | UUID | Order identifier |
| order_code | TEXT | Order reference |
| customer_name | TEXT | Customer name |
| pickup_mode | TEXT | Pickup method |
| items | JSONB | Ordered products |
| total | NUMERIC | Order total |
| status | TEXT | Current order status |
| cancel_reason | TEXT | Cancellation reason |
| estimated_ready_at | TIMESTAMPTZ | Estimated preparation time |
| created_at | TIMESTAMPTZ | Order creation time |

### Order Statuses

| Status | Description |
|---|---|
| pending | New order |
| preparing | Order is being prepared |
| ready | Order is ready for pickup |
| cancelled | Order has been cancelled |

The application should maintain consistent status values between the database and the Flutter application.

---

## 7. Security and Database Policies

Supabase Row Level Security (RLS) should be enabled for all tables containing application data.

Recommended security practices:

- Allow public read access only to product information intended for customers.
- Restrict order creation to validated requests.
- Restrict order updates to authorized employee accounts.
- Prevent unauthorized access to other customers' order information.
- Validate cancellation reasons and order status transitions.
- Never expose service role credentials in client-side code.

For production deployment, employee permissions should be enforced through authenticated users and database policies.

---

## 8. Application Workflow

### Customer Workflow

1. Open the application.
2. Browse available coffee products.
3. Select a coffee product.
4. Customize the order.
5. Enter customer information.
6. Select the pickup method.
7. Confirm the order.
8. Receive an order reference.
9. Track the order status.
10. Collect the order when it is ready.

### Employee Workflow

1. Open the employee interface.
2. View incoming orders.
3. Select an order.
4. Review its details.
5. Update the order status.
6. Mark the order as ready.
7. Cancel an order when necessary and enter the reason.

---

## 9. Order Cancellation

The application supports an additional cancelled status.

When an order is cancelled:

- The order status changes to `cancelled`.
- A cancellation reason is recorded.
- The customer can view the updated status.
- The order remains identifiable in the order history.

Cancellation should be handled consistently across the employee and customer interfaces.

---

## 10. Project Structure

```text
lib/
│
├── main.dart
│
├── theme/
│   └── app_theme.dart
│
├── models/
│   └── order_model.dart
│
├── data/
│   └── mock_data.dart
│
├── services/
│   └── supabase_service.dart
│
├── screens/
│   ├── splash_screen.dart
│   ├── create_order_screen.dart
│   ├── order_tracking_screen.dart
│   ├── staff_screen.dart
│   ├── notifications_screen.dart
│   └── settings_screen.dart
│
└── widgets/
    ├── custom_button.dart
    ├── custom_parent_widget.dart
    ├── order_status.dart
    └── coffee_card.dart
```

The structure separates application screens, reusable components, models, data, services, and themes to improve maintainability.

---

## 11. Design System

### Color Palette

| Design Element | Light Theme | Dark Theme |
|---|---|---|
| Primary Background | #FFFFFF | #121212 |
| Secondary Background | #F8F6F1 | #1E1E1E |
| Primary Color | #5D4037 | #D4A373 |
| Secondary Color | #8B6B5A | #A67C52 |
| Accent Color | #D7B899 | #F5D7B1 |

### Typography

Font Family: IBM Plex Sans Arabic

### Interface Direction

- Arabic-first interface.
- Right-to-left layout.
- Responsive screen layouts.
- Consistent spacing and reusable components.
- Light and dark theme support.

---

## 12. Running the Application

Check connected devices:

```bash
flutter devices
```

Run on Android:

```bash
flutter run
```

Run on Chrome, if supported:

```bash
flutter run -d chrome
```

---

## 13. Testing and Code Analysis

Run automated tests:

```bash
flutter test
```

Run tests with detailed output:

```bash
flutter test --reporter=expanded
```

Analyze the project:

```bash
flutter analyze
```

Testing should cover:

- Creating a new order.
- Displaying order details.
- Updating order statuses.
- Tracking order progress.
- Cancelling orders.
- Saving cancellation reasons.
- Switching between light and dark themes.

---

## 14. Building the Android APK

To generate a release APK:

```bash
flutter build apk --release
```

The generated APK is located at:

```text
build/app/outputs/flutter-apk/app-release.apk
```

To install the APK on a connected Android device:

```bash
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

The release APK can be included with the project submission for direct application testing.

---

## 15. Building for iOS

iOS builds require macOS and Xcode.

Run:

```bash
flutter build ios --release
```

Additional signing and provisioning configuration may be required before installing or distributing the application.

---

## 16. Project Scope and Implementation Notes

ROKON Coffee was developed as a practical application project covering customer ordering, order tracking, and employee order management.

The implementation includes the core requirements of the ordering workflow and additional features intended to improve the user experience.

The project documentation describes the intended application architecture and setup process. Actual backend availability and feature behavior depend on the configured Supabase project and the implemented application version.

---

## 17. Deliverables

The project submission includes:

| Deliverable | Description |
|---|---|
| Flutter Source Code | Complete application source |
| README.md | Project documentation |
| Android APK | Installable Android release |
| Decision Log | Development decisions and trade-offs |
| Screenshots | Application interface previews, if included |

---

## 18. License and Ownership

This project was developed as part of the Varius experimental assessment.

The source code and project work remain the property of their creator, subject to the assessment terms agreed upon by the parties.

No commercial use or publication is authorized without the owner's consent.

---

<p align="center">

**ROKON Coffee | رُكن**

Coffee Ordering & Management System

Built with Flutter and Supabase.

**Yemen**

</p>#   R O K O N  
 