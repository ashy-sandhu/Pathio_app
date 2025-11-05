# Pathio

<div align="center">
  <img src="assets/logo/app_icon.png" alt="Pathio Logo" width="120" height="120"/>
  
  **Your Path, Perfected.**
  
  A modern travel guide app built with Flutter that helps you discover amazing places around the world and plan your perfect trips.
  
  [![Flutter](https://img.shields.io/badge/Flutter-3.9.2-blue.svg)](https://flutter.dev/)
  [![Dart](https://img.shields.io/badge/Dart-3.9.2-blue.svg)](https://dart.dev/)
  [![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
  
  [![GitHub](https://img.shields.io/badge/GitHub-Repository-black.svg)](https://github.com/ashy-sandhu/Pathio)
  [![Portfolio](https://img.shields.io/badge/Portfolio-ahsan--malik.netlify.app-orange.svg)](https://ahsan-malik.netlify.app)
</div>

---

## 📱 Screenshots

<div align="center">
  <table>
    <tr>
      <td align="center">
        <img src="screenshots/splash_screen.png" alt="Splash Screen" width="1080"/>
        <br/>
        <b>Splash Screen</b>
      </td>
      <td align="center">
        <img src="screenshots/home_screen.png" alt="Home Screen" width="1080"/>
        <br/>
        <b>Home Screen</b>
      </td>
      <td align="center">
        <img src="screenshots/search_screen.png" alt="Search Screen" width="1080"/>
        <br/>
        <b>Search & Discover</b>
      </td>
    </tr>
    <tr>
      <td align="center">
        <img src="screenshots/trips_screen.png" alt="Trips Screen" width="1080"/>
        <br/>
        <b>My Trips</b>
      </td>
      <td align="center">
        <img src="screenshots/place_details.png" alt="Place Details" width="1080"/>
        <br/>
        <b>Place Details</b>
      </td>
      <td align="center">
        <img src="screenshots/account_screen.png" alt="Account Screen" width="200"/>
        <br/>
        <b>Account & Settings</b>
      </td>
    </tr>
  </table>
</div>


---

## ✨ Features

### 🗺️ Core Features
- **Discover Places**: Browse popular destinations and nearby places
- **Interactive Maps**: View places on Google Maps with custom markers
- **Smart Search**: Search for places, cities, and countries
- **Trip Planning**: Create and manage your travel itineraries
- **Saved Places**: Save your favorite places for quick access
- **Reviews**: Share your experiences and read reviews from other travelers

### 🔐 Authentication
- **Email/Password**: Traditional signup and login with email verification
- **Google Sign-In**: Quick authentication with Google account
- **Facebook Sign-In**: Login with Facebook (optional)
- **Email Verification**: Secure email verification flow

### 👤 User Profile
- **Profile Management**: Update your profile information
- **Account Security**: Change password, manage account settings
- **Theme Support**: Light and dark mode support
- **Settings**: Customize app preferences

### 📍 Location Features
- **Current Location**: Detect and use your current location
- **Nearby Places**: Discover places near you with customizable radius
- **Location Permissions**: Smart permission handling

### 🎨 UI/UX
- **Modern Design**: Beautiful, intuitive user interface
- **Smooth Animations**: Lottie animations for enhanced experience
- **Responsive Layout**: Optimized for different screen sizes
- **State Persistence**: App state preserved when switching between apps

---

## 🛠️ Tech Stack

### Frontend
- **Flutter** - Cross-platform mobile framework
- **Dart** - Programming language
- **Provider** - State management solution
- **GoRouter** - Declarative routing for Flutter

### Backend
- **Django** - Python web framework
- **Django REST Framework** - RESTful API development
- **PostgreSQL** - Database (via Railway)
- **Railway** - Hosting platform

### Backend Services
- **Firebase** - Authentication, Firestore, Storage
- **Django REST API** - Custom backend API for places, cities, and countries data
  - API Base URL: `https://web-production-40bd5.up.railway.app`

### Key Packages
- `google_maps_flutter` - Google Maps integration
- `geolocator` - Location services
- `cached_network_image` - Image caching
- `lottie` - Animations
- `flutter_svg` - SVG support
- `shared_preferences` - Local storage
- `go_router` - Navigation
- `provider` - State management

---

## 📋 Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK** (3.9.2 or higher)
- **Dart SDK** (3.9.2 or higher)
- **Android Studio** or **VS Code** with Flutter extensions
- **Git**
- **Android SDK** (for Android development)
- **Firebase Account** (for authentication and database)
- **Google Cloud Platform Account** (for Maps API)

---

## 🚀 Installation

### 1. Clone the Repository

```bash
git clone https://github.com/ashy-sandhu/Pathio.git
cd pathio
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Firebase Setup

1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Add an Android app to your Firebase project
3. Download `google-services.json` from Firebase Console
4. Place it in `android/app/google-services.json`

### 4. Google Maps API Setup

1. Get a Google Maps API key from [Google Cloud Console](https://console.cloud.google.com/)
2. Create `android/local.properties` file:
   ```properties
   GOOGLE_MAPS_API_KEY=your_api_key_here
   ```
3. Enable the following APIs in Google Cloud Console:
   - Maps SDK for Android
   - Places API (if needed)

### 5. Backend API Configuration

The app connects to a Django REST API backend. The API is currently hosted on Railway:

- **Production API**: `https://web-production-40bd5.up.railway.app`

If you want to use a different API endpoint, update `lib/core/constants/api_endpoints.dart`:

```dart
static const String baseUrl = 'your_api_url_here';
```

> **Note**: Make sure the backend API is running and accessible before running the app. The API handles all places, cities, and countries data.

### 6. Configure App Icon

Generate app icons using:
```bash
flutter pub run flutter_launcher_icons
```

---

## 🏃 Running the App

### Prerequisites

1. **Backend API**: Ensure the Django backend API is running and accessible
   - API URL: `https://web-production-40bd5.up.railway.app`
   - Or run locally if you have the API repository

2. **Firebase**: Configure Firebase as mentioned in the installation steps

3. **Google Maps**: Set up Google Maps API key

### Development Mode

```bash
flutter run
```

### Release Build

```bash
flutter build apk --release
```

### Build for Specific Device

```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d <device_id>
```

---

## 📁 Project Structure

```
lib/
├── core/
│   ├── constants/       # App constants and endpoints
│   ├── router/           # Navigation routes
│   └── theme/           # App theme and colors
├── data/
│   ├── models/          # Data models
│   ├── repositories/    # Data repositories
│   └── services/        # API services
├── state/
│   └── providers/       # State providers
├── view/
│   ├── components/      # Reusable UI components
│   └── screens/         # App screens
└── services/            # App services (auth, etc.)
```

---

## 🔧 Configuration

### Environment Variables

Create `android/local.properties`:
```properties
GOOGLE_MAPS_API_KEY=your_google_maps_api_key
```

### Firebase Configuration

Ensure `android/app/google-services.json` is present (not committed to git).

### API Endpoints

Backend API endpoints are configured in `lib/core/constants/api_endpoints.dart`.

**API Base URL:** `https://web-production-40bd5.up.railway.app`

**Available Endpoints:**
- `/api/places/` - Get all places
- `/api/popular/` - Get popular places
- `/api/nearby/` - Get nearby places (requires lat, lon, radius)
- `/api/search/` - Search places (requires query)
- `/api/cities/` - Get all cities
- `/api/countries/` - Get all countries
- `/health/` - Health check endpoint

> **Note:** The backend API is built with Django and hosted on Railway at `https://web-production-40bd5.up.railway.app`.

---

## 📱 Features Breakdown

### Home Screen
- Display popular places
- Show nearby places based on current location
- Quick access to saved places
- Interactive map view

### Search Screen
- Search places by name, category, or location
- Filter results by various criteria
- View place details

### Trips Screen
- Create new trips
- Manage existing trips
- Add places to trip itineraries
- View trip details and timeline

### Account Screen
- View and edit profile
- Manage account settings
- Access help & support
- Privacy policy and terms

---

## 🔒 Security

This project follows security best practices:

- ✅ API keys stored securely (not in source code)
- ✅ Firebase configuration excluded from git
- ✅ Secure authentication flows
- ✅ Email verification required

See [SECURITY_GUIDE.md](SECURITY_GUIDE.md) for more details.

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Development Guidelines

- Follow Flutter/Dart style guidelines
- Write meaningful commit messages
- Add comments for complex logic
- Test your changes before submitting

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🔗 Backend API

This app uses a **Django REST API** backend for fetching places, cities, and countries data.

- **API Base URL**: `https://web-production-40bd5.up.railway.app`
- **Built with**: Django and Django REST Framework
- **Hosted on**: Railway
- **Provides**: RESTful endpoints for places, cities, and countries data

## 👨‍💻 Author

**Ahsan Malik**

- Portfolio: [ahsan-malik.netlify.app](https://ahsan-malik.netlify.app)
- GitHub: [@ashy-sandhu](https://github.com/ashy-sandhu)
- Email: ahsan.build@gmail.com

---

## 🙏 Acknowledgments

- **Flutter Team** - For the amazing framework
- **Django Team** - For the robust web framework
- **Firebase** - For authentication and backend services
- **Google Maps** - For mapping services
- **Railway** - For hosting the backend API
- **LottieFiles** - For animations

---

## 📞 Support & Contact

For support, email **ahsan.build@gmail.com** or open an issue in the repository.

**Links:**
- 🌐 **Portfolio**: [ahsan-malik.netlify.app](https://ahsan-malik.netlify.app)
- 💻 **GitHub**: [@ashy-sandhu](https://github.com/ashy-sandhu)
- 📧 **Email**: ahsan.build@gmail.com

---

## 🗺️ Roadmap

- [ ] iOS support
- [ ] Offline mode
- [ ] Social sharing
- [ ] Trip collaboration
- [ ] Advanced filters
- [ ] Push notifications
- [ ] In-app reviews
- [ ] Multi-language support

---

<div align="center">
  Made with ❤️ using Flutter
  
  **Pathio - Your Path, Perfected.**
</div>
