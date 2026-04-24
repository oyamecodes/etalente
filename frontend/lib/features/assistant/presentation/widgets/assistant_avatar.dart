import 'package:flutter/material.dart';

import '../../../../app/theme.dart';

/// Yellow circular avatar used in the assistant card, header and
/// transcript bubbles. Optionally renders the green "online" dot in the
/// bottom-right corner (used in the popup header).
class AssistantAvatar extends StatelessWidget {
  const AssistantAvatar({
    super.key,
    required this.size,
    required this.iconSize,
    this.showOnlineDot = false,
  });

  final double size;
  final double iconSize;
  final bool showOnlineDot;

  @override
  Widget build(BuildContext context) {
    final avatar = Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.accentYellow,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Icon(Icons.smart_toy_outlined,
          size: iconSize, color: AppColors.onSurface),
    );
    if (!showOnlineDot) return avatar;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(child: avatar),
          Positioned(
            right: -1,
            bottom: -1,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: const Color(0xFF2BB673),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.accentYellow, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
