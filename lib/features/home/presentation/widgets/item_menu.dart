import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ultrared/config/menu/menu_item.dart';
import 'package:ultrared/features/shared/utils/responsive.dart';

class ItemMenu extends StatelessWidget {
  final MenuItem menuItem;
  const ItemMenu({
    super.key,
    required this.size,
    required this.menuItem,
  });

  final Responsive size;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final radius = size.w(16);

    return SizedBox(
      width: size.iScreen(14.0),
      height: size.iScreen(14.0),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: size.h(4)),
        child: Material(
          color: Colors.white,
          elevation: 0,
          borderRadius: BorderRadius.circular(radius),
          child: InkWell(
            onTap: () {
              context.push(menuItem.link);
            },
            borderRadius: BorderRadius.circular(radius),
            splashColor: colors.primary.withValues(alpha: 0.08),
            highlightColor: colors.primary.withValues(alpha: 0.04),
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius),
                color: Colors.white,
                border: Border.all(
                  color: colors.primary,
                  width: 1.2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    menuItem.icon,
                    height: size.iScreen(5),
                    color: colors.primary,
                  ),
                  SizedBox(height: size.h(8)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: size.w(6)),
                    child: Text(
                      menuItem.title,
                      style: TextStyle(
                        fontSize: size.iScreen(1.6),
                        fontWeight: FontWeight.w600,
                        color: colors.onSurface,
                        height: 1.1,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
