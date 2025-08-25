import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../providers/user_prefs.dart';

class GlassCard extends StatelessWidget {
  const GlassCard(
      {super.key,
      this.tintColor, //does have a def value below
      this.borderRadius = 20,
      this.borderWidth = 2,
      this.blur = 5,
      this.borderColor = const Color.fromARGB(49, 171, 170, 170),
      this.showGradient = true,
      this.child});

  final Color? tintColor;
  final double borderRadius;
  final double borderWidth;
  final double blur;
  final Color borderColor;
  final bool showGradient;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    UserPrefs userPrefs =
        Provider.of<UserPrefs>(context, listen: true).userPrefs;

    late Color colorToShow;

    bool? showGradientSet = showGradient;
    //but...
    if (!userPrefs.glassEffects!) {
      showGradientSet = false;
    }

    tintColor == null
        ? colorToShow = Theme.of(context)
            .cardColor
            .withAlpha(userPrefs.glassEffects! ? 153 : 255)
        : colorToShow =
            tintColor!.withAlpha(userPrefs.glassEffects! ? 128 : 255);

    return ClipRRect(
      clipBehavior: Clip.hardEdge,
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: userPrefs.glassEffects!
            ? ImageFilter.blur(sigmaX: blur, sigmaY: blur)
            : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
        child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: borderColor,
                width: borderWidth,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  //optional params have to be const - here we need a non-const optional param
                  colorToShow,
                  showGradientSet
                      ? Theme.of(context)
                          .cardColor
                          .withAlpha(userPrefs.glassEffects! ? 26 : 255)
                      : colorToShow,
                  showGradientSet
                      ? Colors.grey
                          .withAlpha(userPrefs.glassEffects! ? 77 : 255)
                      : colorToShow,
                ],
                stops: const [
                  0.4,
                  .7,
                  1,
                ],
              ),
            ),
            child: child),
      ),
    );
  }
}
