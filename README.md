# Nexa Stays Mobile

Flutter app for Nexa Stays — connects to **Nexa Identity** (auth + Sumsub KYC) and **Nexa Stays** (listings, bookings, payments).

## Prerequisites

1. **Stays database** (Docker):
   ```powershell
   cd database\stays
   .\migrate.ps1
   ```

2. **Identity backend** (local, port 3001):
   ```powershell
   copy backend\identity\.env.example backend\identity\.env
   cd backend\identity
   npm install
   npm run start:dev
   ```

3. **Stays backend** (local, port 3002):
   ```powershell
   copy backend\stays\.env.example backend\stays\.env
   cd backend\stays
   npm install
   npm run start:dev
   ```

## Sumsub KYC setup

Configure Sumsub in `backend/identity/.env`:

```env
SUMSUB_APP_TOKEN=your_app_token
SUMSUB_SECRET_KEY=your_secret_key
SUMSUB_WEBHOOK_SECRET=your_webhook_secret
SUMSUB_BASE_URL=https://api.sumsub.com
SUMSUB_LEVEL_NAME=basic-kyc-level
```

The mobile app uses the Identity API:

| Step | Endpoint |
|------|----------|
| Submit profile | `POST /kyc/submit` (`source: STAYS`) |
| Launch SDK | `POST /kyc/sumsub/token` |
| Sync result | `POST /kyc/sumsub/sync-status` |

Sumsub SDK: `flutter_idensic_mobile_sdk_plugin` (launched from registration flow after OTP/PIN).

For local dev without Sumsub credentials, KYC token requests will fail until keys are set.

## Run the app

**Android emulator** (default — `10.0.2.2` = host machine):

```powershell
cd nexastays-mobile
flutter pub get
flutter run
```

**Physical device** (phone and PC on the same Wi‑Fi):

1. Set your PC LAN IP in `assets/config/dev_api_host.txt` (currently `192.168.1.10`).
2. Stop the app and run a **full restart** (hot reload does not pick up env/bootstrap changes):

```powershell
cd nexastays-mobile
flutter pub get
flutter run
```

On startup you should see in the log: `Nexa API host: 192.168.1.10` and requests to `http://192.168.1.10:3001/...` (not `10.0.2.2`).

Optional override via dart-define file:

```powershell
.\scripts\run-device.ps1
```

Or manually:

```powershell
flutter run `
  --dart-define=IDENTITY_BASE_URL=http://192.168.1.10:3001/api/v1 `
  --dart-define=STAYS_BASE_URL=http://192.168.1.10:3002/api/v1
```

**Requirements for physical device:** Identity (3001) and Stays (3002) must be running on your PC; Windows Firewall must allow inbound on those ports; phone must be on the same network.

## Explore map

Maps use **OpenStreetMap** tiles via `flutter_map` (no API key). Host pin
placement geocodes through Nominatim. Listings need `geo_lat` / `geo_lng` to
appear on the Explore map.

## API routing

| Service | Port | Used for |
|---------|------|----------|
| Identity | 3001 | Auth, OTP, PIN, `/users/*`, `/kyc/*` (Sumsub) |
| Stays | 3002 | `/stays/*` listings, bookings, host, CMI/mock payments |

Both clients share the same JWT from Identity. Token refresh always hits Identity.

## Payments

- **Dev:** `STAYS_PAYMENT_PROVIDER=mock` in `backend/stays/.env` — app auto-completes mock payment after booking.
- **Prod:** CMI card gateway — app opens CMI redirect URL in browser.

Nexa Pay wallet is **not** used in Stays.

## Demo OTP

With `DEMO_OTP_CODE=123456` in Identity `.env`, use `123456` for any OTP in development.
