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
      body: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildBody()),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        backgroundColor: AppTheme.cardColor,
        selectedItemColor: AppTheme.accentColor,
        unselectedItemColor: AppTheme.secondaryTextColor,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.search),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.calendar),
            label: 'My Bookings',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_selectedIndex == 0) {
      return _isLoading
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
            );
    } else {
      return _buildMyBookingsTab();
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
                showActions: false, // Customer can't approve/reject their own bookings
              );
            },
          ),
        );
      },
    );
  }
// ...

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
      decoration: const BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Find a Barber',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              IconButton(
                icon: const Icon(LucideIcons.logOut, color: AppTheme.secondaryTextColor),
                onPressed: () => Provider.of<AuthProvider>(context, listen: false).logout(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            onChanged: _handleSearch,
            style: const TextStyle(color: AppTheme.textColor),
            decoration: const InputDecoration(
              hintText: 'Search by shop or city',
              prefixIcon: Icon(LucideIcons.search, size: 20),
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
