import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.token != null) {
      final data = await _apiService.fetchTransactions(auth.token!);
      if (mounted) {
        setState(() {
          _transactions = data;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBarber = Provider.of<AuthProvider>(context, listen: false).role == 'barber';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.accentColor))
          : _transactions.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadTransactions,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _transactions.length,
                    itemBuilder: (context, index) {
                      final tx = _transactions[index];
                      return _buildTransactionCard(tx, isBarber);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.banknote, size: 64, color: AppTheme.secondaryTextColor.withOpacity(0.3)),
          const SizedBox(height: 16),
          const Text(
            'No transactions yet',
            style: TextStyle(color: AppTheme.secondaryTextColor, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> tx, bool isBarber) {
    final date = DateTime.parse(tx['createdAt']);
    final paymentType = tx['paymentType'] ?? 'cash';
    final amount = tx['amount'] ?? 0;
    final barberName = tx['barber'] != null ? tx['barber']['name'] : 'Unknown';
    final customerName = tx['customer'] != null ? tx['customer']['name'] : 'Guest';
    final serviceName = tx['booking'] != null && tx['booking']['service'] != null 
        ? tx['booking']['service']['name'] 
        : 'Service';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (paymentType == 'online' ? Colors.blue : Colors.green).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              paymentType == 'online' ? LucideIcons.creditCard : LucideIcons.banknote,
              color: paymentType == 'online' ? Colors.blue : Colors.green,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  serviceName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  isBarber ? 'From: $customerName' : 'At: $barberName',
                  style: const TextStyle(color: AppTheme.secondaryTextColor, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('d MMM, yyyy • hh:mm a').format(date),
                  style: TextStyle(color: AppTheme.secondaryTextColor.withOpacity(0.7), fontSize: 11),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹$amount',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textColor),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'PAID',
                  style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
