# 🎵 WilsonOS Spotify DJ Service

**Model:** Claude Sonnet 4  
**Czas:** 20250908_204435

## 📋 Opis

WilsonOS Spotify DJ Service to zaawansowany system do kontroli odtwarzania muzyki przez API Spotify. Serwis umożliwia wyszukiwanie utworów, płynne przejścia między utworami, kontrolę głośności oraz zarządzanie urządzeniami odtwarzającymi.

## 🚀 Funkcje

### Podstawowe
- ✅ **Wyszukiwanie utworów** - wyszukiwanie w bibliotece Spotify
- ✅ **Odtwarzanie** - odtwarzanie utworów od dowolnego momentu
- ✅ **Kontrola odtwarzania** - pauza, wznowienie, następny/poprzedni
- ✅ **Zarządzanie głośnością** - kontrola głośności (0-100%)
- ✅ **Zarządzanie urządzeniami** - przełączanie między urządzeniami

### Zaawansowane
- ✅ **Płynne przejścia** - fade in/out między utworami
- ✅ **Automatyczne odświeżanie tokenów** - bez przerywania sesji
- ✅ **Obsługa błędów** - szczegółowe komunikaty błędów
- ✅ **Logowanie** - śledzenie wywołań API

## 🛠️ Instalacja

### Wymagania
- PHP 7.4+
- cURL
- Konto Spotify Premium
- Aplikacja Spotify zarejestrowana w Spotify Developer Dashboard

### Konfiguracja

1. **Skonfiguruj aplikację Spotify:**
   - Zarejestruj aplikację w [Spotify Developer Dashboard](https://developer.spotify.com/dashboard)
   - Ustaw redirect URI: `https://wilsonos.com/oauth_callback.php`

2. **Skonfiguruj plik `config.ini`:**
   ```ini
   SPOTIFY_CLIENT_ID="twoj_client_id"
   SPOTIFY_CLIENT_SECRET="twoj_client_secret"
   REDIRECT_URI="https://wilsonos.com/oauth_callback.php"
   ACCESS_TOKEN="token_zostanie_ustawiony_automatycznie"
   ```

3. **Autoryzacja (jednorazowo):**
   ```
   http://wilsonos.com/oauth_callback.php
   ```

## 📖 Użycie

### API Endpoints

#### Wyszukiwanie utworów
```bash
curl "http://wilsonos.com/spotify_api_simple.php/search?query=ARTYSTA%20UTWOR&limit=5"
```

#### Odtwarzanie utworu
```bash
curl -X POST "http://wilsonos.com/spotify_api_simple.php/play" \
  -H "Content-Type: application/json" \
  -d '{"track_id": "ID_UTWORU"}'
```

#### Odtwarzanie od konkretnego momentu
```bash
curl -X POST "http://wilsonos.com/spotify_api_simple.php/play" \
  -H "Content-Type: application/json" \
  -d '{"track_id": "ID_UTWORU", "position_ms": 128000}'
```

#### Kontrola odtwarzania
```bash
# Pauza
curl -X POST "http://wilsonos.com/spotify_api_simple.php/pause"

# Wznowienie
curl -X POST "http://wilsonos.com/spotify_api_simple.php/resume"

# Następny utwór
curl -X POST "http://wilsonos.com/spotify_api_simple.php/next"

# Poprzedni utwór
curl -X POST "http://wilsonos.com/spotify_api_simple.php/previous"
```

#### Zarządzanie głośnością
```bash
curl -X POST "http://wilsonos.com/spotify_api_simple.php/volume" \
  -H "Content-Type: application/json" \
  -d '{"volume": 75}'
```

#### Lista urządzeń
```bash
curl "http://wilsonos.com/spotify_api_simple.php/devices"
```

#### Status serwisu
```bash
curl "http://wilsonos.com/spotify_api_simple.php/status"
```

### Przykłady użycia

#### Scenariusz 1: Wyszukaj i odtwórz utwór
```bash
# 1. Wyszukaj utwór
curl "http://wilsonos.com/spotify_api_simple.php/search?query=bohemian%20rhapsody&limit=1"

# 2. Skopiuj track_id z odpowiedzi i odtwórz
curl -X POST "http://wilsonos.com/spotify_api_simple.php/play" \
  -H "Content-Type: application/json" \
  -d '{"track_id": "SKOPIOWANY_ID"}'
```

#### Scenariusz 2: Płynne przejście między utworami
```bash
# 1. Odtwórz pierwszy utwór
curl -X POST "http://wilsonos.com/spotify_api_simple.php/play" \
  -H "Content-Type: application/json" \
  -d '{"track_id": "ID_UTWORU_1"}'

# 2. Po chwili odtwórz drugi utwór (automatycznie wyciszy pierwszy)
curl -X POST "http://wilsonos.com/spotify_api_simple.php/play" \
  -H "Content-Type: application/json" \
  -d '{"track_id": "ID_UTWORU_2"}'
```

## 🔧 Rozwiązywanie problemów

### Problem: "No active device found"
**Rozwiązanie:**
1. Otwórz aplikację Spotify na komputerze/telefonie
2. Zaloguj się do tego samego konta co autoryzowałeś
3. Spróbuj odtworzyć dowolny utwór w aplikacji
4. Sprawdź urządzenia: `curl "http://wilsonos.com/spotify_api_simple.php/devices"`

### Problem: "Invalid access token"
**Rozwiązanie:**
1. Odwiedź ponownie: `http://wilsonos.com/oauth_callback.php`
2. Zaloguj się i autoryzuj ponownie
3. Token zostanie automatycznie odświeżony

### Problem: "Brak tokena dostępu"
**Rozwiązanie:**
1. Wykonaj autoryzację OAuth (patrz sekcja "Instalacja")
2. Upewnij się, że jesteś zalogowany do Spotify

## 📁 Struktura projektu

```
wilsonos-dj/
├── spotify_api_simple.php    # Główny endpoint API
├── SpotifyService.php        # Klasa serwisu Spotify
├── oauth_callback.php        # Callback OAuth
├── refresh_token.php         # Odświeżanie tokenów
├── config.ini               # Konfiguracja
├── playlists/               # Playlisty CSV
├── doc/                     # Dokumentacja
└── analysis/                # Analizy i dokumenty
```

## 🎯 Funkcje zaawansowane

### Płynne przejścia (SpotifyService.php)
```php
$spotify = new SpotifyService();

// Płynne przejście między utworami
$spotify->smoothTransition($newTrackId, $positionMs, $fadeDurationMs);

// Fade out aktualnego utworu
$spotify->fadeOutCurrentTrack($durationMs);

// Fade in nowego utworu
$spotify->fadeInTrack($trackId, $positionMs, $durationMs);
```

### Zarządzanie urządzeniami
```php
// Pobierz dostępne urządzenia
$devices = $spotify->getAvailableDevices();

// Ustaw aktywne urządzenie
$spotify->setActiveDevice($deviceId);
```

## 📊 Status serwisu

Sprawdź status serwisu:
```bash
curl "http://wilsonos.com/spotify_api_simple.php/status"
```

Odpowiedź zawiera:
- Status tokena dostępu
- Aktualny stan odtwarzania
- Liczbę dostępnych urządzeń
- Timestamp

## 🔐 Bezpieczeństwo

- Tokeny dostępu są automatycznie odświeżane
- Wszystkie zapytania używają HTTPS
- CORS jest skonfigurowany dla cross-origin requests
- Szczegółowe logowanie błędów

## 📝 Licencja

Projekt WilsonOS Spotify DJ Service - prywatny projekt.

## 🎵 Miłego słuchania!

Serwis jest w pełni funkcjonalny i gotowy do użycia. Wszystkie podstawowe i zaawansowane funkcje działają poprawnie.

---

**Ostatnia aktualizacja:** 2025-09-08 20:44:35
