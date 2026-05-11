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

  Future<void> _handleBooking() async {
    if (_selectedService == null || _selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a service and a time slot')),
      );
      return;
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await _apiService.createBooking(auth.token!, {
      'barberId': widget.barber.id,
      'serviceId': _selectedService!.id,
      'date': DateFormat('yyyy-MM-dd').format(_selectedDate),
      'startTime': _selectedSlot,
      'paymentType': 'cash', // Default for now
      'amount': _selectedService!.defaultPrice,
    });

    if (success) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppTheme.cardColor,
            title: const Text('Success!', style: TextStyle(color: AppTheme.textColor)),
            content: const Text('Your booking request has been sent to the barber.', style: TextStyle(color: AppTheme.secondaryTextColor)),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Dialog
                  Navigator.pop(context); // Details Screen
                },
                child: const Text('Great!'),
              ),
            ],
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking failed. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.barber.shopName)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBarberInfo(),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Select Service', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textColor)),
                  const SizedBox(height: 16),
                  _buildServiceList(),
                  const SizedBox(height: 32),
                  const Text('Select Date', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textColor)),
                  const SizedBox(height: 16),
                  _buildDatePicker(),
                  const SizedBox(height: 32),
                  const Text('Available Time Slots', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textColor)),
                  const SizedBox(height: 16),
                  _buildSlotGrid(),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _selectedSlot == null ? null : _handleBooking,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Book Now', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarberInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppTheme.accentColor.withOpacity(0.1),
            child: const Icon(LucideIcons.scissors, color: AppTheme.accentColor, size: 32),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.barber.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textColor)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(LucideIcons.mapPin, size: 14, color: AppTheme.secondaryTextColor),
                    const SizedBox(width: 4),
                    Text(widget.barber.location.city, style: const TextStyle(color: AppTheme.secondaryTextColor)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceList() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: widget.barber.services.map((service) {
        final isSelected = _selectedService?.id == service.id;
        return InkWell(
          onTap: () {
            setState(() => _selectedService = service);
            _loadSlots();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.accentColor : AppTheme.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isSelected ? AppTheme.accentColor : AppTheme.borderColor),
            ),
            child: Column(
              children: [
                Text(service.name, style: TextStyle(color: isSelected ? Colors.white : AppTheme.textColor, fontWeight: FontWeight.bold)),
                Text('₹${service.defaultPrice.toStringAsFixed(0)} • ${service.durationMinutes}m', 
                  style: TextStyle(color: isSelected ? Colors.white70 : AppTheme.secondaryTextColor, fontSize: 12)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDatePicker() {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 14, // Next 2 weeks
        itemBuilder: (context, index) {
          final date = DateTime.now().add(Duration(days: index));
          final isSelected = DateFormat('yyyy-MM-dd').format(date) == DateFormat('yyyy-MM-dd').format(_selectedDate);
          
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              onTap: () {
                setState(() => _selectedDate = date);
                _loadSlots();
              },
              child: Container(
                width: 70,
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.accentColor : AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isSelected ? AppTheme.accentColor : AppTheme.borderColor),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(DateFormat('EEE').format(date), style: TextStyle(color: isSelected ? Colors.white70 : AppTheme.secondaryTextColor, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(DateFormat('d').format(date), style: TextStyle(color: isSelected ? Colors.white : AppTheme.textColor, fontSize: 18, fontWeight: FontWeight.bold)),
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
      return const Center(child: CircularProgressIndicator(color: AppTheme.accentColor));
    }

    if (_availableSlots.isEmpty) {
      return const Text('No slots available for this day.', style: TextStyle(color: AppTheme.mutedTextColor));
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 2.2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _availableSlots.length,
      itemBuilder: (context, index) {
        final slot = _availableSlots[index];
        final isSelected = _selectedSlot == slot;

        return InkWell(
          onTap: () => setState(() => _selectedSlot = slot),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.accentColor : AppTheme.cardColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: isSelected ? AppTheme.accentColor : AppTheme.borderColor),
            ),
            child: Text(slot, style: TextStyle(color: isSelected ? Colors.white : AppTheme.textColor, fontWeight: FontWeight.w500)),
          ),
        );
      },
    );
  }
}
