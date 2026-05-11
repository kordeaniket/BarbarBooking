import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
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

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  Future<void> _launchWhatsApp(String phoneNumber, String message) async {
    // Clean phone number (remove +, spaces, etc if needed, but WhatsApp likes +CountryCodeNumber)
    final url = "https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}";
    final Uri launchUri = Uri.parse(url);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri, mode: LaunchMode.externalApplication);
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
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(LucideIcons.user, size: 14, color: AppTheme.secondaryTextColor),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.customerName,
                      style: const TextStyle(color: AppTheme.textColor, fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      booking.customerMobile,
                      style: const TextStyle(color: AppTheme.secondaryTextColor, fontSize: 12),
                    ),
                  ],
                ),
              ),
              // Communication Buttons
              Row(
                children: [
                  _buildCircleButton(
                    icon: LucideIcons.phone,
                    color: Colors.blue,
                    onTap: () => _makePhoneCall(booking.customerMobile),
                  ),
                  const SizedBox(width: 10),
                  _buildCircleButton(
                    icon: LucideIcons.messageSquare,
                    color: Colors.green,
                    onTap: () => _launchWhatsApp(
                      booking.customerMobile, 
                      "Hello ${booking.customerName}, this is regarding your booking for ${booking.serviceName} on ${DateFormat('d MMM').format(booking.date)} at ${booking.startTime}."
                    ),
                  ),
                ],
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
                    onPressed: () {
                      onStatusUpdate?.call('confirmed');
                      // Auto-send WhatsApp confirmation
                      _launchWhatsApp(
                        booking.customerMobile, 
                        "Hello ${booking.customerName}, your booking for ${booking.serviceName} on ${DateFormat('d MMM').format(booking.date)} at ${booking.startTime} has been CONFIRMED. See you soon!"
                      );
                    },
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

  Widget _buildCircleButton({required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: color),
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
