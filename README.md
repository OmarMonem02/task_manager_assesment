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
│   ├── constants/
│   │   └── app_constants.dart
│   │
│   ├── di/
│   │   └── dependency_injection.dart
│   │
│   ├── errors/
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   │
│   ├── network/
│   │   ├── api_constants.dart
│   │   ├── api_result.dart
│   │   └── dio_factory.dart
│   │
│   ├── routes/
│   │   └── app_router.dart
│   │
│   ├── storage/
│   │   └── shared_pref_helper.dart
│   │
│   ├── theme/
│   │   └── app_theme.dart
│   │
│   └── widgets/
│       ├── app_button.dart
│       ├── app_error.dart
│       ├── app_loading.dart
│       └── app_text_field.dart
│
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── auth_local_datasource.dart
│   │   │   │   └── auth_remote_datasource.dart
│   │   │   ├── models/
│   │   │   │   ├── login_request_model.dart
│   │   │   │   ├── register_request_model.dart
│   │   │   │   └── user_model.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── user_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart
│   │   │   └── usecases/
│   │   │       ├── check_auth_usecase.dart
│   │   │       ├── login_usecase.dart
│   │   │       ├── logout_usecase.dart
│   │   │       └── register_usecase.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── auth_bloc.dart
│   │       │   ├── auth_event.dart
│   │       │   └── auth_state.dart
│   │       ├── pages/
│   │       │   ├── login_page.dart
│   │       │   └── register_page.dart
│   │       └── widgets/
│   │           ├── auth_button.dart
│   │           ├── login_form.dart
│   │           └── register_form.dart
│   │
│   ├── profile/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── profile_local_datasource.dart
│   │   │   ├── models/
│   │   │   │   └── profile_model.dart
│   │   │   └── repositories/
│   │   │       └── profile_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── profile_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── profile_repository.dart
│   │   │   └── usecases/
│   │   │       └── get_profile_usecase.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── profile_bloc.dart
│   │       │   ├── profile_event.dart
│   │       │   └── profile_state.dart
│   │       ├── pages/
│   │       │   └── profile_page.dart
│   │       └── widgets/
│   │           └── profile_header.dart
│   │
│   └── projects/
│       ├── data/
│       │   ├── datasources/
│       │   │   └── projects_remote_datasource.dart
│       │   ├── models/
│       │   │   ├── project_model.dart
│       │   │   └── task_model.dart
│       │   └── repositories/
│       │       └── projects_repository_impl.dart
│       ├── domain/
│       │   ├── entities/
│       │   │   ├── project_entity.dart
│       │   │   └── task_entity.dart
│       │   ├── repositories/
│       │   │   └── projects_repository.dart
│       │   └── usecases/
│       │       ├── add_task_usecase.dart
│       │       ├── get_project_tasks_usecase.dart
│       │       ├── get_projects_usecase.dart
│       │       └── mark_task_done_usecase.dart
│       └── presentation/
│           ├── bloc/
│           │   ├── projects_bloc.dart
│           │   ├── projects_event.dart
│           │   └── projects_state.dart
│           ├── pages/
│           │   ├── project_details_page.dart
│           │   └── projects_page.dart
│           └── widgets/
│               ├── add_task_bottom_sheet.dart
│               ├── empty_projects.dart
│               ├── project_card.dart
│               └── task_card.dart
│
└── main.dart
```

### Core Layer

The `core` module contains shared services and utilities used across the entire application:

* **Constants** — app-wide configuration values
* **Dependency Injection** using GetIt
* **Error Handling** — exceptions and failures
* **Network Layer** using Dio
* **Application Routing** using GoRouter
* **Local Storage** using SharedPreferences
* **Theme** — centralized app styling
* **Reusable Widgets** — shared UI components

### Feature Modules

Each feature follows Clean Architecture principles and is divided into three layers:

#### Data Layer

Contains:

* Models
* Data Sources (local & remote)
* Repository Implementations

#### Domain Layer

Contains:

* Entities
* Repository Contracts
* Use Cases

#### Presentation Layer

Contains:

* Pages
* Widgets
* BLoC (events & states)

### Available Features

#### Authentication

Handles:

* User Login
* User Registration
* Session Check
* Logout

#### Projects

Handles:

* Project Listing
* Project Details
* Task Management (add, list, mark done)

#### Profile

Handles:

* User Information
* Profile Display

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
