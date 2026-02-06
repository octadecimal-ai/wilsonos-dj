#!/bin/bash

# Wilson DJ - Spotify Token Refresh Script
# Odświeża token Spotify poprzez wywołanie oauth_callback_simple.php
# Autor: Wilson DJ
# Data: 2025-09-09

echo "🎧 Wilson DJ - Odświeżanie tokena Spotify..."
echo "================================================"

# Sprawdź czy wget jest dostępny
if ! command -v wget &> /dev/null; then
    echo "❌ Błąd: wget nie jest zainstalowany!"
    echo "Zainstaluj wget: sudo apt-get install wget (Ubuntu/Debian) lub brew install wget (macOS)"
    exit 1
fi

# URL do odświeżenia tokena
REFRESH_URL="http://wilsonos.com/refresh_token.php"

echo "🔄 Odświeżam token Spotify..."
echo "URL: $REFRESH_URL"

# Wywołaj refresh_token.php
RESPONSE=$(wget -qO- "$REFRESH_URL" 2>&1)

# Sprawdź czy odpowiedź zawiera sukces
if echo "$RESPONSE" | grep -q "Token odświeżony pomyślnie\|✓ Token odświeżony\|Nowy token"; then
    echo "✅ Token został odświeżony pomyślnie!"
    echo "📄 Odpowiedź serwera:"
    echo "$RESPONSE"
else
    echo "❌ Błąd podczas odświeżania tokena!"
    echo "📄 Odpowiedź serwera:"
    echo "$RESPONSE"
    exit 1
fi

echo "================================================"
echo "🎧 Wilson DJ - Token odświeżony! Gotowy do pracy!"
