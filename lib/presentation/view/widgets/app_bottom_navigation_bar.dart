import 'package:auto_route/auto_route.dart';
import 'package:family_health/presentation/resources/colors.dart';
import 'package:family_health/presentation/resources/styles.dart';
import 'package:family_health/shared/extension/context.dart';
import 'package:flutter/material.dart';

class AppBottomNavigationItem {
  AppBottomNavigationItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.page,
  });

  final String label;
  final Widget icon;
  final Widget selectedIcon;
  final PageRouteInfo page;
}

class AppBottomNavigationBar extends StatelessWidget {
  const AppBottomNavigationBar({
    Key? key,
    required this.items,
    this.currentIndex = 0,
    this.onTap,
    this.selectedTextStyle,
    this.unSelectedTextStyle,
  }) : super(key: key);

  final List<AppBottomNavigationItem> items;
  final int currentIndex;
  final ValueChanged<int>? onTap;
  final TextStyle? selectedTextStyle;
  final TextStyle? unSelectedTextStyle;

  @override
  Widget build(BuildContext context) {
    final _unSelectedTextStyle = unSelectedTextStyle ??
        AppStyles.bottomNavigation.copyWith(color: AppColors.textSecondary);
    final _selectedTextStyle = selectedTextStyle ??
        _unSelectedTextStyle.copyWith(
          fontWeight: FontWeight.w500,
          color: context.themeOwn().colorSchema?.primary,
        );
    return Container(
      decoration: BoxDecoration(
        boxShadow: const [
          BoxShadow(
            offset: Offset(-5, 5),
            color: Color(0xFFAEAEC0),
            blurRadius: 20,
          ),
        ],
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        child: Material(
          color: context.themeOwn().colorSchema?.whiteText,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: _BottomNavigationTile(
            items: items,
            currentIndex: currentIndex,
            onTap: onTap,
            selectedTextStyle: _selectedTextStyle,
            unSelectedTextStyle: _unSelectedTextStyle,
          ),
        ),
      ),
    );
  }
}

class _BottomNavigationTile extends StatelessWidget {
  const _BottomNavigationTile({
    Key? key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    required this.selectedTextStyle,
    required this.unSelectedTextStyle,
  }) : super(key: key);

  final List<AppBottomNavigationItem> items;
  final int currentIndex;
  final ValueChanged<int>? onTap;
  final TextStyle selectedTextStyle;
  final TextStyle unSelectedTextStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: items
          .asMap()
          .map(
            (i, e) => MapEntry(
              i,
              Expanded(
                child: _Tile(
                  item: e,
                  isSelected: i == currentIndex,
                  onTap: () => onTap?.call(i),
                  selectedTextStyle: selectedTextStyle,
                  unSelectedTextStyle: unSelectedTextStyle,
                ),
              ),
            ),
          )
          .values
          .toList(),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    Key? key,
    required this.item,
    required this.isSelected,
    required this.onTap,
    required this.selectedTextStyle,
    required this.unSelectedTextStyle,
  }) : super(key: key);

  final AppBottomNavigationItem item;
  final bool isSelected;
  final VoidCallback onTap;
  final TextStyle selectedTextStyle;
  final TextStyle unSelectedTextStyle;

  @override
  Widget build(BuildContext context) {
    const activeColor = AppColors.primary;
    const inactiveColor = Color(0xFF94A3B8); // slate-400

    return InkWell(
      onTap: onTap,
      splashColor: activeColor.withValues(alpha: 0.1),
      highlightColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconTheme(
              data: IconThemeData(
                color: isSelected ? activeColor : inactiveColor,
                size: 24,
              ),
              child: isSelected ? item.selectedIcon : item.icon,
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: (isSelected ? selectedTextStyle : unSelectedTextStyle)
                  .copyWith(
                color: isSelected ? activeColor : inactiveColor,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
