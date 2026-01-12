# Development Setup

This guide will help you set up the Restaurantzz project for local development.

## Prerequisites

- [Git](https://git-scm.com/) (latest stable version)
- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Flutter Version Management (FVM)](https://fvm.app/)
- An IDE ([VS Code](https://code.visualstudio.com/download),
[Android Studio](https://developer.android.com/studio), etc.)

## Setup Steps

### 1. Clone the repository

```bash
git clone https://github.com/waffiqaziz/restaurantzz.git
cd restaurantzz
```

### 2. Flutter Version Management (FVM)

This project uses FVM (Flutter Version Management) to ensure consistency across
development environments.

Install and use the required Flutter version `3.38.6` via FVM:

```bash
fvm install 3.38.6
fvm use 3.38.6
```

### 3. Install dependencies

```bash
flutter pub get
```

### 4. Run the application

```bash
flutter run
```
