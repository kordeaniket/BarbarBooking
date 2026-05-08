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
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderColor),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 160,
              width: double.infinity,
              color: AppTheme.borderColor,
              child: barber.profilePhoto != null
                  ? Image.network(
                      apiService.getFullImageUrl(barber.profilePhoto),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Center(child: Icon(LucideIcons.scissors, size: 32, color: AppTheme.mutedTextColor)),
                    )
                  : const Center(
                      child: Icon(LucideIcons.scissors, size: 32, color: AppTheme.mutedTextColor),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        barber.shopName,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.borderColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          children: [
                            Icon(LucideIcons.star, size: 14, color: Colors.amber),
                            SizedBox(width: 4),
                            Text(
                              '4.8',
                              style: TextStyle(
                                color: Colors.amber,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    barber.name,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(LucideIcons.mapPin, size: 14, color: AppTheme.secondaryTextColor),
                      const SizedBox(width: 4),
                      Text(
                        '${barber.location.city}, ${barber.location.address}',
                        style: const TextStyle(color: AppTheme.mutedTextColor, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      ...barber.services.take(3).map((service) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.accentColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              service.name,
                              style: const TextStyle(
                                color: AppTheme.accentColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )),
                      if (barber.services.length > 3)
                        Text(
                          '+${barber.services.length - 3} more',
                          style: const TextStyle(color: AppTheme.mutedTextColor, fontSize: 10),
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
