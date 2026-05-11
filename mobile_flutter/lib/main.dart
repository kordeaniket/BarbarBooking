import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/booking_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/customer/home_screen.dart';
import 'screens/barber/barber_dashboard_screen.dart';
import 'screens/auth/login_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const BarberBookingApp(),
    ),
  );
}

class BarberBookingApp extends StatelessWidget {
  const BarberBookingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Barber Booking',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          home: Consumer<AuthProvider>(
            builder: (ctx, auth, _) {
              if (auth.isAuthenticated) {
                return auth.role == 'barber' 
                  ? const BarberDashboardScreen() 
                  : const CustomerHomeScreen();
              }
              return FutureBuilder(
                future: auth.tryAutoLogin(),
                builder: (ctx, snapshot) => 
                  snapshot.connectionState == ConnectionState.waiting 
                    ? const Scaffold(body: Center(child: CircularProgressIndicator(color: AppTheme.accentColor)))
                    : const LoginScreen(),
              );
            },
          ),
        );
      },
    );
  }
}
