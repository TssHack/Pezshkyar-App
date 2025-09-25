# 🩺 Pezshkyar — Smart Medical Assistant

![Pezshkyar Logo](./assets/logo.png)

> **Pezshkyar** is an **intelligent cross-platform medical assistant app** built with **Flutter**. It offers a smooth, responsive, and delightful experience across **Android & iOS**, empowering users with quick access to trusted medical information and an elegant, user-friendly interface.

---

## 🎯 Vision & Goals
- ⚡ Provide **fast & reliable medical guidance** (general, not a replacement for a doctor)
- 🎨 Deliver a **clean, modern, and minimal UI** with **RTL support** (Persian/Farsi)
- ✨ Enhance UX with **professional animations & micro-interactions**
- 📱 Support **cross-platform experience** (Android & iOS) with **local storage** for chat history

---

## 🔥 Preview
📽️ Add a **demo GIF/video** to showcase the app in action:  
`./assets/demo/demo.gif`

---

## ⭐ Core Features
- 🧠 **AI-powered medical Q&A assistant**
- 💬 **Interactive chat interface** with message history
- 🌙 **Light & Dark mode** toggle
- 🔔 **Push notifications**
- 📝 **Quick replies** for common medical FAQs
- 💾 **Secure local storage** for chat history
- 📎 **Share & copy** information easily
- 🌐 **Multilingual support** (RTL ready)
- 🎞️ **Subtle animations** for smooth transitions

---

## 🎨 UI & Animation Recommendations
Boost UX with modern motion design:

- **Lottie animations** (splash, empty states, success/error)
- **Hero animations** (screen-to-screen transitions)
- **AnimatedList & AnimatedSwitcher** (real-time message updates)
- **Shimmer effect** (loading placeholders)
- **Implicit animations** (`AnimatedOpacity`, `AnimatedContainer`)
- **Custom transitions** with `PageRouteBuilder`

### Example: Adding Lottie in `pubspec.yaml`
```yaml
dependencies:
  lottie: ^2.2.0
```

### Example: Lottie Splash Screen + FadeTransition
```dart
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    Future.delayed(Duration(milliseconds: 1800), () {
      Navigator.of(context).pushReplacementNamed('/chat');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Lottie.asset(
          'assets/animations/medical_splash.json',
          controller: _controller,
          onLoaded: (composition) {
            _controller
              ..duration = composition.duration
              ..forward();
          },
          width: 240,
          height: 240,
        ),
      ),
    );
  }
}
```

---

## 🏗️ Project Structure
```
lib/
├── config/
│   ├── app_routes.dart
│   ├── constants.dart
│   └── theme.dart
├── models/
│   └── message_model.dart
├── screens/
│   ├── chat_screen.dart
│   ├── settings_screen.dart
│   └── splash_screen.dart
├── services/
│   ├── api_service.dart
│   ├── notification_service.dart
│   └── storage_service.dart
├── widgets/
│   ├── chat_bubble.dart
│   ├── custom_drawer.dart
│   ├── glass_input_box.dart
│   └── typing_indicator.dart
├── main.dart
assets/
├── animations/
│   └── medical_splash.json
├── images/
│   └── logo.png
└── demo/
    └── demo.gif
```

---

## ⚙️ Dependencies (`pubspec.yaml`)
```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.2
  http: ^0.13.5
  provider: ^6.0.5
  shared_preferences: ^2.0.15
  lottie: ^2.2.0
  flutter_local_notifications: ^12.0.3
  intl: ^0.18.0
  flutter_svg: ^1.1.6

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_launcher_icons: ^0.9.2
  flutter_native_splash: ^2.2.10
```

---

## 🚀 Run Locally
Make sure you have **Flutter SDK** installed.

1. Clone repository
```bash
git clone https://github.com/tsshack/pezshkyar-app.git
cd pezshkyar
```
2. Install dependencies
```bash
flutter pub get
```
3. Run the app
```bash
flutter run
```

### Build Release (Android)
```bash
flutter build apk --release
```

### Build Release (iOS)
```bash
flutter build ipa
```
*(Requires Xcode & Apple Developer Account)*

---

## 🔐 API & Security
- Store **API keys & tokens** in **.env files** or **secure storage**.
- Never commit sensitive credentials to GitHub.

```dart
class ApiConfig {
  static const String BASE_URL = 'https://api.pezshkyar.com';
  // Use secure storage / remote config for tokens
}
```

---

## 💡 Example: Animated Chat Bubble
```dart
import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isMe;

  const ChatBubble({required this.text, this.isMe = false});

  @override
  Widget build(BuildContext context) {
    final radius = Radius.circular(16);
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.8, end: 1.0),
        duration: Duration(milliseconds: 350),
        builder: (context, value, child) {
          return Transform.scale(scale: value, child: child);
        },
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: isMe ? Theme.of(context).primaryColor : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: radius,
              topRight: radius,
              bottomLeft: isMe ? radius : Radius.circular(4),
              bottomRight: isMe ? Radius.circular(4) : radius,
            ),
            boxShadow: [
              BoxShadow(
                blurRadius: 6,
                color: Colors.black12,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            text,
            style: TextStyle(color: isMe ? Colors.white : Colors.black87),
            textDirection: TextDirection.rtl,
          ),
        ),
      ),
    );
  }
}
```

---

## 🛠️ Recommended Packages
- `flutter_native_splash` — native splash screen
- `flutter_launcher_icons` — app icons
- `cached_network_image` — optimized image loading
- `riverpod` or `provider` — state management
- `shimmer` — skeleton loaders

---

## 🧪 Testing
- ✅ Unit & widget tests (chat logic, local storage)
- ✅ API & network tests using mocks (e.g., Mockito)
- ✅ Integration tests for real device behavior

---

## 🤝 Contributing
1. Fork this repository
2. Create a feature branch: `git checkout -b feature/AmazingFeature`
3. Commit changes: `git commit -m "Add AmazingFeature"`
4. Push branch: `git push origin feature/AmazingFeature`
5. Open a Pull Request

> Please open an issue first to discuss your proposal.

---

## 📝 License
Licensed under the **MIT License** — see the [LICENSE](LICENSE) file.

---

## 👨‍💻 Developer
**Ehsan Fazli**  
🚀 Full-Stack & Mobile Developer | Flutter Enthusiast | API Designer

- 📧 Email: [ehsanehsanfazlinejad.com](mailto:ehsanehsanfazlinejad.com)  
- 🌐 Website: [ehsanjs.ir](https://ehsanjs.ir)  
- 💬 Telegram: [@Devehsan](https://t.me/Devehsan)  
- 🐙 GitHub: [tsshack](https://github.com/tsshack)  
- 🔗 LinkedIn: [linkedin.com/in/ehsanfazli](https://linkedin.com/in/ehsanfazli)

---

## ⚠️ Disclaimer
Pezshkyar provides **general medical information only**. It is **NOT a substitute** for professional medical advice, diagnosis, or treatment. Always consult a qualified physician.

---

## ✅ Release Checklist
- [ ] Add screenshots & demo GIF
- [ ] Configure splash screen & icons
- [ ] Test on multiple devices & screen sizes
- [ ] Verify permissions & app store policies
- [ ] Remove sensitive
