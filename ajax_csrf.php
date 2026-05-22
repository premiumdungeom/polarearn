<?php
// ============================================================
// PolarEarn - ajax_csrf.php
// Returns a fresh CSRF token for the Flutter app
// ============================================================
require_once 'config.php';
session_start();
$token = generateCSRFToken();
header('Content-Type: application/json');
echo json_encode(['token' => $token]);
