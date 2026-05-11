import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../models/barber.dart';
import '../../services/api_service.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';

class BarberDetailsScreen extends StatefulWidget {
  final Barber barber;

  const BarberDetailsScreen({super.key, required this.barber});

  @override
  State<BarberDetailsScreen> createState() => _BarberDetailsScreenState();
}

class _BarberDetailsScreenState extends State<BarberDetailsScreen> {
  final ApiService _apiService = ApiService();
  Service? _selectedService;
  DateTime _selectedDate = DateTime.now();
  String? _selectedSlot;
  List<String> _availableSlots = [];
  bool _isLoadingSlots = false;

  @override
  void initState() {
    super.initState();
    if (widget.barber.services.isNotEmpty) {
      _selectedService = widget.barber.services.first;
      _loadSlots();
    }
  }

  Future<void> _loadSlots() async {
    if (_selectedService == null) return;

    setState(() {
      _isLoadingSlots = true;
      _selectedSlot = null;
    });

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    
    final slots = await _apiService.fetchAvailableSlots(
      auth.token!,
      widget.barber.id,
      dateStr,
      _selectedService!.id,
    );

    setState(() {
      _availableSlots = slots;
      _isLoadingSlots = false;
    });
  }

  void _showBookingConfirmation() {
    if (_selectedService == null || _selectedSlot == null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        decoration: const BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Confirm Booking', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textColor)),
            const SizedBox(height: 24),
            _buildInfoRow(LucideIcons.scissors, 'Service', _selectedService!.name),
            const SizedBox(height: 16),
            _buildInfoRow(LucideIcons.calendar, 'Date', DateFormat('EEEE, d MMMM').format(_selectedDate)),
            const SizedBox(height: 16),
            _buildInfoRow(LucideIcons.clock, 'Time', _selectedSlot!),
            const SizedBox(height: 16),
            _buildInfoRow(LucideIcons.banknote, 'Total Price', '₹${_selectedService!.defaultPrice.toStringAsFixed(0)}'),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _handleBooking();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Confirm & Book', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.accentColor),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(color: AppTheme.secondaryTextColor)),
        const Spacer(),
        Text(value, style: const TextStyle(color: AppTheme.textColor, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Future<void> _handleBooking() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await _apiService.createBooking(auth.token!, {
      'barberId': widget.barber.id,
      'serviceId': _selectedService!.id,
      'date': DateFormat('yyyy-MM-dd').format(_selectedDate),
      'startTime': _selectedSlot,
      'paymentType': 'cash',
      'amount': _selectedService!.defaultPrice,
    });

    if (success) {
      if (mounted) {
        _showSuccessAnimation();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking failed. Please try again.')),
        );
      }
    }
  }

  void _showSuccessAnimation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(32),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.check, size: 64, color: Colors.green),
              ),
              const SizedBox(height: 24),
              const Text('Booking Confirmed!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textColor)),
              const SizedBox(height: 8),
              const Text('Your appointment has been sent to the barber.', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.secondaryTextColor)),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Dialog
                    Navigator.pop(context); // Details Screen
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Back to Home'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Choose Service'),
                  const SizedBox(height: 16),
                  _buildServiceList(),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Select Date'),
                  const SizedBox(height: 16),
                  _buildDatePicker(),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Available Time'),
                  const SizedBox(height: 16),
                  _buildSlotGrid(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _buildBottomAction(),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: AppTheme.backgroundColor,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(widget.barber.shopName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black87],
                ),
              ),
            ),
            Center(
              child: Hero(
                tag: 'barber-${widget.barber.id}',
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: AppTheme.accentColor.withOpacity(0.2),
                  child: const Icon(LucideIcons.scissors, size: 40, color: AppTheme.accentColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textColor),
    );
  }

  Widget _buildServiceList() {
    return Column(
      children: widget.barber.services.map((service) {
        final isSelected = _selectedService?.id == service.id;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () {
              setState(() => _selectedService = service);
              _loadSlots();
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.accentColor.withOpacity(0.1) : AppTheme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isSelected ? AppTheme.accentColor : AppTheme.borderColor),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.accentColor : AppTheme.borderColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(LucideIcons.scissors, size: 20, color: isSelected ? Colors.white : AppTheme.secondaryTextColor),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(service.name, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textColor)),
                        Text('${service.durationMinutes} min', style: const TextStyle(fontSize: 12, color: AppTheme.secondaryTextColor)),
                      ],
                    ),
                  ),
                  Text('₹${service.defaultPrice.toStringAsFixed(0)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.accentColor)),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDatePicker() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 14,
        itemBuilder: (context, index) {
          final date = DateTime.now().add(Duration(days: index));
          final isSelected = DateFormat('yyyy-MM-dd').format(date) == DateFormat('yyyy-MM-dd').format(_selectedDate);
          final isToday = DateFormat('yyyy-MM-dd').format(date) == DateFormat('yyyy-MM-dd').format(DateTime.now());

          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              onTap: () {
                setState(() => _selectedDate = date);
                _loadSlots();
              },
              child: Container(
                width: 75,
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.accentColor : AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isSelected ? AppTheme.accentColor : AppTheme.borderColor),
                  boxShadow: isSelected ? [BoxShadow(color: AppTheme.accentColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(isToday ? 'Today' : DateFormat('EEE').format(date), style: TextStyle(color: isSelected ? Colors.white70 : AppTheme.secondaryTextColor, fontSize: 11, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(DateFormat('d').format(date), style: TextStyle(color: isSelected ? Colors.white : AppTheme.textColor, fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSlotGrid() {
    if (_isLoadingSlots) {
      return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: AppTheme.accentColor)));
    }

    if (_availableSlots.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: AppTheme.cardColor, borderRadius: BorderRadius.circular(16)),
        child: const Center(child: Text('No slots available for this day.', style: TextStyle(color: AppTheme.mutedTextColor))),
      );
    }

    // Split slots into Morning and Evening
    final morning = _availableSlots.where((s) => int.parse(s.split(':')[0]) < 12).toList();
    final afternoon = _availableSlots.where((s) => int.parse(s.split(':')[0]) >= 12 && int.parse(s.split(':')[0]) < 17).toList();
    final evening = _availableSlots.where((s) => int.parse(s.split(':')[0]) >= 17).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (morning.isNotEmpty) ...[_buildTimeHeading('Morning'), _buildChips(morning)],
        if (afternoon.isNotEmpty) ...[_buildTimeHeading('Afternoon'), _buildChips(afternoon)],
        if (evening.isNotEmpty) ...[_buildTimeHeading('Evening'), _buildChips(evening)],
      ],
    );
  }

  Widget _buildTimeHeading(String label) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.secondaryTextColor)),
    );
  }

  Widget _buildChips(List<String> times) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: times.map((slot) {
        final isSelected = _selectedSlot == slot;
        return InkWell(
          onTap: () => setState(() => _selectedSlot = slot),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.accentColor : AppTheme.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isSelected ? AppTheme.accentColor : AppTheme.borderColor),
            ),
            child: Text(slot, style: TextStyle(color: isSelected ? Colors.white : AppTheme.textColor, fontWeight: FontWeight.w500)),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBottomAction() {
    if (_selectedSlot == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Total Price', style: TextStyle(color: AppTheme.secondaryTextColor, fontSize: 12)),
                Text('₹${_selectedService!.defaultPrice.toStringAsFixed(0)}', style: const TextStyle(color: AppTheme.textColor, fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: _showBookingConfirmation,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentColor,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Book Now', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
