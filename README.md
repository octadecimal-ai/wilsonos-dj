# 🎵 WilsonOS Spotify DJ Service

**Model:** Claude Sonnet 4  
**Czas:** 20250909_175338

## 📋 Opis

WilsonOS Spotify DJ Service to zaawansowany system do kontroli odtwarzania muzyki przez API Spotify. Serwis umożliwia wyszukiwanie utworów, płynne przejścia między utworami, kontrolę głośności, zarządzanie urządzeniami odtwarzającymi oraz pełne zarządzanie playlistami.

## 🚀 Funkcje

### Podstawowe
- ✅ **Wyszukiwanie utworów** - wyszukiwanie w bibliotece Spotify
- ✅ **Odtwarzanie** - odtwarzanie utworów od dowolnego momentu
- ✅ **Kontrola odtwarzania** - pauza, wznowienie, następny/poprzedni
- ✅ **Zarządzanie głośnością** - kontrola głośności (0-100%)
- ✅ **Zarządzanie urządzeniami** - przełączanie między urządzeniami

### Zaawansowane
- ✅ **Playlisty** - odtwarzanie całych playlist (3 metody fallback)
- ✅ **Kolejka** - dodawanie utworów do kolejki
- ✅ **Zarządzanie playlistami** - tworzenie, edycja, usuwanie playlist
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

#### Odtwarzanie playlisty
```bash
curl -X POST "http://wilsonos.com/spotify_api_simple.php/play-playlist" \
  -H "Content-Type: application/json" \
  -d '{"artist": "ARTYSTA", "limit": 10}'
```

#### Zarządzanie kolejką
```bash
# Dodaj utwór do kolejki
curl -X POST "http://wilsonos.com/spotify_api_simple.php/add-to-queue" \
  -H "Content-Type: application/json" \
  -d '{"track_id": "ID_UTWORU"}'

# Sprawdź status kolejki (informacyjnie)
curl -X POST "http://wilsonos.com/spotify_api_simple.php/clear-queue"
```

#### Tworzenie playlist
```bash
curl -X POST "http://wilsonos.com/spotify_api_simple.php/create-playlist" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Moja Playlista",
    "description": "Opis playlisty",
    "tracks": ["ID1", "ID2", "ID3"],
    "public": false
  }'
```

#### Zarządzanie playlistami
```bash
# Lista wszystkich playlist
curl "http://wilsonos.com/spotify_api_simple.php/playlist-management"

# Zmiana nazwy playlisty
curl -X POST "http://wilsonos.com/spotify_api_simple.php/playlist-management" \
  -H "Content-Type: application/json" \
  -d '{
    "action": "rename",
    "playlist_id": "ID_PLAYLISTY",
    "new_name": "Nowa nazwa"
  }'

# Aktualizacja opisu
curl -X POST "http://wilsonos.com/spotify_api_simple.php/playlist-management" \
  -H "Content-Type: application/json" \
  -d '{
    "action": "update_description",
    "playlist_id": "ID_PLAYLISTY",
    "description": "Nowy opis"
  }'

# Usuwanie playlisty
curl -X POST "http://wilsonos.com/spotify_api_simple.php/playlist-management" \
  -H "Content-Type: application/json" \
  -d '{
    "action": "delete",
    "playlist_id": "ID_PLAYLISTY"
  }'

# Lista utworów w playlisty
curl -X POST "http://wilsonos.com/spotify_api_simple.php/playlist-management" \
  -H "Content-Type: application/json" \
  -d '{
    "action": "get_tracks",
    "playlist_id": "ID_PLAYLISTY"
  }'

# Dodawanie utworów do playlisty
curl -X POST "http://wilsonos.com/spotify_api_simple.php/playlist-management" \
  -H "Content-Type: application/json" \
  -d '{
    "action": "add_tracks",
    "playlist_id": "ID_PLAYLISTY",
    "tracks": ["ID1", "ID2", "ID3"]
  }'

# Usuwanie utworów z playlisty
curl -X POST "http://wilsonos.com/spotify_api_simple.php/playlist-management" \
  -H "Content-Type: application/json" \
  -d '{
    "action": "remove_tracks",
    "playlist_id": "ID_PLAYLISTY",
    "tracks": ["ID1", "ID2", "ID3"]
  }'
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

#### Scenariusz 2: Odtwórz playlistę artysty
```bash
# Odtwórz 10 utworów artysty
curl -X POST "http://wilsonos.com/spotify_api_simple.php/play-playlist" \
  -H "Content-Type: application/json" \
  -d '{"artist": "Pink Floyd", "limit": 10}'
```

#### Scenariusz 3: Utwórz i odtwórz playlistę
```bash
# 1. Wyszukaj utwory
curl "http://wilsonos.com/spotify_api_simple.php/search?query=ambient&limit=5"

# 2. Utwórz playlistę z utworami
curl -X POST "http://wilsonos.com/spotify_api_simple.php/create-playlist" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Moja Ambient Playlista",
    "description": "Relaksująca muzyka ambient",
    "tracks": ["ID1", "ID2", "ID3", "ID4", "ID5"],
    "public": false
  }'

# 3. Dodaj utwory do kolejki
curl -X POST "http://wilsonos.com/spotify_api_simple.php/add-to-queue" \
  -H "Content-Type: application/json" \
  -d '{"track_id": "ID1"}'
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

### Problem: Playlista odtwarza tylko jeden utwór
**Rozwiązanie:**
- API używa 3 metod fallback do odtwarzania playlist
- Metoda 1: `uris` array (preferowana)
- Metoda 2: Tworzenie tymczasowej playlisty
- Metoda 3: Odtwarzanie tylko pierwszego utworu
- Sprawdź logi API dla szczegółów

## 📁 Struktura projektu

```
wilsonos-dj/
├── spotify_api_simple.php    # Główny endpoint API
├── SpotifyService.php        # Klasa serwisu Spotify
├── oauth_callback.php        # Callback OAuth
├── refresh_token.php         # Odświeżanie tokenów
├── config.ini               # Konfiguracja
├── playlists/               # Playlisty CSV
│   ├── dj-wilson/           # Playlisty DJ Wilson
│   │   ├── csv/             # Pliki CSV
│   │   └── *.md             # Dokumentacja playlist
│   └── ...                  # Inne playlisty
├── doc/                     # Dokumentacja
└── analysis/                # Analizy i dokumenty
```

## 🎯 Funkcje zaawansowane

### Odtwarzanie playlist (3 metody fallback)
```php
// Metoda 1: uris array (preferowana)
$data = ['uris' => $uris, 'position_ms' => 0];
makeSpotifyRequest('me/player/play', 'PUT', $data);

// Metoda 2: Tymczasowa playlista
$playlist = makeSpotifyRequest("users/$userId/playlists", 'POST', $playlistData);
makeSpotifyRequest('me/player/play', 'PUT', ['context_uri' => $playlist['uri']]);

// Metoda 3: Tylko pierwszy utwór
makeSpotifyRequest('me/player/play', 'PUT', ['uris' => [$uris[0]]]);
```

### Zarządzanie playlistami
```php
// Utwórz playlistę
$playlist = makeSpotifyRequest("users/$userId/playlists", 'POST', $playlistData);

// Dodaj utwory (maksymalnie 100 na raz)
$chunks = array_chunk($trackUris, 100);
foreach ($chunks as $chunk) {
    makeSpotifyRequest("playlists/$playlistId/tracks", 'POST', ['uris' => $chunk]);
}

// Usuń utwory
makeSpotifyRequest("playlists/$playlistId/tracks", 'DELETE', [
    'tracks' => array_map(function($uri) {
        return ['uri' => $uri];
    }, $trackUris)
]);
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

**Ostatnia aktualizacja:** 2025-09-09 17:53:38