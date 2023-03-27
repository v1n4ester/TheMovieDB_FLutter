import 'package:flutter/material.dart';
import 'package:movie_list/ui/Theme/app_colors.dart';

abstract class AppButtonStyle {
  static final ButtonStyle linkButton = ButtonStyle(
    shape: MaterialStateProperty.all(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    ),
    padding: MaterialStateProperty.all(
      const EdgeInsets.symmetric(
        horizontal: 19.2,
        vertical: 6,
      ),
    ),
    backgroundColor: MaterialStateProperty.all(
      AppColors.mainDartBlue,
    ),
  );

  static const TextStyle linkButtonText = TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w700,
      fontFamily: 'Source Sans Pro');
}
