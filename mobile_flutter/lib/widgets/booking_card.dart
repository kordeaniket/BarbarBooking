import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../models/booking.dart';
import '../theme/app_theme.dart';

class BookingCard extends StatelessWidget {
  final Booking booking;
  final bool showActions;
  final Function(String)? onStatusUpdate;

  const BookingCard({
    super.key,
    required this.booking,
    this.showActions = false,
    this.onStatusUpdate,
  });

  Color _getStatusColor() {
    switch (booking.status.toLowerCase()) {
      case 'pending': return Colors.orange;
      case 'confirmed': return Colors.green;
      case 'completed': return AppTheme.accentColor;
      case 'cancelled':
      case 'rejected': return Colors.red;
      default: return AppTheme.secondaryTextColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  booking.status.toUpperCase(),
                  style: TextStyle(color: _getStatusColor(), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
              ),
              Text(
                '₹${booking.servicePrice.toStringAsFixed(0)}',
                style: const TextStyle(color: AppTheme.textColor, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            booking.serviceName,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textColor),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(LucideIcons.user, size: 14, color: AppTheme.secondaryTextColor),
              const SizedBox(width: 6),
              Text(
                booking.customerName ?? 'No Name',
                style: const TextStyle(color: AppTheme.secondaryTextColor, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppTheme.borderColor),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildMetaInfo(LucideIcons.calendar, DateFormat('d MMM, yyyy').format(booking.date)),
              const SizedBox(width: 20),
              _buildMetaInfo(LucideIcons.clock, booking.startTime),
            ],
          ),
          if (showActions && booking.status == 'pending') ...[
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => onStatusUpdate?.call('rejected'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.withOpacity(0.1),
                      foregroundColor: Colors.red,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Reject', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => onStatusUpdate?.call('confirmed'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Approve', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetaInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.accentColor),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(color: AppTheme.textColor, fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
