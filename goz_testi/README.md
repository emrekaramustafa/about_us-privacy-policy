# Göz Testi - Eye Test Mobile Application

Professional eye testing application built with Flutter, supporting both iOS and Android platforms.

## 📱 Features

### Current Tests
- **Visual Acuity (Snellen E Test)** - Tests visual sharpness using the tumbling E optotype
- **Color Vision (Ishihara)** - Color blindness screening with simulated Ishihara plates  
- **Astigmatism Test** - Radial line dial test for detecting astigmatism

### App Features
- 🎨 Clean, minimalist medical-grade UI design
- 📐 Screen-calibrated test elements for accuracy
- 📊 Detailed test results with recommendations
- 📄 PDF report generation (Premium)
- 🔒 Paywall for premium features

## 🏗️ Architecture

This project follows **Clean Architecture** principles:

```
lib/
├── core/
│   ├── theme/          # App theme & colors
│   ├── router/         # Navigation (go_router)
│   ├── utils/          # Screen calibration, helpers
│   ├── constants/      # App strings & constants
│   └── widgets/        # Shared widgets
├── features/
│   ├── splash/         # Splash screen
│   ├── disclaimer/     # Legal disclaimer
│   ├── home/           # Home screen with test grid
│   ├── tests/
│   │   ├── visual_acuity/   # Snellen E test
│   │   ├── color_vision/    # Ishihara test
│   │   └── astigmatism/     # Astigmatism dial test
│   ├── result/         # Test results & reports
│   └── paywall/        # Premium subscription
└── main.dart
```

## 🛠️ Tech Stack

- **State Management**: Riverpod
- **Navigation**: go_router
- **Fonts**: Google Fonts (Inter)
- **Icons**: Lucide Icons
- **PDF Generation**: pdf, printing packages
- **Architecture**: Clean Architecture

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.5.0 or higher)
- Dart SDK
- iOS Simulator or Android Emulator

### Installation

1. Clone the repository
```bash
cd goz_testi
```

2. Install dependencies
```bash
flutter pub get
```

3. Run the app
```bash
flutter run
```

### Build for Production

**Android:**
```bash
flutter build apk --release
```

**iOS:**
```bash
flutter build ios --release
```

## 📏 Screen Calibration

The app uses a calibration system based on screen width to ensure test elements maintain accurate sizes across different devices. The reference device is iPhone 14 Pro (393pt width).

Key calibration features:
- Dynamic font sizing for test elements
- Snellen E size calculations for each acuity level
- Viewing distance recommendations

## ⚠️ Disclaimer

**This application is for informational and entertainment purposes only.**

- It does NOT provide medical diagnosis
- Results do not replace professional eye examinations
- Test accuracy may vary based on screen quality, brightness, and viewing conditions
- Always consult an eye care professional for actual vision concerns

## 📋 Test Descriptions

### Visual Acuity (Snellen E)
- Displays the "tumbling E" optotype in decreasing sizes
- Tests vision from 20/200 to 20/10
- 3 questions per level, 2 correct to advance
- Random rotation: up, down, left, right

### Color Vision (Ishihara)
- 6 simulated Ishihara plates
- User identifies hidden numbers
- Tests for red-green color blindness
- Results indicate normal vision or potential deficiency

### Astigmatism
- Radial line dial with 12 lines
- User evaluates if all lines appear equal
- Tests each eye separately
- Identifies potentially affected meridians

## 🎨 Design System

**Colors:**
- Primary: Medical Blue (#2563EB)
- Secondary: Medical Teal (#0D9488)
- Background: Clean White (#FAFAFA)
- Premium: Gold (#D97706)

**Typography:**
- Font Family: Inter (Google Fonts)
- Weights: 400 (Regular), 500 (Medium), 600 (SemiBold), 700 (Bold)

## 📄 License

This project is proprietary. All rights reserved.

## 👨‍💻 Developer

Built with ❤️ using Flutter

---

**Version:** 1.0.0  
**Last Updated:** January 2026

