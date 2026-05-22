<?php
// ============================================================
// PolarEarn - ajax_dashboard.php
// Returns dashboard data as JSON for the Flutter app
// ============================================================
require_once 'config.php';

if (!isLoggedIn()) {
    jsonResponse(false, 'Not authenticated.');
}

$conn   = getDBConnection();
$userId = (int)$_SESSION['user_id'];

// User basics
$stmt = $conn->prepare(
    'SELECT username, avatar, affiliate_balance, task_balance,
            total_earned, plan, channel_joined, ref_code
     FROM users WHERE id = ? LIMIT 1'
);
$stmt->bind_param('i', $userId);
$stmt->execute();
$user = $stmt->get_result()->fetch_assoc();
$stmt->close();

if (!$user) {
    jsonResponse(false, 'User not found.');
}

// Total withdrawn
$wStmt = $conn->prepare(
    'SELECT COALESCE(SUM(amount),0) AS total_withdrawn
     FROM withdrawals WHERE user_id = ? AND status = "completed"'
);
$wStmt->bind_param('i', $userId);
$wStmt->execute();
$totalWithdrawn = (float)$wStmt->get_result()->fetch_assoc()['total_withdrawn'];
$wStmt->close();

// Weekly chart data (last 6 weeks)
$chartStmt = $conn->prepare(
    'SELECT DATE(DATE_SUB(rb.created_at, INTERVAL WEEKDAY(rb.created_at) DAY)) AS week_start,
            SUM(rb.bonus_amount) AS week_earnings
     FROM referral_bonuses rb
     WHERE rb.referrer_id = ?
       AND rb.created_at >= DATE_SUB(CURDATE(), INTERVAL 42 DAY)
     GROUP BY week_start ORDER BY week_start ASC'
);
$chartStmt->bind_param('i', $userId);
$chartStmt->execute();
$weekRows = $chartStmt->get_result()->fetch_all(MYSQLI_ASSOC);
$chartStmt->close();

$weekMap = [];
foreach ($weekRows as $row) {
    $weekMap[$row['week_start']] = (float)$row['week_earnings'];
}

$baseStmt = $conn->prepare(
    'SELECT COALESCE(SUM(bonus_amount),0) AS recent_sum
     FROM referral_bonuses
     WHERE referrer_id = ? AND created_at >= DATE_SUB(CURDATE(), INTERVAL 42 DAY)'
);
$baseStmt->bind_param('i', $userId);
$baseStmt->execute();
$recentSum = (float)$baseStmt->get_result()->fetch_assoc()['recent_sum'];
$baseStmt->close();
$conn->close();

$totalEarned  = (float)($user['total_earned'] ?? 0);
$runningTotal = max(0, $totalEarned - $recentSum);
$chartLabels  = [];
$chartValues  = [];

for ($i = 5; $i >= 0; $i--) {
    $weekStartTs   = strtotime("monday this week -" . ($i * 7) . " days");
    $weekStartDate = date('Y-m-d', $weekStartTs);
    $runningTotal += $weekMap[$weekStartDate] ?? 0;
    $chartLabels[] = $i === 0 ? date('M j') : date('M j', $weekStartTs);
    $chartValues[] = round($runningTotal, 2);
}

// Account progress
$hasPlan       = !empty($user['plan']);
$channelJoined = (bool)($user['channel_joined'] ?? false);
$progress = $hasPlan && $channelJoined ? 100 : ($hasPlan ? 75 : 0);

jsonResponse(true, 'OK', [
    'username'          => $user['username'],
    'avatar'            => $user['avatar'],
    'affiliate_balance' => (float)$user['affiliate_balance'],
    'task_balance'      => (float)$user['task_balance'],
    'total_earned'      => $totalEarned,
    'total_withdrawn'   => $totalWithdrawn,
    'ref_code'          => $user['ref_code'],
    'progress'          => $progress,
    'chart_labels'      => $chartLabels,
    'chart_values'      => $chartValues,
]);
