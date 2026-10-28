import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vms/core/configs/theme/app_theme.dart';
import 'package:vms/core/utils/share_service.dart';
import 'package:vms/core/widgets/category_badge.dart';
import 'package:vms/core/widgets/qr_pass_card.dart';
import 'package:vms/core/widgets/status_chip.dart';
import 'package:vms/features/dashboard/models/visitor_model.dart';
import 'package:vms/features/dashboard/viewmodels/dashboard_view_model.dart';
import 'package:vms/features/dashboard/views/visitor_form_screen.dart';

class VisitorDetailScreen extends StatelessWidget {
  final Visitor visitor;
  final GlobalKey _qrKey = GlobalKey();

  VisitorDetailScreen({super.key, required this.visitor});

  String _formatDateTime(DateTime date) {
    final now = DateTime.now();
    final isToday = now.year == date.year &&
        now.month == date.month &&
        now.day == date.day;

    final hour = date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final formattedHour = hour == 0
        ? 12
        : hour > 12
            ? hour - 12
            : hour;
    final timeStr = '$formattedHour:$minute $period';

    if (isToday) {
      return timeStr;
    }

    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]}, $timeStr';
  }

  Future<void> _launchDialer(BuildContext context, String mobile) async {
    final cleanNumber = mobile.replaceAll(RegExp(r'\s+|-'), '');
    final Uri phoneUri = Uri(scheme: 'tel', path: cleanNumber);
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Cannot open phone dialer for $cleanNumber'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open phone dialer: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardViewModel>(
      builder: (context, vm, _) {
        // Find updated visitor instance in state
        final current = vm.allVisitors.firstWhere(
          (v) => v.id == visitor.id,
          orElse: () => visitor,
        );

        return Scaffold(
          backgroundColor: const Color(0xFFF7F8FA),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                // Top Status Indicator Tabs
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _DetailStatusTab(
                      label: 'Registered',
                      dotColor: const Color(0xFF2563EB),
                      isActive: current.isRegistered,
                    ),
                    _DetailStatusTab(
                      label: 'Checked In',
                      dotColor: const Color(0xFF10B981),
                      isActive: current.isCheckedIn,
                    ),
                    _DetailStatusTab(
                      label: 'Checked Out',
                      dotColor: const Color(0xFF64748B),
                      isActive: current.isCheckedOut,
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Subheader: Back Button + Gate Info + Actions
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: AppTheme.navy),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'GATE 01 • NORTH',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF64748B),
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          'Visitor Details',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.navy,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: Color(0xFF475569)),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => VisitorFormScreen(existingVisitor: current),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.share_outlined, color: Color(0xFF475569)),
                      onPressed: () {
                        ShareService.sharePassWithQr(
                          qrKey: _qrKey,
                          visitor: current,
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Top Detail Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFECEFF4), width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        offset: const Offset(0, 2),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar + Name + Verified Badge + Status
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 26,
                            backgroundColor: const Color(0xFFDCEAFE),
                            child: Text(
                              current.initials,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1E40AF),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        current.name,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                          color: AppTheme.navy,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Icon(
                                      Icons.check_circle_rounded,
                                      color: Color(0xFF10B981),
                                      size: 16,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'Pass #${current.formattedPassNumber}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF64748B),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          StatusChip(status: current.status),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Mobile Contact Box
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.phone_android, color: Color(0xFF2563EB), size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '+91 ${current.mobile}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.navy,
                                    ),
                                  ),
                                  const Text(
                                    'Mobile Contact',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.call_outlined, color: AppTheme.navy, size: 20),
                              onPressed: () => _launchDialer(context, current.mobile),
                              tooltip: 'Call Visitor',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // 2 Columns: Project & Visitor Category
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: const [
                                    Icon(Icons.business_outlined, size: 14, color: Color(0xFF64748B)),
                                    SizedBox(width: 4),
                                    Text('Project', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  current.project,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.navy,
                                  ),
                                ),
                                Text(
                                  current.unit ?? 'Tower A • 1402',
                                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: const [
                                    Icon(Icons.badge_outlined, size: 14, color: Color(0xFF64748B)),
                                    SizedBox(width: 4),
                                    Text('Visitor Category', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                CategoryBadge(category: current.visitorType),
                                const SizedBox(height: 2),
                                Text(
                                  current.purpose,
                                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(color: Color(0xFFF1F5F9)),
                      const SizedBox(height: 8),

                      // Email Address & Pre-Registration Time
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Email Address', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                              const SizedBox(height: 2),
                              Text(
                                current.email ?? 'Not provided',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF475569),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('Pre-Registration', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                              const SizedBox(height: 2),
                              Text(
                                current.createdDate != null
                                    ? _formatDateTime(current.createdDate!)
                                    : 'Today • 09:15 AM',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF475569),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // EXPRESS PASS (QR Code) Card
                QrPassCard(
                  qrKey: _qrKey,
                  visitor: current,
                  onShare: () {
                    ShareService.sharePassWithQr(
                      qrKey: _qrKey,
                      visitor: current,
                    );
                  },
                  onPrint: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Sent print job to thermal desk printer'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // GATE ACCESS LOG Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFECEFF4), width: 1.2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Row(
                            children: [
                              Icon(Icons.sensor_door_outlined, size: 16, color: AppTheme.navy),
                              SizedBox(width: 6),
                              Text(
                                'GATE ACCESS LOG',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.navy,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'Lane: North Barrier',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: const [
                                      Icon(Icons.login, size: 16, color: Color(0xFF10B981)),
                                      SizedBox(width: 6),
                                      Text('Check-In', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    current.checkInDate != null
                                        ? _formatDateTime(current.checkInDate!)
                                        : (current.isCheckedIn || current.isCheckedOut
                                            ? 'Completed'
                                            : 'Not yet'),
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.navy),
                                  ),
                                  Text(
                                    current.checkInDate != null
                                        ? 'Gate 01 • Main Entry'
                                        : (current.isCheckedIn || current.isCheckedOut
                                            ? 'Logged at Gate 01'
                                            : 'Pending arrival'),
                                    style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: const [
                                      Icon(Icons.logout, size: 16, color: Color(0xFF2563EB)),
                                      SizedBox(width: 6),
                                      Text('Check-Out', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    current.checkOutDate != null
                                        ? _formatDateTime(current.checkOutDate!)
                                        : (current.isCheckedOut ? 'Completed' : 'Not yet'),
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.navy),
                                  ),
                                  Text(
                                    current.checkOutDate != null
                                        ? 'Gate 01 • North Barrier'
                                        : (current.isCheckedOut
                                            ? 'Cleared barrier'
                                            : 'Expected < 2 hrs'),
                                    style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.location_on_outlined, color: Color(0xFFB45309), size: 18),
                            SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Designated Entry: Main Gate • Tower A',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF92400E),
                                    ),
                                  ),
                                  Text(
                                    'Assigned Escort: Concierge Desk 02',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFFB45309),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
        bottomNavigationBar: (current.canCheckIn || current.canCheckOut)
            ? Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      offset: const Offset(0, -3),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: _buildBottomAction(current, vm, context)!,
                ),
              )
            : null,
      );
    },
  );
}

Widget? _buildBottomAction(Visitor current, DashboardViewModel vm, BuildContext context) {
  if (current.canCheckIn) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: () {
          vm.checkInVisitor(current.id);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${current.name} checked in successfully!'),
              backgroundColor: const Color(0xFF15803D),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        icon: const Icon(Icons.person_pin_circle_outlined, color: Colors.white, size: 20),
        label: const Text(
          'CHECK IN VISITOR',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF16A34A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
    );
  } else if (current.canCheckOut) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: () {
          vm.checkOutVisitor(current.id);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${current.name} checked out successfully!'),
              backgroundColor: AppTheme.navy,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        icon: const Icon(Icons.logout, color: Colors.white, size: 20),
        label: const Text(
          'CHECK OUT VISITOR',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFDC2626),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
    );
  }
  return null;
}
}

class _DetailStatusTab extends StatelessWidget {
  final String label;
  final Color dotColor;
  final bool isActive;

  const _DetailStatusTab({
    required this.label,
    required this.dotColor,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? const Color(0xFFCBD5E1) : Colors.transparent,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: isActive ? AppTheme.navy : const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }
}
