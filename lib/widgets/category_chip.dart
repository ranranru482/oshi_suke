import 'package:flutter/material.dart';

import '../models/category.dart';
import '../theme/app_theme.dart';

/// カテゴリを表示するチップ（小さめのピル）。
class CategoryChip extends StatelessWidget {
  const CategoryChip({
    super.key,
    required this.category,
    this.dense = false,
  });

  final OshiCategory category;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final padH = dense ? 8.0 : 10.0;
    final padV = dense ? 3.0 : 4.0;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: padH, vertical: padV),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            category.icon,
            size: dense ? 12 : 14,
            color: AppColors.primaryDark,
          ),
          const SizedBox(width: 4),
          Text(
            category.label,
            style: TextStyle(
              color: AppColors.primaryDark,
              fontSize: dense ? 11 : 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
