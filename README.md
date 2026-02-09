# SkillPulse iOS

A real-time task management app built with iOS, Firebase, SwiftUI and Swift.

## 📱 About

SkillPulse iOS is a modern task management application designed for efficient real-time task tracking and collaboration. Built using the latest iOS development technologies, it provides a smooth and intuitive user experience for managing your daily tasks and workflows.

This is the iOS companion to the [SkillPulse Android app](https://github.com/graffiti75/SkillPulse), bringing the same powerful task management capabilities to iPhone and iPad users with a native iOS experience.

## 🎥 Demo

Check out the app in action:

![SkillPulse iOS Demo](https://raw.githubusercontent.com/graffiti75/SkillPulseIOS/refs/heads/master/SkillPulseiOS/media/Simulator%20Screen%20Recording%20-%20iPhone%2017%20Pro%20-%202026-02-09%20at%2015.21.19.gif)

Also, you can check out the full video [here](https://www.youtube.com/shorts/6UDXk_9fOlc).

## ✨ Features

- **Real-time Synchronization**: Tasks sync instantly across all devices using Firebase Firestore
- **Intuitive UI**: Clean, modern interface built with SwiftUI
- **Task Management**: Create, edit, and delete tasks with ease
- **Cloud Storage**: All data securely stored in Firebase Firestore
- **Responsive Design**: Optimized for all iPhone and iPad screen sizes
- **Offline Support**: Continue working even without internet connection

## 🛠️ Tech Stack

- **Language**: Swift
- **UI Framework**: SwiftUI
- **Backend**: Firebase
  - Firebase Authentication
  - Cloud Firestore
- **Architecture**: MVVM (Model-View-ViewModel)
- **IDE**: Xcode

## 📋 Requirements

- iOS 15.0+
- Xcode 14.0+
- Swift 5.7+
- CocoaPods or Swift Package Manager

## 🚀 Getting Started

### Prerequisites

1. Install [Xcode](https://developer.apple.com/xcode/) from the Mac App Store
2. Install [CocoaPods](https://cocoapods.org/) (if not using SPM):
   ```bash
   sudo gem install cocoapods
   ```

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/graffiti75/SkillPulseIOS.git
   cd SkillPulseIOS
   ```

2. Install dependencies:
   ```bash
   pod install
   ```

3. Open the workspace:
   ```bash
   open SkillPulseiOS.xcworkspace
   ```

4. Configure Firebase:
   - Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Add an iOS app to your Firebase project
   - Download the `GoogleService-Info.plist` file
   - Add it to your Xcode project

5. Build and run the project in Xcode (⌘+R)

## 📁 Project Structure

```
SkillPulseiOS/
├── SkillPulseiOS/
│   ├── Models/          # Data models
│   ├── Views/           # SwiftUI views
│   ├── ViewModels/      # View models (MVVM)
│   ├── Services/        # Firebase services
│   ├── Utilities/       # Helper functions
│   └── Resources/       # Assets and configurations
└── SkillPulseiOS.xcodeproj
```

## 🔄 Cross-Platform

SkillPulse is available on other platforms:
- **React**: [SkillPulse React](https://github.com/graffiti75/SkillPulseReact) - Built with React, JavaScript and Node
- **Android**: [SkillPulse Android](https://github.com/graffiti75/SkillPulse) - Built with Kotlin and Jetpack Compose
- **iOS**: This repository - Built with Swift and SwiftUI

Both apps share the same Firebase backend, allowing seamless synchronization across devices.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is open source and available under the [MIT License](LICENSE).

## 👨‍💻 Author

**Rodrigo Cericatto**
- GitHub: [@graffiti75](https://github.com/graffiti75)
- LinkedIn: [Rodrigo Cericatto](https://www.linkedin.com/in/rodrigocericatto/)
- Email: graffiti75@gmail.com

## 🙏 Acknowledgments

- Firebase for providing the real-time backend infrastructure
- SwiftUI for the modern declarative UI framework
- The iOS development community for continuous inspiration

---

⭐ If you find this project useful, please consider giving it a star!
