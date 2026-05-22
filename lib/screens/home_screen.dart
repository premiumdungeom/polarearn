import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:share_plus/share_plus.dart';
import '../services/api_service.dart';
import '../services/theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;
  Map<String, dynamic>? _data;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final r = await ApiService.getDashboard();
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (r.success) _data = r.data;
    });
  }

  String _fmt(dynamic amount) {
    final v = double.tryParse(amount?.toString() ?? '0') ?? 0;
    return '₦${v.toStringAsFixed(2).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildNavBar(),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppTheme.green))
                  : RefreshIndicator(
                      onRefresh: _load,
                      color: AppTheme.green,
                      child: _buildBody(),
                    ),
            ),
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  Widget _buildNavBar() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              const Icon(Icons.bolt, color: AppTheme.green, size: 32),
              const SizedBox(width: 6),
              RichText(
                text: const TextSpan(
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark),
                  children: [
                    TextSpan(text: 'Polar'),
                    TextSpan(
                        text: 'Earn',
                        style: TextStyle(color: AppTheme.green)),
                  ],
                ),
              ),
            ]),
            GestureDetector(
              onTap: () {},
              child: CircleAvatar(
                radius: 19,
                backgroundColor: AppTheme.greenLight,
                child: Text(
                  (_data?['username'] ?? 'U')[0].toUpperCase(),
                  style: const TextStyle(
                      color: AppTheme.green,
                      fontWeight: FontWeight.w800,
                      fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildBody() => ListView(
        padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
        children: [
          _buildBalanceCard(),
          const SizedBox(height: 14),
          _buildProgressCard(),
          const SizedBox(height: 14),
          _buildEarningsGrid(),
          const SizedBox(height: 14),
          _buildReferCard(),
          const SizedBox(height: 14),
          _buildQuickActions(),
          const SizedBox(height: 14),
          _buildChartCard(),
        ],
      );

  Widget _buildBalanceCard() {
    final avail = (_data?['affiliate_balance'] ?? 0) +
        (_data?['task_balance'] ?? 0);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left - green panel
          Expanded(
            flex: 11,
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.green, AppTheme.greenDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Available Balance',
                      style:
                          TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(_fmt(avail),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () =>
                        Navigator.pushNamed(context, '/withdraw'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: Colors.white70, width: 1.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Withdraw',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600)),
                          SizedBox(width: 6),
                          Icon(Icons.arrow_forward,
                              color: Colors.white, size: 14),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Right - stats
          Expanded(
            flex: 10,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _statItem(Icons.trending_up, 'Total Earned',
                    _fmt(_data?['total_earned'] ?? 0)),
                const Divider(color: AppTheme.border),
                _statItem(Icons.credit_card, 'Withdrawn',
                    _fmt(_data?['total_withdrawn'] ?? 0)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statItem(IconData icon, String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppTheme.greenLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppTheme.green, size: 18),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 11, color: AppTheme.textGray)),
                Text(value,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700)),
              ],
            ),
          ],
        ),
      );

  Widget _buildProgressCard() {
    final progress = (_data?['progress'] ?? 0) as num;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            height: 72,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress / 100,
                  backgroundColor: AppTheme.border,
                  color: AppTheme.green,
                  strokeWidth: 7,
                ),
                Text('${progress.toInt()}%',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 14)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Account Progress',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(
                  progress == 100
                      ? 'Account fully set up 🎉'
                      : progress == 75
                          ? 'Join the official channel to complete setup'
                          : 'Activate a plan to get started!',
                  style: const TextStyle(
                      fontSize: 12, color: AppTheme.textGray),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress / 100,
                    backgroundColor: AppTheme.border,
                    color: AppTheme.green,
                    minHeight: 7,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsGrid() => Row(
        children: [
          Expanded(
            child: _earningCard(
              icon: Icons.people_outline,
              title: 'Affiliate',
              amount: _fmt(_data?['affiliate_balance'] ?? 0),
              linkLabel: 'View Details',
              onTap: () {},
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _earningCard(
              icon: Icons.check_box_outlined,
              title: 'Daily Tasks',
              amount: _fmt(_data?['task_balance'] ?? 0),
              linkLabel: 'View Tasks',
              onTap: () {},
            ),
          ),
        ],
      );

  Widget _earningCard({
    required IconData icon,
    required String title,
    required String amount,
    required String linkLabel,
    required VoidCallback onTap,
  }) =>
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.greenLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppTheme.green, size: 20),
            ),
            const SizedBox(height: 10),
            Text(title,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(amount,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.green)),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: onTap,
              child: Row(
                children: [
                  Text(linkLabel,
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.green)),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward,
                      color: AppTheme.green, size: 14),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _buildReferCard() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.green,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.person_add, color: Colors.white),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Refer & Earn',
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700)),
                  Text('Invite friends and earn more rewards',
                      style:
                          TextStyle(fontSize: 12, color: AppTheme.textGray)),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final code = _data?['ref_code'] ?? '';
                Share.share(
                    'Join PolarEarn and start earning daily! Use my referral code: $code\nhttps://YOUR_DOMAIN.com/register?ref=$code');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                elevation: 0,
              ),
              child: const Text('Refer',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      );

  Widget _buildQuickActions() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Quick Actions',
              style:
                  TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          Row(
            children: [
              _qaItem(Icons.check_box_outlined, 'Daily\nTasks', () {}),
              const SizedBox(width: 10),
              _qaItem(Icons.calendar_today_outlined, 'Check-in', () {}),
              const SizedBox(width: 10),
              _qaItem(Icons.play_circle_outline, 'Monetize', () {}),
              const SizedBox(width: 10),
              _qaItem(Icons.share_outlined, 'Share &\nEarn', () {}),
            ],
          ),
        ],
      );

  Widget _qaItem(IconData icon, String label, VoidCallback onTap) =>
      Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.greenLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: AppTheme.green, size: 22),
                ),
                const SizedBox(height: 8),
                Text(label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 11.5, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      );

  Widget _buildChartCard() {
    final rawPoints =
        (_data?['chart_values'] as List?)?.map((e) => (e as num).toDouble()).toList() ??
            [0, 0, 0, 0, 0, 0];
    final labels = (_data?['chart_labels'] as List?)
            ?.map((e) => e.toString())
            .toList() ??
        ['', '', '', '', '', 'Today'];

    final spots = rawPoints.asMap().entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Earnings Overview',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: AppTheme.border,
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (v, _) => Text(
                        v >= 1000
                            ? '${(v / 1000).toStringAsFixed(0)}k'
                            : v.toStringAsFixed(0),
                        style: const TextStyle(
                            fontSize: 10, color: AppTheme.textLight),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) {
                        final i = v.toInt();
                        if (i < 0 || i >= labels.length) {
                          return const SizedBox();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(labels[i],
                              style: const TextStyle(
                                  fontSize: 10, color: AppTheme.textLight)),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppTheme.green,
                    barWidth: 2.5,
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppTheme.green.withOpacity(0.08),
                    ),
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, _, __, i) {
                        final isLast = i == spots.length - 1;
                        return FlDotCirclePainter(
                          radius: isLast ? 5 : 3.5,
                          color:
                              isLast ? AppTheme.green : Colors.white,
                          strokeWidth: 2,
                          strokeColor: AppTheme.green,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() => Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(Icons.home_outlined, 'Home', 0),
            _navItem(Icons.check_box_outlined, 'Tasks', 1),
            // FAB
            GestureDetector(
              onTap: () {},
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF22b94a), AppTheme.greenDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3.5),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.green.withOpacity(0.45),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.bolt, color: Colors.white, size: 28),
                  ),
                  const SizedBox(height: 4),
                  const Text('Activate\nPlan',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 9.5, color: AppTheme.textLight)),
                ],
              ),
            ),
            _navItem(Icons.people_outline, 'Referrals', 3),
            _navItem(Icons.person_outline, 'Profile', 4),
          ],
        ),
      );

  Widget _navItem(IconData icon, String label, int index) {
    final active = _tab == index;
    return GestureDetector(
      onTap: () {
        setState(() => _tab = index);
        if (index == 4) {
          // profile
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              color: active ? AppTheme.green : AppTheme.textLight, size: 22),
          const SizedBox(height: 3),
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: active ? AppTheme.green : AppTheme.textLight)),
        ],
      ),
    );
  }
}
