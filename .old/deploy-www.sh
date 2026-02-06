#!/bin/bash

# Skrypt do kopiowania katalogu www na serwer wilsonos.com przez SFTP
# Dane połączenia są pobierane z pliku config.ini

set -e  # Zatrzymaj wykonanie przy błędzie

# Ścieżka do katalogu skryptu
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/www/config.ini"
WWW_DIR="${SCRIPT_DIR}/www"  # Lokalny katalog źródłowy
REMOTE_DIR="www"  # Zdalny katalog docelowy (relatywnie do katalogu domowego użytkownika)

# Funkcja do czytania wartości z config.ini
read_config() {
    local key=$1
    grep "^${key}=" "${CONFIG_FILE}" | cut -d'=' -f2 | tr -d '"'
}

# Sprawdź czy plik config.ini istnieje
if [ ! -f "${CONFIG_FILE}" ]; then
    echo "Błąd: Nie znaleziono pliku config.ini w ${CONFIG_FILE}"
    exit 1
fi

# Sprawdź czy katalog www istnieje
if [ ! -d "${WWW_DIR}" ]; then
    echo "Błąd: Nie znaleziono katalogu www w ${WWW_DIR}"
    exit 1
fi

# Pobierz dane z config.ini
SFTP_HOST_PORT=$(read_config "WILSONOS_SFTP")
SFTP_LOGIN=$(read_config "WILSONOS_LOGIN")
SFTP_PASSWORD=$(read_config "WILSONOS_PASSWORD")

# Wyodrębnij host i port
SFTP_HOST=$(echo "${SFTP_HOST_PORT}" | cut -d':' -f1)
SFTP_PORT=$(echo "${SFTP_HOST_PORT}" | cut -d':' -f2)

if [ -z "${SFTP_HOST}" ] || [ -z "${SFTP_PORT}" ] || [ -z "${SFTP_LOGIN}" ] || [ -z "${SFTP_PASSWORD}" ]; then
    echo "Błąd: Nie udało się odczytać wszystkich wymaganych danych z config.ini"
    exit 1
fi

echo "=========================================="
echo "Deploy katalogu www na serwer wilsonos.com"
echo "=========================================="
echo "Kierunek: LOKALNY www → ZDALNY www"
echo "Host: ${SFTP_HOST}"
echo "Port: ${SFTP_PORT}"
echo "Login: ${SFTP_LOGIN}"
echo "Katalog źródłowy (lokalny): ${WWW_DIR}"
echo "Katalog docelowy (zdalny): ~/${REMOTE_DIR}"
echo "=========================================="
echo ""

# Sprawdź czy rsync jest dostępny
if ! command -v rsync &> /dev/null; then
    echo "Błąd: rsync nie jest zainstalowany. Zainstaluj: brew install rsync"
    exit 1
fi

# Sprawdź czy sshpass jest dostępny (dla automatycznego podawania hasła)
if command -v sshpass &> /dev/null; then
    echo "Używam sshpass do uwierzytelniania..."
    export SSHPASS="${SFTP_PASSWORD}"
    RSYNC_RSH="sshpass -e ssh -p ${SFTP_PORT} -o StrictHostKeyChecking=no"
else
    echo "Uwaga: sshpass nie jest zainstalowany."
    echo "Zainstaluj: brew install hudochenkov/sshpass/sshpass"
    echo "Lub użyj kluczy SSH dla automatycznego uwierzytelniania."
    echo ""
    echo "Kopiowanie przez rsync (będzie wymagane ręczne podanie hasła)..."
    RSYNC_RSH="ssh -p ${SFTP_PORT} -o StrictHostKeyChecking=no"
fi

# Wykonaj synchronizację przez rsync
# Kopiowanie: lokalny katalog www → zdalny katalog www
echo "Rozpoczynam kopiowanie z lokalnego www do zdalnego www..."
rsync -avz --progress \
    -e "${RSYNC_RSH}" \
    --exclude='.DS_Store' \
    --exclude='*.log' \
    --exclude='.git' \
    --exclude='.gitignore' \
    "${WWW_DIR}/" \
    "${SFTP_LOGIN}@${SFTP_HOST}:${REMOTE_DIR}/"

if [ $? -eq 0 ]; then
    echo ""
    echo "=========================================="
    echo "✓ Kopiowanie zakończone pomyślnie!"
    echo "=========================================="
else
    echo ""
    echo "=========================================="
    echo "✗ Wystąpił błąd podczas kopiowania"
    echo "=========================================="
    exit 1
fi

