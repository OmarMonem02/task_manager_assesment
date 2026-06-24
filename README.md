# Task Manager

A Flutter assessment project built using **Clean Architecture**, **BLoC State Management**, and modern Flutter development practices.

## Features

* Create, update, and delete tasks
* Mark tasks as completed
* Offline data persistence
* API integration using Dio
* Dependency Injection using GetIt
* State Management using BLoC
* Responsive UI across different screen sizes
* Internet connection monitoring
* Loading skeletons and image caching

---

## Project Structure

```text
lib/
├── core/
│   ├── di/
│   │   └── dependency_injection.dart
│   │
│   ├── network/
│   │   ├── api_constants.dart
│   │   ├── api_result.dart
│   │   └── dio_factory.dart
│   │
│   ├── routes/
│   │   └── app_router.dart
│   │
│   └── storage/
│       └── shared_pref_helper.dart
│
├── features/
│   ├── auth/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── profile/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   └── projects/
│       ├── data/
│       ├── domain/
│       └── presentation/
│
└── main.dart
```

### Core Layer

The `core` module contains shared services and utilities used across the entire application:

* **Dependency Injection** using GetIt
* **Network Layer** using Dio
* **Application Routing** using GoRouter
* **Local Storage** using SharedPreferences

### Feature Modules

Each feature follows Clean Architecture principles and is divided into three layers:

#### Data Layer

Contains:

* Models
* Data Sources
* Repository Implementations

#### Domain Layer

Contains:

* Entities
* Repository Contracts
* Business Logic

#### Presentation Layer

Contains:

* Screens
* Widgets
* BLoC/Cubit
* States & Events

### Available Features

#### Authentication

Handles:

* User Login
* User Registration
* Authentication Flow

#### Projects

Handles:

* Project Listing
* Project Details
* Project Management

#### Profile

Handles:

* User Information
* Profile Management
* User Settings

---

## Packages

### State Management

```yaml
equatable: ^2.0.8
flutter_bloc: ^9.1.1
```

### Dependency Injection

```yaml
get_it: ^9.2.1
```

### Networking

```yaml
dio: ^5.9.2
pretty_dio_logger: ^1.4.0
```

### Navigation

```yaml
go_router: ^17.3.0
```

### Local Storage

```yaml
shared_preferences: ^2.5.5
```

### UI & Responsive Design

```yaml
flutter_screenutil: ^5.9.3
flutter_svg: ^2.3.0
skeletonizer: ^2.1.3
cached_network_image: ^3.4.1
```

### Utilities

```yaml
internet_connection_checker_plus: ^3.1.0
```

---

## Getting Started

### Prerequisites

* Flutter SDK (latest stable version)
* Dart SDK
* Android Studio / VS Code

### Installation

1. Clone the repository

```bash
git clone <repository-url>
```

2. Navigate to the project directory

```bash
cd taskmanager
```

3. Install dependencies

```bash
flutter pub get
```

4. Run the project

```bash
flutter run
```

---

## Build APK

```bash
flutter build apk --release
```

---

## Project Highlights

* Clean Architecture
* Repository Pattern
* BLoC Pattern
* Dependency Injection
* Scalable Feature-Based Structure
* Offline Support
* API Integration
* Responsive UI
* Network Monitoring
* Reusable Components

---

## Author

Omar Abdelmonem
Flutter Developer
