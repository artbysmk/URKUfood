# 🍔 La Carta

**La Carta** is a food delivery mobile application built with Flutter and a NestJS backend. It allows users to browse restaurant catalogs, place orders, and track their status in real time through WhatsApp integration.

---

## Features

- **Restaurant Catalog** — Browse multiple restaurants with categories and dishes
- **Shopping Cart** — Add items, adjust quantities, and confirm orders
- **Order Tracking** — Real-time order status sync from backend
- **WhatsApp Integration** — Admin receives orders via WhatsApp with interactive polls to update status (Preparing → Shipped → Delivered)
- **JWT Authentication** — Secure login and registration with token-based auth
- **Session Persistence** — User session survives app restarts
- **Catalog Seeding** — Backend auto-seeds restaurants and dishes on startup

---

## Tech Stack

| Layer        | Technology                          |
|--------------|-------------------------------------|
| Mobile App   | Flutter (Dart SDK ^3.9.0)           |
| Backend API  | NestJS (Node.js 20)                |
| Database     | MongoDB (Mongoose v9)               |
| Auth         | JWT (passport-jwt)                  |
| WhatsApp     | whatsapp-web.js v1.34.6 (Polls)     |
| Hosting      | Render (backend) + MongoDB Atlas    |

---

## Project Structure

```
La Carta/
├── lib/                        # Flutter app source
│   ├── app/
│   │   ├── app.dart            # Main UI
│   │   ├── app_controller.dart # State management
│   │   └── backend_bridge.dart # HTTP client to backend
│   └── main.dart
├── backend/                    # NestJS API
│   └── src/
│       ├── auth/               # JWT authentication
│       ├── orders/             # Order management
│       ├── automation/         # WhatsApp integration
│       ├── seed/               # Catalog seeder
│       └── main.ts            # App bootstrap
├── android/                    # Android platform config
├── images/                     # Restaurant images
├── render.yaml                 # Render deployment blueprint
└── index.html                  # Web entry point
```

---

## Getting Started

### Prerequisites

- Flutter SDK ^3.9.0
- Node.js 20+
- MongoDB (local or Atlas)

### Backend Setup

```bash
cd backend
cp .env.example .env        # Configure your environment variables
npm install
npm run start:dev
```

**Environment Variables:**

| Variable                         | Description |
|----------------------------------|-------------|
| `MONGODB_URI`                    | MongoDB connection string |
| `JWT_SECRET`                     | Secret key for JWT tokens |
| `PUBLIC_BASE_URL`                | Public URL of the backend |
| `GOOGLE_CLIENT_ID`               | Google OAuth client ID used by backend token validation |
| `SMTP_HOST`, `SMTP_PORT`         | SMTP server for email verification |
| `SMTP_USER`, `SMTP_PASS`         | SMTP credentials |
| `SMTP_FROM`                      | Sender shown in verification emails |
| `SMTP_TLS_REJECT_UNAUTHORIZED`   | Optional TLS override for SMTP providers |
| `FCM_PROJECT_ID`                 | Firebase project ID for push sending |
| `FCM_CLIENT_EMAIL`               | Firebase service account client email |
| `FCM_PRIVATE_KEY`                | Firebase service account private key |
| `WHATSAPP_ENABLED`               | Enable or disable WhatsApp automation |
| `WHATSAPP_ALLOW_RENDER`          | Allow whatsapp-web.js on Render if Chromium is available |
| `WHATSAPP_NOTIFY_TO`             | Admin phone number for notifications |
| `WHATSAPP_CHROME_PATH`           | Optional Chromium path for whatsapp-web.js |

### Flutter App Setup

```bash
flutter pub get
flutter run --dart-define=API_BASE_URL=http://localhost:3000
```

### Build APK for Production

```bash
flutter build apk --release --dart-define=API_BASE_URL=https://your-backend.onrender.com
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

---

## Deployment

### Backend (Render)

1. Connect your GitHub repo to [Render](https://render.com)
2. Use the included `render.yaml` blueprint
3. Set `MONGODB_URI`, `PUBLIC_BASE_URL`, `GOOGLE_CLIENT_ID`, SMTP variables and FCM variables in the Render dashboard
4. Keep `WHATSAPP_ENABLED=false` unless you also provide a valid Chromium path and explicitly enable `WHATSAPP_ALLOW_RENDER=true`
5. After Render assigns the backend URL, build the APK with that same value in `API_BASE_URL`

### Android Release Build

```bash
flutter build apk --release --dart-define=API_BASE_URL=https://urkufood-api.onrender.com
```

### Connected Services Checklist

1. Backend on Render with a valid `PUBLIC_BASE_URL`
2. MongoDB Atlas reachable from Render
3. Firebase Android config in `android/app/google-services.json`
4. FCM service account vars configured in Render
5. Google Sign-In backend client ID configured in Render
6. APK built with the same backend URL passed through `API_BASE_URL`

### Database (MongoDB Atlas)

1. Create a free cluster on [MongoDB Atlas](https://cloud.mongodb.com)
2. Create a database user and whitelist IPs
3. Copy the connection string to `MONGODB_URI`

---

## API Endpoints

| Method | Endpoint         | Description        | Auth |
|--------|------------------|--------------------|------|
| POST   | `/auth/register` | Register new user  | No   |
| POST   | `/auth/login`    | Login              | No   |
| POST   | `/orders`        | Create order       | JWT  |
| GET    | `/orders/my`     | Get user's orders  | JWT  |
| GET    | `/docs`          | Swagger API docs   | No   |

---

## Authors

- **ChrisSantacruz** — [GitHub](https://github.com/ChrispinSantacruz)
- **ArtBySMK** — [GitHub](https://github.com/artbysmk)

---

## License

This project is for educational and personal use.
