import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../models/barber.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/barber_card.dart';
import '../../widgets/booking_card.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../common/profile_screen.dart';
import 'barber_details_screen.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  final ApiService _apiService = ApiService();
  List<Barber> _barbers = [];
  List<Barber> _filteredBarbers = [];
  bool _isLoading = true;
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadBarbers();
    _refreshBookings();
  }

  Future<void> _loadBarbers() async {
    setState(() => _isLoading = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final barbers = await _apiService.fetchBarbers(auth.token ?? '');
    setState(() {
      _barbers = barbers;
      _filteredBarbers = barbers;
      _isLoading = false;
    });
  }

  Future<void> _refreshBookings() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.token != null) {
      await Provider.of<BookingProvider>(context, listen: false).fetchBookings(auth.token!);
    }
  }

  void _handleSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredBarbers = _barbers;
      } else {
        _filteredBarbers = _barbers.where((barber) {
          final shopName = barber.shopName.toLowerCase();
          final city = barber.location.city.toLowerCase();
          final searchLower = query.toLowerCase();
          return shopName.contains(searchLower) || city.contains(searchLower);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.search),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.calendar),
            label: 'My Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.user),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppTheme.accentColor))
                  : RefreshIndicator(
                      onRefresh: _loadBarbers,
                      color: AppTheme.accentColor,
                      child: _filteredBarbers.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                              padding: const EdgeInsets.all(20),
                              itemCount: _filteredBarbers.length,
                              itemBuilder: (context, index) {
                                return BarberCard(
                                  barber: _filteredBarbers[index],
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => BarberDetailsScreen(barber: _filteredBarbers[index]),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                    ),
            ),
          ],
        );
      case 1:
        return Scaffold(
          appBar: AppBar(title: const Text('My Bookings')),
          body: _buildMyBookingsTab(),
        );
      case 2:
        return const ProfileScreen();
      default:
        return const Center(child: Text('Coming Soon'));
    }
  }

  Widget _buildMyBookingsTab() {
    return Consumer<BookingProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.accentColor));
        }

        final bookings = provider.bookings;

        if (bookings.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.calendar, size: 64, color: AppTheme.mutedTextColor.withOpacity(0.5)),
                const SizedBox(height: 16),
                const Text('No bookings found', style: TextStyle(color: AppTheme.secondaryTextColor)),
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
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              return BookingCard(
                booking: booking,
                showActions: false,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Welcome,', style: TextStyle(color: Theme.of(context).hintColor, fontSize: 14)),
          Text(auth.name ?? 'Guest', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          TextField(
            controller: _searchController,
            onChanged: _handleSearch,
            decoration: InputDecoration(
              hintText: 'Search shops, services or cities',
              prefixIcon: const Icon(LucideIcons.search, size: 20, color: AppTheme.accentColor),
              filled: true,
              fillColor: Theme.of(context).scaffoldBackgroundColor,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        'No barbers found in this area',
        style: TextStyle(color: AppTheme.mutedTextColor, fontSize: 16),
      ),
    );
  }
}
