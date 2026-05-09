# 🍓 Malina App

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Clean Architecture](https://img.shields.io/badge/Architecture-Clean-brightgreen?style=for-the-badge)
![BLoC](https://img.shields.io/badge/State_Management-BLoC-blue?style=for-the-badge)

A robust, feature-rich Flutter application demonstrating **Clean Architecture**, solid state management, and modern UI practices. Built as a comprehensive technical assignment.

## ✨ Key Features

- **🔐 Local Authentication**: Secure login system with brute-force protection (accounts lock and delete after 3 failed attempts).
- **🛒 Smart Cart System**: Persistent shopping cart with category filtering (Food, Beauty), quantity management, and subtotal calculation.
- **📷 QR Code Scanner**: Integrated QR scanning capability for quick item additions, supporting complex data formats.
- **🎨 Custom UI/UX**: Includes a custom bottom navigation bar, animated category popups, and handcrafted custom painters.
- **📱 Responsive Design**: Fully responsive layout adapting to various screen sizes using safe areas and flexible constraints.

## 🛠 Tech Stack

- **Framework**: [Flutter](https://flutter.dev/) & [Dart](https://dart.dev/)
- **State Management**: [`flutter_bloc`](https://pub.dev/packages/flutter_bloc)
- **Routing**: [`go_router`](https://pub.dev/packages/go_router) (with `ShellRoute`)
- **Dependency Injection**: [`get_it`](https://pub.dev/packages/get_it)
- **Local Storage**: [`shared_preferences`](https://pub.dev/packages/shared_preferences)
- **Code Generation**: [`freezed`](https://pub.dev/packages/freezed) & [`json_serializable`](https://pub.dev/packages/json_serializable)
- **Hardware Integration**: [`mobile_scanner`](https://pub.dev/packages/mobile_scanner)

## 🏗 Architecture (Clean Architecture)

The project adheres to **Clean Architecture** principles and is structured using a **Feature-First** approach to ensure scalability and separation of concerns:

```text
lib/
├── core/               # App-wide configurations (Router, DI, UI components)
└── features/
    ├── auth/           # Authentication feature (Domain, Data, Presentation)
    ├── cart/           # Cart management feature (Domain, Data, Presentation)
    ├── home/           # Main feed and dashboard
    ├── profile/        # User profile
    ├── qr/             # Universal QR scanner implementation
    └── shell/          # Global navigation shell
```

### Data Flow Pattern
1. **UI Layer** dispatches events to the **BLoC**.
2. **BLoC** delegates business logic to **UseCases** (Domain layer).
3. **UseCases** interact with **Repositories** via abstract interfaces.
4. **Repositories** (Data layer) handle data mapping and interact with local storage.
5. **UI Layer** listens to state changes and rebuilds reactively.

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (latest stable)
- Dart SDK

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/RYUU05/malina.git
   cd malina
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate models & DI** (Required for Freezed/JSON Serializable)
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Run the application**
   ```bash
   flutter run
   ```

## 🧪 Testing & Validation

To ensure code quality and architecture compliance, run the following checks:

```bash
# Analyze code for linting errors and best practices
flutter analyze

# Run unit and widget tests
flutter test
```

## 💡 Technical Highlights & Optimizations

- **Debounced Storage Writes**: Cart changes are instantly reflected in the UI but debounced before writing to local storage, optimizing I/O performance.
- **Data Isolation**: User data (carts, attempts, settings) is strictly isolated using unique username-based keys in `SharedPreferences`.
- **ShellRoute Navigation**: Seamless bottom navigation state preservation across top-level screens without re-rendering the entire view tree.
- **Custom Canvas Elements**: Utilizes `CustomPainter` for complex UI overlays, such as the QR scanner viewfinder and decorative assets, avoiding heavy image assets.

---
*Developed using modern Flutter best practices.*
