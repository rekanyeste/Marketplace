# 🛍️ Nearbuy - Local Marketplace App

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" />
  <img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" />
  <img src="https://img.shields.io/badge/Riverpod-000000?style=for-the-badge&logo=dart&logoColor=white" />
</p>

A beautifully designed, feature-rich local marketplace application built with Flutter and Firebase. **Nearbuy** connects people in their local community to buy and sell items easily and securely.

## ✨ Features

- **User Authentication:** Secure login and registration using Firebase Auth.
- **Browse & Search:** Easily discover items nearby with categories and search functionality.
- **Sell Items:** Quick and intuitive listing creation with image uploads and local compression.
- **Real-time Database:** Fast and reliable data syncing using Cloud Firestore.
- **Profile Management:** Manage your listings, favorites, and account details.
- **Modern UI:** Smooth animations, Google Fonts typography, and responsive design tailored for mobile devices.

## 🛠️ Tech Stack

- **Framework:** [Flutter](https://flutter.dev/)
- **State Management:** [Riverpod](https://riverpod.dev/)
- **Routing:** [go_router](https://pub.dev/packages/go_router)
- **Backend:** Firebase (Firestore, Auth, Storage, Cloud Messaging)
- **Other Key Packages:**
  - `image_picker` & `flutter_image_compress` for media handling
  - `cached_network_image` for optimized image loading
  - `google_fonts` for typography

## 🚀 Getting Started

Follow these instructions to get a copy of the project up and running on your local machine.

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (^3.7.0)
- Firebase CLI and a Firebase Project

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/nearbuy.git
   cd nearbuy
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase:**
   Ensure you have the Firebase CLI installed and run the following command to link your Firebase project:
   ```bash
   flutterfire configure
   ```

4. **Run the app:**
   ```bash
   flutter run
   ```

## 📄 License

This project is licensed under the MIT License.
