#!/bin/bash

# Wilson DJ - Spotify Reauthorization Script
# Wymusza ponowną autoryzację i uzyskanie refresh token
# Autor: Wilson DJ
# Data: 2025-09-09

echo "🎧 Wilson DJ - Ponowna autoryzacja Spotify..."
echo "================================================"

# Sprawdź czy wget jest dostępny
if ! command -v wget &> /dev/null; then
    echo "❌ Błąd: wget nie jest zainstalowany!"
    echo "Zainstaluj wget: sudo apt-get install wget (Ubuntu/Debian) lub brew install wget (macOS)"
    exit 1
fi

# URL do autoryzacji
AUTH_URL="http://wilsonos.com/oauth_callback.php"

echo "🔄 Rozpoczynam ponowną autoryzację..."
echo "URL: $AUTH_URL"
echo ""
echo "📋 INSTRUKCJE:"
echo "1. Otwórz przeglądarkę i przejdź do: $AUTH_URL"
echo "2. Zaloguj się do Spotify"
echo "3. Autoryzuj aplikację (zaznacz wszystkie uprawnienia)"
echo "4. Zostaniesz przekierowany z komunikatem o sukcesie"
echo "5. Po autoryzacji uruchom: ./refresh_token.sh"
echo ""
echo "⚠️  WAŻNE: Ta autoryzacja wymusi uzyskanie refresh token!"
echo "   Refresh token pozwoli na automatyczne odświeżanie access token"
echo "   bez konieczności ponownego logowania przez użytkownika."
echo ""

# Otwórz przeglądarkę (jeśli jest dostępna)
if command -v open &> /dev/null; then
    echo "🌐 Otwieram przeglądarkę..."
    open "$AUTH_URL"
elif command -v xdg-open &> /dev/null; then
    echo "🌐 Otwieram przeglądarkę..."
    xdg-open "$AUTH_URL"
else
    echo "🌐 Skopiuj i wklej ten URL do przeglądarki:"
    echo "$AUTH_URL"
fi

echo ""
echo "================================================"
echo "🎧 Wilson DJ - Czekam na autoryzację..."
echo "Po autoryzacji uruchom: ./refresh_token.sh"
