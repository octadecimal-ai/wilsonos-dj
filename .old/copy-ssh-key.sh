#!/bin/bash

# Skrypt do kopiowania klucza SSH na serwer wilsonos.com
# Dane połączenia są pobierane z pliku config.ini

set -e

# Ścieżka do katalogu skryptu
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/www/config.ini"

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

# Sprawdź czy klucz SSH istnieje
SSH_KEY="${HOME}/.ssh/id_rsa.pub"
if [ ! -f "${SSH_KEY}" ]; then
    echo "Błąd: Nie znaleziono klucza SSH w ${SSH_KEY}"
    echo "Wygeneruj klucz: ssh-keygen -t rsa -b 4096"
    exit 1
fi

# Sprawdź czy sshpass jest dostępny
if command -v sshpass &> /dev/null; then
    USE_SSHPASS=true
elif command -v expect &> /dev/null; then
    USE_SSHPASS=false
    USE_EXPECT=true
else
    echo "Błąd: Ani sshpass ani expect nie są zainstalowane."
    echo "Zainstaluj: brew install hudochenkov/sshpass/sshpass"
    echo "Lub: brew install expect"
    exit 1
fi

echo "=========================================="
echo "Kopiowanie klucza SSH na serwer wilsonos.com"
echo "=========================================="
echo "Host: ${SFTP_HOST}"
echo "Port: ${SFTP_PORT}"
echo "Login: ${SFTP_LOGIN}"
echo "Klucz: ${SSH_KEY}"
echo "=========================================="
echo ""

# Metoda 1: Użyj sshpass z ssh-copy-id
if [ "$USE_SSHPASS" = true ]; then
    echo "Używam sshpass do kopiowania klucza..."
    export SSHPASS="${SFTP_PASSWORD}"
    sshpass -e ssh-copy-id -p ${SFTP_PORT} -o StrictHostKeyChecking=no ${SFTP_LOGIN}@${SFTP_HOST}
    
    if [ $? -eq 0 ]; then
        echo "✓ Klucz SSH został dodany pomyślnie!"
    else
        echo "⚠ Próba kopiowania przez sshpass nie powiodła się, próbuję alternatywnej metody..."
        # Metoda alternatywna: ręczne kopiowanie przez sshpass
        SSH_KEY_CONTENT=$(cat "${SSH_KEY}")
        sshpass -e ssh -p ${SFTP_PORT} -o StrictHostKeyChecking=no ${SFTP_LOGIN}@${SFTP_HOST} \
            "mkdir -p ~/.ssh && chmod 700 ~/.ssh && echo '${SSH_KEY_CONTENT}' >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys" 2>/dev/null
        
        if [ $? -eq 0 ]; then
            echo "✓ Klucz SSH został dodany pomyślnie (metoda alternatywna)!"
        else
            echo ""
            echo "✗ Nie udało się skopiować klucza automatycznie."
            echo ""
            echo "Możliwe przyczyny:"
            echo "  1. Hasło w config.ini jest niepoprawne"
            echo "  2. Serwer wymaga innej metody autoryzacji"
            echo "  3. Port SSH może być inny"
            echo ""
            echo "Możesz skopiować klucz ręcznie używając:"
            echo "  ssh-copy-id -p ${SFTP_PORT} ${SFTP_LOGIN}@${SFTP_HOST}"
            echo ""
            echo "Lub ręcznie:"
            echo "  cat ~/.ssh/id_rsa.pub | ssh -p ${SFTP_PORT} ${SFTP_LOGIN}@${SFTP_HOST} 'mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 700 ~/.ssh && chmod 600 ~/.ssh/authorized_keys'"
            echo ""
            exit 1
        fi
    fi
# Metoda 2: Użyj expect
elif [ "$USE_EXPECT" = true ]; then
    echo "Używam expect do kopiowania klucza..."
    SSH_KEY_CONTENT=$(cat "${SSH_KEY}")
    
    expect << EOF
set timeout 30
spawn ssh -p ${SFTP_PORT} -o StrictHostKeyChecking=no ${SFTP_LOGIN}@${SFTP_HOST} "mkdir -p ~/.ssh && chmod 700 ~/.ssh && echo '${SSH_KEY_CONTENT}' >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys && echo 'SUCCESS'"
expect {
    -re "(password|Password):" {
        send "${SFTP_PASSWORD}\r"
        exp_continue
    }
    "SUCCESS" {
        puts "\n✓ Klucz SSH został dodany pomyślnie!"
        exit 0
    }
    timeout {
        puts "\n✗ Timeout podczas kopiowania klucza"
        exit 1
    }
    eof {
        puts "\n✓ Klucz SSH został dodany pomyślnie!"
        exit 0
    }
}
EOF
fi

# Sprawdź czy klucz został dodany (opcjonalne - test połączenia)
echo ""
echo "Testowanie połączenia bez hasła..."
if ssh -p ${SFTP_PORT} -o StrictHostKeyChecking=no -o ConnectTimeout=5 ${SFTP_LOGIN}@${SFTP_HOST} "echo 'Połączenie działa!'" 2>/dev/null; then
    echo "✓ Połączenie SSH bez hasła działa poprawnie!"
else
    echo "⚠ Połączenie bez hasła może wymagać dodatkowej konfiguracji"
fi

