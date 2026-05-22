import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/theme.dart';

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  List<dynamic> _accounts = [];
  List<dynamic> _banks = [];
  bool _loading = true;

  // Add account form state
  String? _selectedBankCode, _selectedBankName, _resolvedName;
  final _accNumCtrl = TextEditingController();
  bool _isPrimary = false;
  bool _verifying = false, _saving = false;
  String? _verifyError;

  @override
  void initState() {
    super.initState();
    _load();
    _loadBanks();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final r = await ApiService.getBankAccounts();
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (r.success) _accounts = r.data?['accounts'] ?? [];
    });
  }

  Future<void> _loadBanks() async {
    final r = await ApiService.getBanks();
    if (!mounted) return;
    if (r.success) setState(() => _banks = r.data?['banks'] ?? []);
  }

  Future<void> _verify() async {
    final accNum = _accNumCtrl.text.trim();
    if (_selectedBankCode == null || accNum.length != 10) return;

    setState(() { _verifying = true; _resolvedName = null; _verifyError = null; });
    final r = await ApiService.resolveAccount(
        accountNumber: accNum, bankCode: _selectedBankCode!);
    if (!mounted) return;
    setState(() {
      _verifying = false;
      if (r.success) {
        _resolvedName = r.data?['data']?['account_name'];
      } else {
        _verifyError = 'Could not verify. Check number and bank.';
      }
    });
  }

  Future<void> _save() async {
    if (_resolvedName == null || _selectedBankCode == null) return;
    setState(() => _saving = true);
    final r = await ApiService.saveAccount(
      bankCode: _selectedBankCode!,
      bankName: _selectedBankName!,
      accountNumber: _accNumCtrl.text.trim(),
      accountName: _resolvedName!,
      isPrimary: _isPrimary,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (r.success) {
      Navigator.pop(context);
      _load();
      _showToast('Account saved successfully!');
    } else {
      _showToast(r.message, error: true);
    }
  }

  Future<void> _delete(int id, String bankName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Remove Account?',
            style: TextStyle(fontWeight: FontWeight.w800)),
        content: Text('Remove $bankName account? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel',
                  style: TextStyle(color: AppTheme.textGray))),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Remove',
                  style: TextStyle(color: AppTheme.red))),
        ],
      ),
    );
    if (confirmed != true) return;
    final r = await ApiService.deleteAccount(id);
    if (!mounted) return;
    if (r.success) {
      _load();
      _showToast('Account removed.');
    } else {
      _showToast(r.message, error: true);
    }
  }

  void _showToast(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error ? AppTheme.red : AppTheme.textDark,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
    ));
  }

  void _openAddSheet() {
    _accNumCtrl.clear();
    _selectedBankCode = null;
    _selectedBankName = null;
    _resolvedName = null;
    _verifyError = null;
    _isPrimary = _accounts.isEmpty;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: AppTheme.border,
                        borderRadius: BorderRadius.circular(4)),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Add Bank Account',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                const Text(
                    "Select your bank and enter your account number — we'll verify it instantly.",
                    style: TextStyle(
                        fontSize: 13, color: AppTheme.textGray)),
                const SizedBox(height: 20),

                // Bank dropdown
                const Text('Bank',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF555555))),
                const SizedBox(height: 7),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.border, width: 2),
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xFFfafafa),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      hint: const Text('— Select bank —',
                          style: TextStyle(fontSize: 14)),
                      value: _selectedBankCode,
                      items: _banks.map<DropdownMenuItem<String>>((b) {
                        return DropdownMenuItem(
                          value: b['code'].toString(),
                          child: Text(b['name'].toString(),
                              style: const TextStyle(fontSize: 14)),
                        );
                      }).toList(),
                      onChanged: (v) {
                        setS(() {
                          _selectedBankCode = v;
                          _selectedBankName = _banks.firstWhere(
                              (b) => b['code'].toString() == v,
                              orElse: () => {'name': ''})['name'];
                          _resolvedName = null;
                          _verifyError = null;
                        });
                        if (_accNumCtrl.text.length == 10) _verify().then((_) => setS(() {}));
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Account number
                const Text('Account Number',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF555555))),
                const SizedBox(height: 7),
                TextField(
                  controller: _accNumCtrl,
                  keyboardType: TextInputType.number,
                  maxLength: 10,
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: 'Enter 10-digit account number',
                    hintStyle: const TextStyle(
                        fontSize: 14, color: AppTheme.textLight),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 13),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: AppTheme.border, width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: AppTheme.border, width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: AppTheme.green, width: 2),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFfafafa),
                  ),
                  onChanged: (v) {
                    setS(() { _resolvedName = null; _verifyError = null; });
                    if (v.length == 10 && _selectedBankCode != null) {
                      _verify().then((_) => setS(() {}));
                    }
                  },
                ),

                // Verify status
                if (_verifying)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Row(children: [
                      SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppTheme.green)),
                      SizedBox(width: 8),
                      Text('Verifying…',
                          style: TextStyle(fontSize: 12, color: AppTheme.textGray)),
                    ]),
                  ),

                if (_resolvedName != null)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.greenLight,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: AppTheme.green.withOpacity(0.25), width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('ACCOUNT NAME',
                            style: TextStyle(
                                fontSize: 11,
                                color: AppTheme.green,
                                fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text(_resolvedName!,
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),

                if (_verifyError != null)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.redLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(_verifyError!,
                        style: const TextStyle(
                            fontSize: 13, color: AppTheme.red)),
                  ),

                const SizedBox(height: 16),

                // Primary checkbox
                Row(children: [
                  Checkbox(
                    value: _isPrimary || _accounts.isEmpty,
                    onChanged: _accounts.isEmpty
                        ? null
                        : (v) => setS(() => _isPrimary = v ?? false),
                    activeColor: AppTheme.green,
                  ),
                  const Text('Set as primary account',
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600)),
                ]),
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: (_resolvedName == null || _saving)
                        ? null
                        : () => _save().then((_) => setS(() {})),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: _saving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2.5))
                        : const Text('Save Account',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Details'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.green))
          : RefreshIndicator(
              onRefresh: _load,
              color: AppTheme.green,
              child: ListView(
                padding: const EdgeInsets.all(14),
                children: [
                  // Header card
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
                    child: Row(children: [
                      const Icon(Icons.credit_card, color: Colors.white, size: 28),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Bank Accounts',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800)),
                            Text('${_accounts.length}/3 slots used.',
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 13)),
                          ],
                        ),
                      ),
                      // Slot dots
                      Row(
                        children: List.generate(3, (i) => Container(
                          margin: const EdgeInsets.only(left: 6),
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: i < _accounts.length
                                ? Colors.white
                                : Colors.white30,
                            border: Border.all(
                                color: Colors.white54, width: 1.5),
                          ),
                        )),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 16),

                  if (_accounts.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFfff8e6),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: const Color(0xFFffe8a3), width: 1),
                      ),
                      child: const Row(children: [
                        Text('💡', style: TextStyle(fontSize: 16)),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'No saved accounts yet. Add your bank account below to enable withdrawals.',
                            style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF7a5c00),
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ]),
                    ),

                  // Accounts list
                  ..._accounts.map((acc) => _buildAccountCard(acc)),

                  const SizedBox(height: 8),

                  // Add account card
                  GestureDetector(
                    onTap: _accounts.length >= 3 ? null : _openAddSheet,
                    child: Opacity(
                      opacity: _accounts.length >= 3 ? 0.5 : 1,
                      child: Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: AppTheme.border,
                              width: 2,
                              style: BorderStyle.solid),
                        ),
                        child: Row(children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppTheme.greenLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.add_circle_outline,
                                color: AppTheme.green, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _accounts.length >= 3
                                      ? 'Limit Reached (3/3)'
                                      : 'Add Bank Account',
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700),
                                ),
                                Text(
                                  _accounts.length >= 3
                                      ? 'Remove an account to add a new one'
                                      : 'Account name is verified automatically',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textGray),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right,
                              color: AppTheme.border),
                        ]),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Info banner
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFfff8e6),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: const Color(0xFFffe8a3), width: 1),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('🔒', style: TextStyle(fontSize: 16)),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Account details are verified. Your primary account is used for all withdrawals. You can save up to 3 accounts.',
                            style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF7a5c00),
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildAccountCard(Map acc) {
    final isPrimary = acc['is_primary'] == 1 || acc['is_primary'] == true;
    final last4 = acc['account_number'].toString().substring(
        acc['account_number'].toString().length - 4);
    final initials = acc['bank_name'].toString().substring(0, 2).toUpperCase();

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPrimary ? AppTheme.green : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        children: [
          Row(children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppTheme.greenLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(initials,
                    style: const TextStyle(
                        color: AppTheme.green,
                        fontWeight: FontWeight.w800,
                        fontSize: 16)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(acc['bank_name'].toString(),
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w700)),
                  Text('**** **** $last4',
                      style: const TextStyle(
                          fontSize: 12, color: AppTheme.textGray)),
                ],
              ),
            ),
            if (isPrimary)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.greenLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: AppTheme.green.withOpacity(0.2), width: 1.5),
                ),
                child: const Text('✓ Primary',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.green)),
              ),
          ]),
          const Divider(height: 24, color: AppTheme.border),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Account Name',
                style: TextStyle(fontSize: 11, color: AppTheme.textLight)),
            Text(acc['account_name'].toString(),
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            if (!isPrimary)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await ApiService.setPrimaryAccount(acc['id']);
                    _load();
                  },
                  icon: const Icon(Icons.check, size: 14),
                  label: const Text('Set Primary',
                      style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.green,
                    side: const BorderSide(color: AppTheme.greenLight),
                    backgroundColor: AppTheme.greenLight,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            if (!isPrimary) const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () =>
                    _delete(acc['id'], acc['bank_name'].toString()),
                icon: const Icon(Icons.delete_outline, size: 14),
                label: const Text('Remove', style: TextStyle(fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.red,
                  side: const BorderSide(color: AppTheme.redLight),
                  backgroundColor: AppTheme.redLight,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ]),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _accNumCtrl.dispose();
    super.dispose();
  }
}
