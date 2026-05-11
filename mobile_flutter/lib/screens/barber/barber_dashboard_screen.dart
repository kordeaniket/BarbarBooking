import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../widgets/booking_card.dart';
import '../../theme/app_theme.dart';
import '../../models/booking.dart';
import '../../models/barber.dart';
import '../../services/api_service.dart';
import '../common/profile_screen.dart';

class BarberDashboardScreen extends StatefulWidget {
  const BarberDashboardScreen({super.key});

  @override
  State<BarberDashboardScreen> createState() => _BarberDashboardScreenState();
}

class _BarberDashboardScreenState extends State<BarberDashboardScreen> {
  final ApiService _apiService = ApiService();
  int _selectedIndex = 0;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Service> _services = [];
  bool _isLoadingServices = false;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshBookings();
      _refreshServices();
    });
  }

  Future<void> _refreshBookings() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.token != null) {
      await Provider.of<BookingProvider>(context, listen: false).fetchBookings(auth.token!);
    }
  }

  Future<void> _refreshServices() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.token != null && auth.userId != null) {
      setState(() => _isLoadingServices = true);
      final services = await _apiService.fetchBarberServices(auth.token!, auth.userId!);
      setState(() {
        _services = services;
        _isLoadingServices = false;
      });
    }
  }

  void _handleStatusUpdate(String bookingId, String status) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await Provider.of<BookingProvider>(context, listen: false)
        .updateBookingStatus(auth.token!, bookingId, status);
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking $status successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update booking status')),
      );
    }
  }

  void _showPaymentSelectionDialog(String bookingId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Payment Method',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textColor),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildPaymentOption(
                    icon: LucideIcons.banknote,
                    label: 'Cash',
                    color: Colors.green,
                    onTap: () {
                      Navigator.pop(context);
                      _handlePaymentUpdate(bookingId, 'received', 'cash');
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildPaymentOption(
                    icon: LucideIcons.creditCard,
                    label: 'Online',
                    color: Colors.blue,
                    onTap: () {
                      Navigator.pop(context);
                      _handlePaymentUpdate(bookingId, 'received', 'online');
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  void _handlePaymentUpdate(String bookingId, String status, String type) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await _apiService.updatePaymentStatus(auth.token!, bookingId, status, type);
    
    if (success) {
      _refreshBookings();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment via ${type.toUpperCase()} recorded successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update payment status')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(LucideIcons.inbox), label: 'Requests'),
          BottomNavigationBarItem(icon: Icon(LucideIcons.calendar), label: 'Schedule'),
          BottomNavigationBarItem(icon: Icon(LucideIcons.scissors), label: 'Services'),
          BottomNavigationBarItem(icon: Icon(LucideIcons.user), label: 'Profile'),
        ],
      ),
      floatingActionButton: _selectedIndex == 2 
        ? FloatingActionButton(
            onPressed: () => _showServiceSheet(),
            backgroundColor: AppTheme.accentColor,
            child: const Icon(LucideIcons.plus, color: Colors.white),
          )
        : null,
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0: return Scaffold(appBar: AppBar(title: const Text('New Requests')), body: _buildRequestsTab());
      case 1: return Scaffold(appBar: AppBar(title: const Text('Schedule')), body: _buildScheduleTab());
      case 2: return Scaffold(appBar: AppBar(title: const Text('My Services')), body: _buildServicesTab());
      case 3: return const ProfileScreen();
      default: return _buildRequestsTab();
    }
  }

  Widget _buildServicesTab() {
    if (_isLoadingServices) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.accentColor));
    }

    if (_services.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.scissors, size: 64, color: AppTheme.mutedTextColor),
            const SizedBox(height: 16),
            const Text('No services added yet', style: TextStyle(color: AppTheme.secondaryTextColor)),
            TextButton(onPressed: _refreshServices, child: const Text('Refresh')),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshServices,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _services.length,
        itemBuilder: (context, index) {
          final service = _services[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              title: Text(service.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('₹${service.defaultPrice.toStringAsFixed(0)} • ${service.durationMinutes} min'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(LucideIcons.edit3, size: 20, color: AppTheme.secondaryTextColor),
                    onPressed: () => _showServiceSheet(service: service),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.trash2, size: 20, color: Colors.red),
                    onPressed: () => _confirmDeleteService(service),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showServiceSheet({Service? service}) {
    final nameController = TextEditingController(text: service?.name);
    final priceController = TextEditingController(text: service?.defaultPrice.toStringAsFixed(0));
    final durationController = TextEditingController(text: service?.durationMinutes.toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 32,
          top: 32,
          left: 24,
          right: 24,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, -5))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  service == null ? 'Add New Service' : 'Edit Service',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                IconButton(icon: const Icon(LucideIcons.x), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 24),
            _buildInputField(controller: nameController, label: 'Service Name', hint: 'e.g. Premium Haircut', icon: LucideIcons.scissors),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _buildInputField(controller: priceController, label: 'Price (₹)', hint: '500', icon: LucideIcons.banknote, keyboardType: TextInputType.number)),
                const SizedBox(width: 16),
                Expanded(child: _buildInputField(controller: durationController, label: 'Duration (min)', hint: '30', icon: LucideIcons.clock, keyboardType: TextInputType.number)),
              ],
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () async {
                  final auth = Provider.of<AuthProvider>(context, listen: false);
                  final data = {
                    'name': nameController.text,
                    'defaultPrice': double.parse(priceController.text),
                    'durationMinutes': int.parse(durationController.text),
                  };

                  bool success;
                  if (service == null) {
                    success = await _apiService.createService(auth.token!, data);
                  } else {
                    success = await _apiService.updateService(auth.token!, service.id, data);
                  }

                  if (success) {
                    Navigator.pop(context);
                    _refreshServices();
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                child: Text(service == null ? 'Create Service' : 'Save Changes', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({required TextEditingController controller, required String label, required String hint, required IconData icon, TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Theme.of(context).hintColor, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 20, color: AppTheme.accentColor),
            filled: true,
            fillColor: Theme.of(context).scaffoldBackgroundColor,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  void _confirmDeleteService(Service service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Service'),
        content: Text('Are you sure you want to delete "${service.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final auth = Provider.of<AuthProvider>(context, listen: false);
              final success = await _apiService.deleteService(auth.token!, service.id);
              if (success) {
                Navigator.pop(context);
                _refreshServices();
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestsTab() {
    return Consumer<BookingProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) return const Center(child: CircularProgressIndicator());
        final pending = provider.pendingBookings;
        if (pending.isEmpty) return const Center(child: Text('No pending requests'));

        return RefreshIndicator(
          onRefresh: _refreshBookings,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pending.length,
            itemBuilder: (context, index) => BookingCard(
              booking: pending[index],
              showActions: true,
              onStatusUpdate: (status) => _handleStatusUpdate(pending[index].id, status),
              onPaymentReceived: () => _showPaymentSelectionDialog(pending[index].id),
            ),
          ),
        );
      },
    );
  }

  Widget _buildScheduleTab() {
    return Consumer<BookingProvider>(
      builder: (context, provider, _) {
        final confirmed = provider.confirmedBookings;
        final dayBookings = confirmed.where((b) => isSameDay(b.date, _selectedDay)).toList();

        return Column(
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) => setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              }),
              onFormatChanged: (format) => setState(() => _calendarFormat = format),
              eventLoader: (day) => confirmed.where((b) => isSameDay(b.date, day)).toList(),
              calendarStyle: const CalendarStyle(
                selectedDecoration: BoxDecoration(color: AppTheme.accentColor, shape: BoxShape.circle),
                todayDecoration: BoxDecoration(color: Colors.grey, shape: BoxShape.circle),
                markerDecoration: BoxDecoration(color: AppTheme.accentColor, shape: BoxShape.circle),
              ),
            ),
            const Divider(),
            Expanded(
              child: dayBookings.isEmpty
                  ? const Center(child: Text('No appointments'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: dayBookings.length,
                      itemBuilder: (context, index) => BookingCard(
                        booking: dayBookings[index], 
                        showActions: true, // Show actions in schedule too for payment
                        onPaymentReceived: () => _showPaymentSelectionDialog(dayBookings[index].id),
                        onStatusUpdate: (status) => _handleStatusUpdate(dayBookings[index].id, status),
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }
}
