import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/theme/app_colors.dart';
import 'menu_drawer.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onMenuTap;
  final List<Widget>? actions;
  final GlobalKey<ScaffoldState>? scaffoldKey;

  const CustomAppBar({
    super.key,
    required this.title,
    this.onMenuTap,
    this.actions,
    this.scaffoldKey,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surface,
      centerTitle: false,
      titleSpacing: 0,
      automaticallyImplyLeading: false,
      leadingWidth: 56,
      toolbarHeight: 56,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      shadowColor: AppColors.shadow,
      surfaceTintColor: Colors.transparent,
      flexibleSpace: SafeArea(
        bottom: false,
        child: Container(
          height: 56,
          alignment: Alignment.bottomCenter,
          padding: const EdgeInsets.only(bottom: 2.0),
          child: Row(
            children: [
              IconButton(
                onPressed: onMenuTap ?? () {
                  if (scaffoldKey?.currentState != null) {
                    scaffoldKey!.currentState!.openDrawer();
                  } else {
                    _showMenuDialog(context);
                  }
                },
                icon: const Icon(
                  Icons.menu_rounded,
                  color: AppColors.iconPrimary,
                  size: 24,
                ),
                tooltip: 'Menu',
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: SizedBox(
                  width: 180,
                  height: 80,
                  child: SvgPicture.asset(
                    'assets/logo/appbaricon.svg',
                    fit: BoxFit.contain,
                    alignment: Alignment.centerLeft,
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  // Notification functionality will be implemented in future update
                },
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: AppColors.iconPrimary,
                  size: 24,
                ),
                tooltip: 'Notifications',
              ),
              if (actions != null) ...actions!,
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                AppColors.border.withValues(alpha: 0.3),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showMenuDialog(BuildContext context) {
    // Fallback: Show drawer in a drawer-like dialog if scaffold is not available
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        width: double.infinity,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: const MenuDrawer(),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56 + 1);
}
