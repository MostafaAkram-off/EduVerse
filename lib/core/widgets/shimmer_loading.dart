import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:edu_verse/core/theme/app_colors.dart';

Color _shimmerBase(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? AppColors.shimmerBaseDark
        : AppColors.shimmerBase;

Color _shimmerHighlight(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? AppColors.shimmerHighlightDark
        : AppColors.shimmerHighlight;

class ShimmerBox extends StatelessWidget {
  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 12,
  });

  final double width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final base = _shimmerBase(context);
    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: _shimmerHighlight(context),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: base,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class ShimmerCard extends StatelessWidget {
  const ShimmerCard({super.key, this.height = 100});

  final double height;

  @override
  Widget build(BuildContext context) {
    final base = _shimmerBase(context);
    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: _shimmerHighlight(context),
      child: Container(
        height: height,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: base,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

class ShimmerList extends StatelessWidget {
  const ShimmerList({super.key, this.itemCount = 4, this.itemHeight = 88});

  final int itemCount;
  final double itemHeight;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
          itemCount, (_) => ShimmerCard(height: itemHeight)),
    );
  }
}

class ShimmerGrid extends StatelessWidget {
  const ShimmerGrid(
      {super.key, this.crossAxisCount = 2, this.itemCount = 4});

  final int crossAxisCount;
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final base = _shimmerBase(context);
    final highlight = _shimmerHighlight(context);
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.0,
      ),
      itemCount: itemCount,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: base,
        highlightColor: highlight,
        child: Container(
          decoration: BoxDecoration(
            color: base,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
