import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/barber.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';

class BarberCard extends StatelessWidget {
  final Barber barber;
  final VoidCallback onTap;

  const BarberCard({
    super.key,
    required this.barber,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final apiService = ApiService();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: AppTheme.borderColor),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.borderColor.withOpacity(0.5),
                  ),
                  child: barber.profilePhoto != null
                      ? Image.network(
                          apiService.getFullImageUrl(barber.profilePhoto),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Center(child: Icon(LucideIcons.scissors, size: 40, color: AppTheme.mutedTextColor)),
                        )
                      : const Center(
                          child: Icon(LucideIcons.scissors, size: 40, color: AppTheme.mutedTextColor),
                        ),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(12),
                      backdropFilter: const ColorFilter.mode(Colors.black26, BlendMode.darken),
                    ),
                    child: const Row(
                      children: [
                        Icon(LucideIcons.star, size: 14, color: Colors.amber),
                        SizedBox(width: 4),
                        Text(
                          '4.8',
                          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          barber.shopName,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textColor),
                        ),
                      ),
                      const Icon(LucideIcons.chevronRight, size: 20, color: AppTheme.secondaryTextColor),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(LucideIcons.mapPin, size: 14, color: AppTheme.accentColor),
                      const SizedBox(width: 6),
                      Text(
                        barber.location.city,
                        style: const TextStyle(color: AppTheme.secondaryTextColor, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: AppTheme.borderColor),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Wrap(
                          spacing: 8,
                          children: barber.services.take(2).map((s) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.accentColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(s.name, style: const TextStyle(color: AppTheme.accentColor, fontSize: 11, fontWeight: FontWeight.w600)),
                              )).toList(),
                        ),
                      ),
                      Text(
                        'From ₹${barber.services.isNotEmpty ? barber.services.first.defaultPrice.toStringAsFixed(0) : '0'}',
                        style: const TextStyle(color: AppTheme.textColor, fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
