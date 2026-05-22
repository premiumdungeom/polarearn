import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/theme.dart';

class WithdrawScreen extends StatefulWidget {
  const WithdrawScreen({super.key});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  final _amountCtrl = TextEditingController();
  List<dynamic> _accounts = [];
  int? _selectedAccountId;
  bool _loading = true, _submitting = false;
  String? _error, _statusMsg;
  bool _success = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final r = await ApiService.getBankAccounts();
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (r.success) {
        _accounts = r.data?['accounts'] ?? [];
        // Auto-select primary
        final primary = _accounts.firstWhere(
            (a) => a['is_primary'] == 1 || a['is_primary'] == true,
            orElse: () => _accounts.isNotEmpty ? _accounts[0] : null);
        if (primary != null) _selectedAccountId = primary['id'];
      }
    });
  }

  Future<void> _withdraw() async {
    final amountText = _amountCtrl.text.trim();
    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      setState(() => _error = 'Enter a valid amount');
      return;
    }
    if (_selectedAccountId == null) {
      setState(() => _error = 'Select a bank account');
      return;
    }

    setState(() { _submitting = true; _error = null; _statusMsg = null; });

    final r = await ApiService.requestWithdrawal(
        amount: amount, accountId: _selectedAccountId!);
    if (!mounted) return;

    if (r.success) {
      // Poll for completion
      final ref = r.data?['reference'] ?? '';
      final flwId = r.data?['flw_id'] ?? '';
      setState(() => _statusMsg = 'Transfer initiated. Checking status…');

      await Future.delayed(const Duration(seconds: 5));
      final check = await ApiService.checkWithdrawal(
          reference: ref, flwId: flwId.toString());
      if (!mounted) return;

      setState(() {
        _submitting = false;
        if (check.success) {
          _success = true;
          _statusMsg = '✅ Transfer completed!';
        } else {
          _statusMsg = check.message;
        }
      });
    } else {
      setState(() {
        _submitting = false;
        _error = r.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Withdraw'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: AppTheme.bg,
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.green))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.green, AppTheme.greenDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(children: [
                      Icon(Icons.account_balance_wallet_outlined,
                          color: Colors.white, size: 28),
                      SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Request Withdrawal',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800)),
                          Text('Funds sent to your bank account',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 13)),
                        ],
                      ),
                    ]),
                  ),
                  const SizedBox(height: 20),

                  if (_success) ...[
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.greenLight,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.green, width: 1.5),
                      ),
                      child: Column(children: [
                        const Icon(Icons.check_circle,
                            color: AppTheme.green, size: 48),
                        const SizedBox(height: 12),
                        Text(_statusMsg ?? 'Transfer complete!',
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.green)),
                      ]),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.green,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                        ),
                        child: const Text('Back to Home',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ] else ...[
                    if (_error != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.redLight,
                          borderRadius: BorderRadius.circular(10),
                          border: const Border(
                              left: BorderSide(
                                  color: AppTheme.red, width: 3)),
                        ),
                        child: Text(_error!,
                            style: const TextStyle(
                                color: AppTheme.red, fontSize: 13)),
                      ),
                      const SizedBox(height: 14),
                    ],

                    if (_statusMsg != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.greenLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(children: [
                          const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppTheme.green)),
                          const SizedBox(width: 10),
                          Text(_statusMsg!,
                              style: const TextStyle(
                                  fontSize: 13, color: AppTheme.green)),
                        ]),
                      ),
                      const SizedBox(height: 14),
                    ],

                    // Amount field
                    const Text('Amount (₦)',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _amountCtrl,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.w700),
                      decoration: InputDecoration(
                        prefixText: '₦ ',
                        prefixStyle: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textDark),
                        hintText: '0.00',
                        hintStyle: const TextStyle(
                            color: AppTheme.textLight, fontSize: 24),
                        contentPadding: const EdgeInsets.all(16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: AppTheme.border, width: 2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: AppTheme.border, width: 2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: AppTheme.green, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Account selector
                    const Text('Send to',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),

                    if (_accounts.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFfff8e6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(children: [
                          const Text('⚠️'),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('No bank account saved',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700)),
                                const SizedBox(height: 4),
                                GestureDetector(
                                  onTap: () => Navigator.pushNamed(
                                      context, '/accounts'),
                                  child: const Text('Add one now →',
                                      style: TextStyle(
                                          color: AppTheme.green,
                                          fontWeight: FontWeight.w600)),
                                ),
                              ],
                            ),
                          ),
                        ]),
                      )
                    else
                      ..._accounts.map((acc) {
                        final isPrimary = acc['is_primary'] == 1 ||
                            acc['is_primary'] == true;
                        final last4 = acc['account_number']
                            .toString()
                            .substring(acc['account_number']
                                    .toString()
                                    .length -
                                4);
                        return GestureDetector(
                          onTap: () => setState(
                              () => _selectedAccountId = acc['id']),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color:
                                    _selectedAccountId == acc['id']
                                        ? AppTheme.green
                                        : AppTheme.border,
                                width: 2,
                              ),
                            ),
                            child: Row(children: [
                              Radio<int>(
                                value: acc['id'],
                                groupValue: _selectedAccountId,
                                onChanged: (v) =>
                                    setState(() => _selectedAccountId = v),
                                activeColor: AppTheme.green,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(acc['bank_name'].toString(),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14)),
                                    Text(
                                        '**** $last4 · ${acc['account_name']}',
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: AppTheme.textGray)),
                                  ],
                                ),
                              ),
                              if (isPrimary)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppTheme.greenLight,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text('Primary',
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: AppTheme.green,
                                          fontWeight: FontWeight.w700)),
                                ),
                            ]),
                          ),
                        );
                      }),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: (_submitting || _accounts.isEmpty)
                            ? null
                            : _withdraw,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                          elevation: 0,
                        ),
                        child: _submitting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2.5))
                            : const Text('Request Withdrawal',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }
}
