import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/pokemon_type_helper.dart';
import '../../../../core/utils/string_extensions.dart';

class PokemonTypeBadge extends StatelessWidget {
  final String typeName;
  final bool showIcon;
  final double fontSize;
  final EdgeInsetsGeometry? padding;

  const PokemonTypeBadge({
    super.key,
    required this.typeName,
    this.showIcon = true,
    this.fontSize = 11,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.getTypeColor(typeName);
    final icon = PokemonTypeHelper.getTypeIcon(typeName);

    return Container(
      padding: padding ?? EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(icon, size: (fontSize + 3).sp, color: Colors.white),
            SizedBox(width: 4.w),
          ],
          Text(
            typeName.capitalize(),
            style: TextStyle(
              color: Colors.white,
              fontSize: fontSize.sp,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
