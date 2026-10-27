import 'package:flutter/material.dart';
import 'package:vms/core/configs/theme/app_theme.dart';

/// Top bar with Shield icon, Title, Notification Bell, and Profile Avatar.
class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final VoidCallback? onBack;
  final List<Widget>? actions;

  const AppHeader({
    super.key,
    this.title = 'Dashboard',
    this.showBackButton = false,
    this.onBack,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      leadingWidth: showBackButton ? 56 : 64,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: AppTheme.navy),
              onPressed: onBack ?? () => Navigator.of(context).maybePop(),
            )
          : Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Center(
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppTheme.navy,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.shield_outlined,
                      color: AppTheme.gold,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ),
      title: Text(
        title,
        style: const TextStyle(
          color: AppTheme.navy,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
      ),
      // actions: actions ??
      //     [
      //       // Notification Bell with unread indicator
      //       Stack(
      //         alignment: Alignment.center,
      //         children: [
      //           IconButton(
      //             icon: const Icon(Icons.notifications_none_outlined,
      //                 color: AppTheme.navy, size: 26),
      //             onPressed: () {
      //               ScaffoldMessenger.of(context).showSnackBar(
      //                 const SnackBar(
      //                   content: Text('No new notifications'),
      //                   duration: Duration(seconds: 1),
      //                 ),
      //               );
      //             },
      //           ),
      //           Positioned(
      //             top: 12,
      //             right: 12,
      //             child: Container(
      //               width: 7,
      //               height: 7,
      //               decoration: const BoxDecoration(
      //                 color: Colors.red,
      //                 shape: BoxShape.circle,
      //               ),
      //             ),
      //           ),
      //         ],
      //       ),
      //       // Profile Avatar
      //       Padding(
      //         padding: const EdgeInsets.only(right: 16, left: 4),
      //         child: CircleAvatar(
      //           radius: 17,
      //           backgroundColor: AppTheme.navy,
      //           child: const Icon(
      //             Icons.person,
      //             size: 20,
      //             color: Colors.white,
      //           ),
      //         ),
      //       ),
      //     ],
    );
  }
}
