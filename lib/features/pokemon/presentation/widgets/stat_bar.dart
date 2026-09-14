import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';

class StatBar extends StatelessWidget {
  final String label;
  final int value;
  final int max;

  const StatBar({
    super.key,
    required this.label,
    required this.value,
    this.max = 255,
  });

  Color _getStatColor(String name) {
    switch (name.toLowerCase()) {
      case 'hp':
        return AppColors.statHp;
      case 'attack':
        return AppColors.statAttack;
      case 'defense':
        return AppColors.statDefense;
      case 'special-attack':
      case 'sp. atk':
        return AppColors.statSpAtk;
      case 'special-defense':
      case 'sp. def':
        return AppColors.statSpDef;
      case 'speed':
        return AppColors.statSpeed;
      default:
        return AppColors.primaryRed;
    }
  }

  String _formatStatName(String name) {
    switch (name.toLowerCase()) {
      case 'hp':
        return 'HP';
      case 'attack':
        return 'Attack';
      case 'defense':
        return 'Defense';
      case 'special-attack':
        return 'Sp. Atk';
      case 'special-defense':
        return 'Sp. Def';
      case 'speed':
        return 'Speed';
      default:
        return name;
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = (value / max).clamp(0.0, 1.0);
    final statColor = _getStatColor(label);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.h),
      child: Row(
        children: [
          SizedBox(
            width: 80.w,
            child: Text(
              _formatStatName(label),
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
          SizedBox(
            width: 40.w,
            child: Text(
              value.toString(),
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: Stack(
                children: [
                  Container(
                    height: 8.h,
                    color: statColor.withOpacity(0.18),
                  ),
                  FractionallySizedBox(
                    widthFactor: progress,
                    child: Container(
                      height: 8.h,
                      decoration: BoxDecoration(
                        color: statColor,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
