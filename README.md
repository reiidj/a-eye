# A-Eye: Cataract Maturity Classification

This is the official Android implementation for our undergraduate thesis: **"A-EYE: CATARACT MATURITY CLASSIFICATION IN PUPIL IMAGES USING RADIAL-AWARE MOBILEVIT AND SEMANTIC-AWARE AUGMENTATION WITH SIGMOID ACTIVATION."**

This application provides a real-world, on-device system for classifying the maturity level of cataracts from pupil images, using a lightweight, novel, and highly accurate deep-learning model.

<br>

## ⬇️ Download APK here ⬇️

You can download and install the latest APK directly from here:

[**Download A-Eye.apk**](https://drive.google.com/drive/u/1/folders/1p-fPbZVsGuAwlhuo3jJSShyLPXr36cU2)

<br>

## 🌟 Key Features

* **Novel Deep Learning Model:** Implements a **Radial-Aware MobileViT**, a custom lightweight architecture designed to be highly effective for analyzing the unique radial patterns of pupil images.
* **High-Accuracy Classification:** Accurately classifies the maturity of cataracts (e.g., [List the classes, like 'Immature', 'Mature', 'Hypermature']).
* **Semantic-Aware Augmentation:** The model was trained using a novel semantic-aware augmentation strategy to improve robustness and accuracy, even in varied lighting conditions.
* **On-Device Deployment:** The entire classification pipeline runs 100% locally on the Android device using **TensorFlow Lite**, ensuring user privacy and offline functionality.
* **API & Validation:** Includes a backend API and database for validating, storing, and tracking classification results (as demonstrated by the `API-Model-Validation` branch).

<br>

## 📸 Screenshots

*(This is the most important section! Show the app analyzing an eye image and giving a classification.)*

| 1. Main Screen / Image Upload | 2. Classification Result |
| :---: | :---: |
| <img src="https.github.com/user-attachments/assets/4ffcc72f-cb9e-4ef6-af1d-a4e381c275a2" alt="3 - Main" width="250"> | <img src="https.github.com/user-attachments/assets/70b4a9da-5442-434b-8ff8-cedab16dd351" alt="8 1 1 - Vald Image_ Crop" width="250"> |

<br>

## 🛠️ Tech Stack & Tools

* **Language:** **Flutter (Dart)** for the mobile app, **Python** for the ML model & API
* **UI:** Flutter Widgets (using `StatefulWidget` for state)
* **Machine Learning:** **TensorFlow Lite**, **MobileViT** (Custom Model)
* **Networking:** `http` package (to call the Hugging Face API)
* **Database:** **Cloud Firestore** (for user data and scan history)

<br>

## 🚀 Getting Started

To get a local copy up and running, follow these steps.

### Prerequisites

* Android Studio 
* Android SDK \[28\]

### Installation

1.  Clone the repo
    ```sh
    git clone [https://github.com/reiidj/a-eye.git](https://github.com/reiidj/a-eye.git)
    ```
2.  Open the project in your IDE (Android Studio or VS Code).
3.  Install the required dependencies by running this command in your terminal:
    ```sh
    flutter pub get
    ```
4.  **[IMPORTANT: Add any special instructions here. Since this is a Firebase project, you'll need to configure it. e.g., "You will need to run `flutterfire configure` to add your own `firebase_options.dart` file." or "You will need to add your own API key..."]**
5.  Build and run the application.
    ```sh
    flutter run
    ```
<br>

## 👤 Contact info

Reiidj - [@reiidj](httpsax://github.com/reiidj)

Project Link: [https://github.com/reiidj/a-eye](https://github.com/reiidj/a-eye)
