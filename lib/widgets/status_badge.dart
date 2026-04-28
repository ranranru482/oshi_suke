import 'package:flutter/material.dart';

import '../models/event_status.dart';

/// イベントステータスを表示するカラーバッジ。
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.status,
    this.dense = false,
    this.solid = false,
  });

  final EventStatus status;
  final bool dense;

  /// true: 濃い背景＋白文字 / false: ライト背景＋濃文字
  final bool solid;

  @override
  Widget build(BuildContext context) {
    final color = status.color;
    final fg = solid ? Colors.white : color;
    final bg = solid ? color : color.withValues(alpha: 0.12);
    final padH = dense ? 8.0 : 10.0;
    final padV = dense ? 3.0 : 5.0;
    final fontSize = dense ? 10.0 : 11.5;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: padH, vertical: padV),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: dense ? 11 : 13, color: fg),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: TextStyle(
              color: fg,
              fontWeight: FontWeight.w800,
              fontSize: fontSize,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
