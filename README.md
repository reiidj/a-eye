# A-EYE: Cataract Maturity Classification

This is the official mobile implementation for the undergraduate thesis: **"A-EYE: Cataract Maturity Classification in Pupil Images Using Radial-Aware MobileViT and Semantic-Aware Augmentation with Sigmoid Activation."**

This application provides a real-world, on-device system for classifying the maturity level of cataracts from pupil images. It leverages a novel, lightweight, and highly accurate deep-learning model designed specifically for mobile deployment.

## Download

You can download and install the latest Android build directly from our releases.
* **[Download Latest A-Eye APK](https://drive.google.com/drive/folders/1dUZsaA_YMFwDLsnimx_p6r-dFw2Z_5za?usp=drive_link)**

## Key Features

* **Novel Deep Learning Model:** Implements a **Radial-Aware MobileViT**, a custom lightweight architecture designed to effectively analyze the unique radial patterns of pupil images.
* **High-Accuracy Classification:** Accurately classifies the maturity of cataracts (e.g., Immature, and Mature).
* **Semantic-Aware Augmentation:** The model is trained using a novel augmentation strategy to improve robustness and accuracy across varied lighting conditions.
* **On-Device Deployment:** The classification pipeline runs entirely locally on the Android device using **TensorFlow Lite**, ensuring user privacy and offline functionality.
* **API & Validation:** Includes a Python backend API and database for validating, storing, and tracking classification results.

## Screenshots

| Image Upload | Classification Result |
| :---: | :---: |
| *(screenshot link placeholder)* | *(screenshot link placeholder)* |

## Tech Stack & Tools

* **Frontend:** Flutter (Dart)
* **Backend/ML:** Python, TensorFlow Lite, Custom MobileViT
* **Networking:** `http` package (Hugging Face API integration)
* **Database:** Cloud Firestore

## Getting Started

To get a local copy up and running for development, follow these steps.

### Prerequisites
* Android Studio
* Android SDK (API Level 28+)
* Flutter SDK

### Installation

1. Clone the repository:
   ```bash
   git clone [https://github.com/reiidj/a-eye.git](https://github.com/reiidj/a-eye.git)

2. Open the project in your preferred IDE (Android Studio or VS Code).

3. Install the required Flutter dependencies:
    ```bash
    flutter pub get

4. Firebase Configuration: This project requires Firebase. You must configure your own Firebase project and run
   ```bash
   flutterfire configure
   ```
   This generates the required firebase_options.dart file.

6. Build and run the application:
    ```bash
    flutter run

### Contact
Rei Djemf M. Rivera - @reiidj
Project Link: https://github.com/reiidj/a-eye
