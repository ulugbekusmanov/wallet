import 'package:flutter/cupertino.dart';
import 'package:tbccwallet/ui/styles/styles.dart';

BoxDecoration elevatedContainerDecoration({double? borderRadius, Color? color}) => BoxDecoration(
      color: color ?? AppColors.generalShapesBg,
      boxShadow: [
        BoxShadow(
          blurRadius: 18,
          color: AppColors.shadowColor,
          offset: Offset(0, 13),
        )
      ],
      borderRadius: BorderRadius.circular(borderRadius ?? 20),
    );
