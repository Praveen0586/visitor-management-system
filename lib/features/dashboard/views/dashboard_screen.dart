import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vms/core/configs/theme/app_theme.dart';
import 'package:vms/core/widgets/app_header.dart';
import 'package:vms/core/widgets/metric_card.dart';
import 'package:vms/core/widgets/visitor_tile.dart';
import 'package:vms/features/dashboard/viewmodels/dashboard_view_model.dart';
import 'package:vms/features/dashboard/views/visitor_detail_screen.dart';
import 'package:vms/features/dashboard/views/visitor_form_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  String _getFormattedCurrentDate() {
    final now = DateTime.now();
    const weekdays = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final weekday = weekdays[now.weekday - 1];
    final month = months[now.month - 1];
    return '$weekday, ${now.day} $month ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: const AppHeader(title: 'Dashboard'),
      body: Consumer<DashboardViewModel>(
        builder: (context, vm, _) {
          return RefreshIndicator(
            onRefresh: vm.fetchVisitors,
            color: AppTheme.navy,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Subheader Row: Title & Gate Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Visitor Management',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.navy,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_outlined,
                                size: 14,
                                color: Color(0xFF64748B),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _getFormattedCurrentDate(),
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF64748B),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      // Gate Pill Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF10B981),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Main Gate • Tower A',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.navy,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Total Visitors Today (Big Card)
                  BigMetricCard(
                    title: 'Total Visitors Today',
                    value: vm.todayVisitorsCount.toString(),
                    subtitle: 'All registered gates',
                    icon: Icons.people_alt_outlined,
                  ),
                  const SizedBox(height: 12),

                  // Checked In & Checked Out Metric Cards
                  Row(
                    children: [
                      Expanded(
                        child: SmallMetricCard(
                          title: 'Currently\nChecked In',
                          value: vm.currentlyCheckedInCount.toString(),
                          icon: Icons.login_rounded,
                          iconBg: const Color(0xFFDCFCE7),
                          iconColor: const Color(0xFF15803D),
                          valueColor: const Color(0xFF16A34A),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SmallMetricCard(
                          title: 'Checked Out\nToday',
                          value: vm.checkedOutTodayCount.toString(),
                          icon: Icons.logout_rounded,
                          iconBg: const Color(0xFFEFF6FF),
                          iconColor: const Color(0xFF2563EB),
                          valueColor: AppTheme.navy,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Action Buttons
                  // 1. REGISTER VISITOR (Gold)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const VisitorFormScreen(),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.person_add_alt_1_outlined,
                        color: AppTheme.navy,
                        size: 20,
                      ),
                      label: const Text(
                        'REGISTER VISITOR',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                          color: AppTheme.navy,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.gold,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 2. SCAN QR CODE (White Outlined)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: () => vm.setNavIndex(2),
                      icon: const Icon(
                        Icons.qr_code_scanner_rounded,
                        color: AppTheme.navy,
                        size: 20,
                      ),
                      label: const Text(
                        'SCAN QR CODE',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                          color: AppTheme.navy,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // View All Visitors Navigation Banner
                  InkWell(
                    onTap: () => vm.setNavIndex(1),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFECEFF4), width: 1.2),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.badge_outlined,
                            color: Color(0xFF64748B),
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'View All Visitors',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.navy,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              vm.totalVisitorsCount.toString(),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF2563EB),
                              ),
                            ),
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            size: 18,
                            color: Color(0xFF64748B),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Recent Visitors Section Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Recent Visitors',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.navy,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                      const Text(
                        'Live updates',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF94A3B8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Recent Visitors Tiles List
                  if (vm.recentVisitors.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      alignment: Alignment.center,
                      child: const Text('No recent visitors'),
                    )
                  else
                    ...vm.recentVisitors.map((visitor) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: VisitorTile(
                          visitor: visitor,
                          isCompact: true,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => VisitorDetailScreen(visitor: visitor),
                              ),
                            );
                          },
                        ),
                      );
                    }),
                  const SizedBox(height: 12),

                  // // Visitor Log Synchronized Banner (Dark Navy)
                  // Container(
                  //   width: double.infinity,
                  //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  //   decoration: BoxDecoration(
                  //     color: AppTheme.navy,
                  //     borderRadius: BorderRadius.circular(12),
                  //   ),
                  //   child: Row(
                  //     children: const [
                  //       Icon(
                  //         Icons.verified_outlined,
                  //         color: AppTheme.gold,
                  //         size: 20,
                  //       ),
                  //       SizedBox(width: 10),
                  //       Expanded(
                  //         child: Text(
                  //           'Visitor Log Synchronized',
                  //           style: TextStyle(
                  //             color: Colors.white,
                  //             fontSize: 13,
                  //             fontWeight: FontWeight.w600,
                  //           ),
                  //         ),
                  //       ),
                  //       Text(
                  //         'Just now',
                  //         style: TextStyle(
                  //           color: Color(0xFF94A3B8),
                  //           fontSize: 12,
                  //           fontWeight: FontWeight.w500,
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
