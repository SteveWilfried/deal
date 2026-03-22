# Connexion Backend Ndokoti — Guide

## Mode actuel : Démo (DummyJSON)

Par défaut, l'app tourne en mode démo avec DummyJSON.
Aucune configuration requise.

---

## Activer le backend réel

### 1. Démarrer l'API FastAPI localement

```bash
cd ndokoti-api
cp .env.example .env
# Remplir DATABASE_URL, SUPABASE_URL, SUPABASE_ANON_KEY...
pip install -r requirements.txt
uvicorn app.main:app --reload --port 8000
```

### 2. Lancer Flutter en mode réel

```bash
# Émulateur Android (l'IP 10.0.2.2 pointe vers localhost de la machine)
flutter run \
  --dart-define=USE_REAL_BACKEND=true \
  --dart-define=NDOKOTI_API_URL=http://10.0.2.2:8000

# Simulateur iOS
flutter run \
  --dart-define=USE_REAL_BACKEND=true \
  --dart-define=NDOKOTI_API_URL=http://localhost:8000

# Device physique (remplacer par l'IP de votre machine)
flutter run \
  --dart-define=USE_REAL_BACKEND=true \
  --dart-define=NDOKOTI_API_URL=http://192.168.1.X:8000
```

### 3. Production

```bash
flutter build apk \
  --dart-define=USE_REAL_BACKEND=true \
  --dart-define=NDOKOTI_API_URL=https://api.ndokoti.cm \
  --dart-define=SUPABASE_URL=https://XXX.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJ...
```

---

## Endpoints utilisés

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| GET | `/v1/deals` | Liste paginée avec filtres |
| GET | `/v1/deals/{id}` | Détail + incrément vues |
| POST | `/v1/deals` | Créer annonce (auth requis) |
| PUT | `/v1/deals/{id}` | Modifier annonce (auth requis) |
| DELETE | `/v1/deals/{id}` | Supprimer (soft delete) |
| GET | `/v1/deals/seller/{id}` | Annonces d'un vendeur |
| POST | `/v1/users/me` | Créer/récupérer profil |
| GET | `/v1/users/me` | Mon profil |
| PUT | `/v1/users/me` | Modifier profil |

## Authentification Supabase OTP

```dart
// Envoyer le code SMS
await AuthService.instance.sendOtp('+2379048785');

// Vérifier le code et créer la session
final user = await AuthService.instance.verifyOtp('+237655000001', '123456');

// Déconnexion
await AuthService.instance.signOut();
```

## Architecture des services

```
lib/core/
├── config/
│   └── app_config.dart      ← URLs, timeouts, flags
├── services/
│   ├── api_service.dart     ← Client HTTP + JWT
│   ├── auth_service.dart    ← Supabase OTP + profil
│   └── deal_service.dart    ← Deals (réel + démo)
```
