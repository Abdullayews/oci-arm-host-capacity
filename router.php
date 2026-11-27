<?php
/**
 * Router for PHP built-in web server (php -S).
 *
 * Render (and humans) hit /health for liveness; every other path gets a
 * simple status page. The OCI check loop itself lives in entrypoint.sh.
 */

declare(strict_types=1);

$uri = $_SERVER['REQUEST_URI'] ?? '/';
$path = parse_url($uri, PHP_URL_PATH) ?: '/';

if ($path === '/health') {
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode([
        'status' => 'ok',
        'service' => 'oci-arm-host-capacity',
        'php' => PHP_VERSION,
        'time' => gmdate('c'),
    ]);
    return true;
}

header('Content-Type: text/html; charset=utf-8');
?>
<!DOCTYPE html>
<html lang="en">
<head><meta charset="utf-8"><title>OCI ARM Host Capacity</title></head>
<body style="font-family: monospace; max-width: 40rem; margin: 3rem auto;">
<h1>OCI ARM Host Capacity</h1>
<p>The keep-alive web server is running. The OCI check loop lives in the
container and calls <code>php index.php</code> every 60 seconds.</p>
<p>Liveness: <a href="/health">/health</a></p>
</body>
</html>
