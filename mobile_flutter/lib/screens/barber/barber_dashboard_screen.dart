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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Barber Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.logOut),
            onPressed: () => Provider.of<AuthProvider>(context, listen: false).logout(),
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        backgroundColor: AppTheme.cardColor,
        selectedItemColor: AppTheme.accentColor,
        unselectedItemColor: AppTheme.secondaryTextColor,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.inbox),
            label: 'Requests',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.calendar),
            label: 'Schedule',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.scissors),
            label: 'Services',
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 2 
        ? FloatingActionButton(
            onPressed: _showAddServiceDialog,
            backgroundColor: AppTheme.accentColor,
            child: const Icon(LucideIcons.plus, color: Colors.white),
          )
        : null,
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0: return _buildRequestsTab();
      case 1: return _buildScheduleTab();
      case 2: return _buildServicesTab();
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
            const SizedBox(height: 8),
            const Text('Tap + to add a service', style: TextStyle(color: AppTheme.mutedTextColor, fontSize: 12)),
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
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const Icon(LucideIcons.scissors, color: AppTheme.accentColor),
              title: Text(service.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${service.durationMinutes} minutes'),
              trailing: Text('₹${service.defaultPrice.toStringAsFixed(0)}', 
                style: const TextStyle(color: AppTheme.accentColor, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          );
        },
      ),
    );
  }

  void _showAddServiceDialog() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final durationController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: const Text('Add New Service', style: TextStyle(color: AppTheme.textColor)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController, 
              style: const TextStyle(color: AppTheme.textColor),
              decoration: const InputDecoration(labelText: 'Service Name (e.g. Haircut)')
            ),
            const SizedBox(height: 12),
            TextField(
              controller: priceController, 
              style: const TextStyle(color: AppTheme.textColor),
              decoration: const InputDecoration(labelText: 'Price (₹)'), 
              keyboardType: TextInputType.number
            ),
            const SizedBox(height: 12),
            TextField(
              controller: durationController, 
              style: const TextStyle(color: AppTheme.textColor),
              decoration: const InputDecoration(labelText: 'Duration (minutes)'), 
              keyboardType: TextInputType.number
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentColor),
            onPressed: () async {
              if (nameController.text.isEmpty || priceController.text.isEmpty || durationController.text.isEmpty) {
                return;
              }
              final auth = Provider.of<AuthProvider>(context, listen: false);
              final success = await _apiService.createService(auth.token!, {
                'name': nameController.text,
                'defaultPrice': double.parse(priceController.text),
                'durationMinutes': int.parse(durationController.text),
              });
              if (success) {
                Navigator.pop(context);
                _refreshServices();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Service added successfully')));
              }
            },
            child: const Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestsTab() {
    return Consumer<BookingProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.accentColor));
        }

        final pending = provider.pendingBookings;

        if (pending.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.checkCircle, size: 64, color: AppTheme.mutedTextColor.withOpacity(0.5)),
                const SizedBox(height: 16),
                const Text('No pending requests', style: TextStyle(color: AppTheme.secondaryTextColor)),
                const SizedBox(height: 8),
                TextButton(onPressed: _refreshBookings, child: const Text('Refresh')),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _refreshBookings,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pending.length,
            itemBuilder: (context, index) {
              final booking = pending[index];
              return BookingCard(
                booking: booking,
                onApprove: () => _handleStatusUpdate(booking.id, 'confirmed'),
                onReject: () => _handleStatusUpdate(booking.id, 'cancelled'),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildScheduleTab() {
    return Consumer<BookingProvider>(
      builder: (context, provider, _) {
        final confirmed = provider.confirmedBookings;
        
        // Filter confirmed bookings for selected day
        final dayBookings = confirmed.where((b) {
          return isSameDay(b.date, _selectedDay);
        }).toList();

        return Column(
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              eventLoader: (day) {
                return confirmed.where((b) => isSameDay(b.date, day)).toList();
              },
              calendarStyle: CalendarStyle(
                selectedDecoration: const BoxDecoration(color: AppTheme.accentColor, shape: BoxShape.circle),
                todayDecoration: BoxDecoration(color: AppTheme.accentColor.withOpacity(0.5), shape: BoxShape.circle),
                markerDecoration: const BoxDecoration(color: AppTheme.accentColor, shape: BoxShape.circle),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: true,
                titleCentered: true,
              ),
            ),
            const Divider(color: AppTheme.borderColor),
            Expanded(
              child: dayBookings.isEmpty
                  ? const Center(child: Text('No appointments for this day', style: TextStyle(color: AppTheme.secondaryTextColor)))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: dayBookings.length,
                      itemBuilder: (context, index) {
                        final booking = dayBookings[index];
                        return BookingCard(
                          booking: booking,
                          showActions: false,
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
