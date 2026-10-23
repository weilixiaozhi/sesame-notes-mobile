import 'package:flutter/material.dart';

import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';

/// 使用 [AppTokens.grabHandleColor] 的弹层拖拽条。
class SheetGrabHandle extends StatelessWidget {
  const SheetGrabHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppDimens.p8, bottom: AppDimens.p4),
      child: Center(
        child: Container(
          width: AppDimens.p36,
          height: AppDimens.p4,
          decoration: BoxDecoration(
            color: AppTokens.grabHandleColor(context),
            borderRadius: BorderRadius.circular(
              AppDimens.sheetGrabHandleRadius,
            ),
          ),
        ),
      ),
    );
  }
}
