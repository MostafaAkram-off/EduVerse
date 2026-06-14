import 'package:flutter/material.dart';
import 'package:edu_verse/core/theme/app_text_theme.dart';
import 'package:edu_verse/core/theme/theme_ext.dart';

/// Sliver app bar used at the top of CustomScrollView screens.
class AppTopBar extends StatelessWidget {
  const AppTopBar({
    super.key,
    this.greeting,
    this.name,
    this.title,
    this.subtitle,
    this.actions,
    this.showBack = false,
    this.pinned = true,
    this.floating = false,
  });

  final String? greeting;
  final String? name;
  final String? title;
  final String? subtitle;
  final List<Widget>? actions;
  final bool showBack;
  final bool pinned;
  final bool floating;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: pinned,
      floating: floating,
      backgroundColor: context.bg,
      automaticallyImplyLeading: showBack,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleSpacing: 20,
      title: _title(),
      actions: actions != null
          ? [...actions!, const SizedBox(width: 8)]
          : null,
    );
  }

  Widget _title() {
    if (greeting != null && name != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(greeting!, style: AppTextTheme.greeting),
          Text(name!, style: AppTextTheme.greetingName),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title ?? '', style: AppTextTheme.screenTitle),
        if (subtitle != null)
          Text(subtitle!,
              style: AppTextTheme.appBarSubtitle),
      ],
    );
  }
}

/// Inline (non-sliver) top bar for non-scrollable screens.
class InlineTopBar extends StatelessWidget implements PreferredSizeWidget {
  const InlineTopBar({
    super.key,
    this.title,
    this.subtitle,
    this.actions,
    this.showBack = true,
  });

  final String? title;
  final String? subtitle;
  final List<Widget>? actions;
  final bool showBack;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: context.bg,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: showBack,
      titleSpacing: showBack ? 0 : 20,
      title: subtitle != null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title ?? '', style: AppTextTheme.appBarTitle),
                Text(subtitle!, style: AppTextTheme.appBarSubtitle),
              ],
            )
          : Text(title ?? '', style: AppTextTheme.appBarTitle),
      actions: actions,
    );
  }
}
