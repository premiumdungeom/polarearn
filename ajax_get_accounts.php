<?php
// ============================================================
// PolarEarn - ajax_get_accounts.php
// Returns the logged-in user's saved bank accounts as JSON
// ============================================================
require_once 'config.php';
requireLogin();

$conn   = getDBConnection();
$userId = (int)$_SESSION['user_id'];

$stmt = $conn->prepare(
    'SELECT id, bank_name, bank_code, account_number, account_name, is_primary, created_at
     FROM user_bank_accounts
     WHERE user_id = ?
     ORDER BY is_primary DESC, id ASC
     LIMIT 3'
);
$stmt->bind_param('i', $userId);
$stmt->execute();
$accounts = $stmt->get_result()->fetch_all(MYSQLI_ASSOC);
$stmt->close();
$conn->close();

jsonResponse(true, 'OK', ['accounts' => $accounts]);
