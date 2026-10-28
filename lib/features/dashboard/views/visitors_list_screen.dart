import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vms/core/configs/theme/app_theme.dart';
import 'package:vms/core/widgets/app_header.dart';
import 'package:vms/core/widgets/empty_state_view.dart';
import 'package:vms/core/widgets/visitor_tile.dart';
import 'package:vms/features/dashboard/models/visitor_model.dart';
import 'package:vms/features/dashboard/viewmodels/dashboard_view_model.dart';
import 'package:vms/features/dashboard/views/visitor_detail_screen.dart';
import 'package:vms/features/dashboard/views/visitor_form_screen.dart';

class VisitorsListScreen extends StatefulWidget {
  const VisitorsListScreen({super.key});

  @override
  State<VisitorsListScreen> createState() => _VisitorsListScreenState();
}

class _VisitorsListScreenState extends State<VisitorsListScreen> {
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: const AppHeader(title: 'Dashboard'),
      body: Consumer<DashboardViewModel>(
        builder: (context, vm, _) {
          final visitors = vm.filteredVisitors;
          final totalCount = vm.totalVisitorsCount;

          return Stack(
            children: [
              RefreshIndicator(
                onRefresh: vm.fetchVisitors,
                color: AppTheme.navy,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  children: [
                    // Subheader
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'Visitors',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.navy,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEFF6FF),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '$totalCount Total',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF2563EB),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            const Text(
                              'Sumadhura Front-Desk Registry',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        // Filter icon button
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.tune_rounded,
                              color: Color(0xFF2563EB),
                              size: 20,
                            ),
                            onPressed: () {
                              _showFilterBottomSheet(context, vm);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Search Bar
                    Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: TextField(
                        controller: _searchCtrl,
                        onChanged: vm.setSearchQuery,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.navy,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search by name or mobile number',
                          hintStyle: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Color(0xFF94A3B8),
                            size: 20,
                          ),
                          suffixIcon: _searchCtrl.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.cancel_rounded,
                                    color: Color(0xFF94A3B8),
                                    size: 18,
                                  ),
                                  onPressed: () {
                                    _searchCtrl.clear();
                                    vm.setSearchQuery('');
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Filter Chips Row
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _FilterChip(
                            label: 'All',
                            count: totalCount,
                            isSelected: vm.selectedFilter == 'All',
                            onTap: () => vm.setFilter('All'),
                          ),
                          const SizedBox(width: 8),
                          _FilterChip(
                            label: 'Checked In',
                            count: vm.currentlyCheckedInCount,
                            dotColor: const Color(0xFF10B981),
                            isSelected: vm.selectedFilter == VisitorStatus.checkedIn,
                            onTap: () => vm.setFilter(VisitorStatus.checkedIn),
                          ),
                          const SizedBox(width: 8),
                          _FilterChip(
                            label: 'Registered',
                            count: vm.registeredCount,
                            dotColor: const Color(0xFF2563EB),
                            isSelected: vm.selectedFilter == VisitorStatus.registered,
                            onTap: () => vm.setFilter(VisitorStatus.registered),
                          ),
                          const SizedBox(width: 8),
                          _FilterChip(
                            label: 'Checked Out',
                            count: vm.checkedOutCount,
                            dotColor: const Color(0xFF94A3B8),
                            isSelected: vm.selectedFilter == VisitorStatus.checkedOut,
                            onTap: () => vm.setFilter(VisitorStatus.checkedOut),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Visitors List or Empty State
                    if (visitors.isEmpty)
                      EmptyStateView(
                        searchQuery: vm.searchQuery.isNotEmpty ? vm.searchQuery : null,
                        onClearFilters: () {
                          _searchCtrl.clear();
                          vm.clearFiltersAndSearch();
                        },
                        onWalkIn: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const VisitorFormScreen(),
                            ),
                          );
                        },
                      )
                    else
                      ...visitors.map(
                        (visitor) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: VisitorTile(
                            visitor: visitor,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => VisitorDetailScreen(visitor: visitor),
                                ),
                              );
                            },
                            onEdit: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => VisitorFormScreen(existingVisitor: visitor),
                                ),
                              );
                            },
                            onDelete: () {
                              _showDeleteConfirmDialog(context, vm, visitor);
                            },
                          ),
                        ),
                      ),
                    const SizedBox(height: 80), // Padding for floating action button
                  ],
                ),
              ),

              // Floating Register Button (Yellow Pill)
              Positioned(
                bottom: 16,
                right: 16,
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const VisitorFormScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add, color: AppTheme.navy, size: 20),
                    label: const Text(
                      'Register Visitor',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.navy,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.gold,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      elevation: 4,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDeleteConfirmDialog(
    BuildContext context,
    DashboardViewModel vm,
    Visitor visitor,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Visitor'),
        content: Text('Are you sure you want to remove "${visitor.name}" from the registry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              vm.deleteVisitor(visitor.id);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${visitor.name} deleted'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context, DashboardViewModel vm) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter by Status',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: ['All', 'Checked In', 'Registered', 'Checked Out'].map((filter) {
                final isSelected = vm.selectedFilter == filter;
                return ChoiceChip(
                  label: Text(filter),
                  selected: isSelected,
                  selectedColor: AppTheme.navy,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.navy,
                    fontWeight: FontWeight.w600,
                  ),
                  onSelected: (_) {
                    vm.setFilter(filter);
                    Navigator.of(ctx).pop();
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final int count;
  final Color? dotColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.count,
    this.dotColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.navy : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.navy : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (dotColor != null) ...[
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF475569),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.2)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : const Color(0xFF64748B),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
