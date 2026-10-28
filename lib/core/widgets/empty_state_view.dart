import 'package:flutter/material.dart';
import 'package:vms/core/configs/theme/app_theme.dart';

class EmptyStateView extends StatelessWidget {
  final String? searchQuery;
  final VoidCallback onClearFilters;
  final VoidCallback onWalkIn;

  const EmptyStateView({
    super.key,
    this.searchQuery,
    required this.onClearFilters,
    required this.onWalkIn,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Main Empty State Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFECEFF4), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                offset: const Offset(0, 4),
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Circular illustration with badge
              Stack(
                alignment: Alignment.topRight,
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFDBEAFE), width: 2),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.person_search_outlined,
                        size: 44,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 2,
                    right: 2,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: AppTheme.gold,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.search,
                          size: 14,
                          color: AppTheme.navy,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              if (searchQuery != null && searchQuery!.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Query: "$searchQuery"',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              const Text(
                'No visitors found',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.navy,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'There are no visitors matching your search or filter criteria for today. Check the spelling or register a new visitor.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 22),
              // Clear Filters & Search Button
              SizedBox(
                width: double.infinity,
                height: 46,
                child: OutlinedButton.icon(
                  onPressed: onClearFilters,
                  icon: const Icon(Icons.filter_alt_off_outlined, size: 18),
                  label: const Text(
                    'Clear Filters & Search',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.navy,
                    backgroundColor: const Color(0xFFF1F5F9),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Direct Visitor Walk-in Button
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton.icon(
                  onPressed: onWalkIn,
                  icon: const Icon(Icons.person_add_alt_1_outlined, size: 18, color: Colors.white),
                  label: const Text(
                    'Direct Visitor Walk-in',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.navy,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // // Pre-Approved Deliveries Info Card
        // Container(
        //   width: double.infinity,
        //   padding: const EdgeInsets.all(16),
        //   decoration: BoxDecoration(
        //     color: const Color(0xFFF0FDF4),
        //     borderRadius: BorderRadius.circular(12),
        //     border: Border.all(color: const Color(0xFFDCFCE7), width: 1),
        //   ),
        //   child: Row(
        //     crossAxisAlignment: CrossAxisAlignment.start,
        //     children: [
        //       Container(
        //         width: 32,
        //         height: 32,
        //         decoration: BoxDecoration(
        //           color: const Color(0xFFDCFCE7),
        //           borderRadius: BorderRadius.circular(8),
        //         ),
        //         child: const Icon(
        //           Icons.verified_user_outlined,
        //           color: Color(0xFF15803D),
        //           size: 18,
        //         ),
        //       ),
        //       const SizedBox(width: 12),
        //       // const Expanded(
        //       //   child: Column(
        //       //     crossAxisAlignment: CrossAxisAlignment.start,
        //       //     children: [
        //       //       Text(
        //       //         'Pre-Approved Deliveries',
        //       //         style: TextStyle(
        //       //           fontSize: 13,
        //       //           fontWeight: FontWeight.w700,
        //       //           color: Color(0xFF14532D),
        //       //         ),
        //       //       ),
        //       //       SizedBox(height: 2),
        //       //       Text(
        //       //         'Resident entry codes can be verified instantly by scanning their pass via the bottom Scan action.',
        //       //         style: TextStyle(
        //       //           fontSize: 12,
        //       //           color: Color(0xFF166534),
        //       //           height: 1.3,
        //       //         ),
        //       //       ),
        //       //     ],
        //       //   ),
        //       // ),
        //     ],
        //   ),
        // ),
      ],
    );
  }
}
