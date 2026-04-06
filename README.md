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

| Variable             | Description                          |
|----------------------|--------------------------------------|
| `MONGODB_URI`        | MongoDB connection string            |
| `JWT_SECRET`         | Secret key for JWT tokens            |
| `WHATSAPP_ENABLED`   | Enable/disable WhatsApp (`true/false`) |
| `WHATSAPP_NOTIFY_TO` | Admin phone number for notifications |
| `PUBLIC_BASE_URL`    | Public URL of the backend            |

### Flutter App Setup

```bash
flutter pub get
flutter run
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
3. Set `MONGODB_URI` and `PUBLIC_BASE_URL` in the Render dashboard
4. WhatsApp is disabled on Render (requires persistent browser session)

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
