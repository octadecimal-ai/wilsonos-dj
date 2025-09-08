<?php
/**
 * WilsonOS Spotify Token Refresh
 * Odświeża token i aktualizuje config.ini
 * Created: 2025-09-08 18:52:16
 */

// Ładowanie konfiguracji
$config = parse_ini_file('config.ini');

echo "=== WilsonOS Spotify Token Refresh ===\n";
echo "Data: " . date('Y-m-d H:i:s') . "\n\n";

// Sprawdź czy mamy refresh token
$tokenFile = 'spotify_token.json';
if (file_exists($tokenFile)) {
    $tokenData = json_decode(file_get_contents($tokenFile), true);
    
    if ($tokenData && isset($tokenData['refresh_token'])) {
        echo "Znaleziono refresh token, odświeżam...\n";
        
        $data = http_build_query([
            'grant_type' => 'refresh_token',
            'refresh_token' => $tokenData['refresh_token']
        ]);
        
        $ch = curl_init();
        curl_setopt_array($ch, [
            CURLOPT_URL => 'https://accounts.spotify.com/api/token',
            CURLOPT_POST => true,
            CURLOPT_POSTFIELDS => $data,
            CURLOPT_HTTPHEADER => [
                'Authorization: Basic ' . base64_encode($config['SPOTIFY_CLIENT_ID'] . ':' . $config['SPOTIFY_CLIENT_SECRET']),
                'Content-Type: application/x-www-form-urlencoded'
            ],
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_TIMEOUT => 10
        ]);
        
        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);
        
        if ($httpCode === 200) {
            $newTokenData = json_decode($response, true);
            $newTokenData['created_at'] = time();
            
            // Zapisz nowy token
            file_put_contents($tokenFile, json_encode($newTokenData));
            
            // Aktualizuj config.ini
            $configContent = file_get_contents('config.ini');
            $configContent = preg_replace(
                '/ACCESS_TOKEN="[^"]*"/',
                'ACCESS_TOKEN="' . $newTokenData['access_token'] . '"',
                $configContent
            );
            file_put_contents('config.ini', $configContent);
            
            echo "✓ Token odświeżony pomyślnie!\n";
            echo "Nowy token: " . substr($newTokenData['access_token'], 0, 20) . "...\n";
            echo "Wygasa za: " . ($newTokenData['expires_in'] ?? 3600) . " sekund\n";
            
        } else {
            echo "✗ Błąd odświeżania tokena: " . $response . "\n";
        }
        
    } else {
        echo "Brak refresh tokena w pliku\n";
    }
    
} else {
    echo "Brak pliku z tokenem\n";
}

echo "\nAby uzyskać nowy token:\n";
echo "1. Odwiedź: http://wilsonos.com/oauth_callback_simple.php\n";
echo "2. Zaloguj się do Spotify i autoryzuj aplikację\n";
echo "3. Token zostanie zapisany automatycznie\n";
?>
