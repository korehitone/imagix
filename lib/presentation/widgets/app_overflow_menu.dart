import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AppOverflowMenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const AppOverflowMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}

class AppOverflowMenu {
  static void show(
    BuildContext context, {
    required List<AppOverflowMenuItem> items,
  }) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;

    final Offset buttonBottomRight = button.localToGlobal(
      button.size.bottomRight(Offset.zero),
      ancestor: overlay,
    );

    final RelativeRect position = RelativeRect.fromLTRB(
      overlay.size.width,                        // no space on right → forces menu to open leftward
      buttonBottomRight.dy,                      // top = just below the ellipsis
      overlay.size.width - buttonBottomRight.dx, // right margin anchors menu's right edge to ellipsis
      0,
    );

    showMenu(
      context: context,
      position: position,
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      items: items.map((item) {
        return PopupMenuItem(
          onTap: item.onTap,
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(
                item.icon,
                color: AppColors.primary,
                size: 18,
              ),
              const SizedBox(width: 10),
              Text(
                item.label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.black,
                    ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}