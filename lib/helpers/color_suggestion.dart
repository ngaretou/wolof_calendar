import 'dart:math';
import 'package:flutter/material.dart';

/// This function is a helper utility to suggest theme colors for the app.
/// It analyzes the 12 monthly background images (`assets/images/1.jpg` to `12.jpg`).
/// For each image, it generates a `ColorScheme`.
///
/// It then identifies a "central" color from all the primary, secondary, and
/// tertiary colors found in the 12 schemes. The central color is the one
/// that has the minimum average distance to all other colors in its set.
///
/// The function displays the three suggested colors in a dialog and prints a
/// full ColorScheme constructor to the console.
///
/// To use it, you could call this function from a temporary button, passing in the context.
Future<void> suggestColors(BuildContext context) async {
  // Show a loading indicator
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return const Dialog(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text("Analyzing Images..."),
            ],
          ),
        ),
      );
    },
  );

  List<ColorScheme> schemes = [];
  for (int i = 1; i <= 12; i++) {
    try {
      final provider = AssetImage('assets/images/$i.jpg');
      final scheme = await ColorScheme.fromImageProvider(
        provider: provider,
        brightness: Brightness.light,
      );
      schemes.add(scheme);
    } catch (e) {
      debugPrint('Error generating color scheme for image $i.jpg: $e');
    }
  }

  if (!context.mounted) return;
  Navigator.of(context).pop(); // Close the loading dialog

  if (schemes.isEmpty) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: const Text('Could not generate any color schemes.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    return;
  }

  List<Color> primaryColors = schemes.map((s) => s.primary).toList();
  List<Color> secondaryColors = schemes.map((s) => s.secondary).toList();
  List<Color> tertiaryColors = schemes.map((s) => s.tertiary).toList();

  Color centralPrimary = _findCentralColor(primaryColors);
  Color centralSecondary = _findCentralColor(secondaryColors);
  Color centralTertiary = _findCentralColor(tertiaryColors);

  final String colorSchemeString =
      '''
// --- Suggested ColorScheme ---

  primary: Color.fromARGB(${argbStringFromColor(centralPrimary)}),
  secondary: Color.fromARGB(${argbStringFromColor(centralSecondary)}),
  tertiary: Color.fromARGB(${argbStringFromColor(centralTertiary)}),
  

// ---------------------------''';

  debugPrint(colorSchemeString);

  for (int i = 0; i < 12; i++) {
    debugPrint(
      'Month ${i + 1} : Color.fromARGB(${argbStringFromColor(primaryColors[i])}) ',
    );
  }

  if (!context.mounted) return;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Color Suggestions'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildColorRow('Primary', centralPrimary),
              const SizedBox(height: 16),
              _buildColorRow('Secondary', centralSecondary),
              const SizedBox(height: 16),
              _buildColorRow('Tertiary', centralTertiary),
              const SizedBox(height: 16),
              Text('see console for monthly primary colors'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Close'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

Widget _buildColorRow(String label, Color color) {
  return Row(
    children: [
      Container(
        width: 50,
        height: 50,
        color: color,
        margin: const EdgeInsets.only(right: 16),
      ),
      Expanded(
        child: SelectableText('$label:\nColor(${argbStringFromColor(color)})'),
      ),
    ],
  );
}

Color _findCentralColor(List<Color> colors) {
  if (colors.isEmpty) return Colors.transparent;
  if (colors.length == 1) return colors.first;

  double minAvgDist = double.infinity;
  Color centralColor = colors.first;

  for (int i = 0; i < colors.length; i++) {
    double totalDist = 0;
    for (int j = 0; j < colors.length; j++) {
      if (i == j) continue;
      totalDist += _colorDistance(colors[i], colors[j]);
    }
    double avgDist = totalDist / (colors.length - 1);
    if (avgDist < minAvgDist) {
      minAvgDist = avgDist;
      centralColor = colors[i];
    }
  }
  return centralColor;
}

double _colorDistance(Color c1, Color c2) {
  double r = c1.r - c2.r;
  double g = c1.g - c2.g;
  double b = c1.b - c2.b;
  return sqrt(r * r + g * g + b * b);
}

String argbStringFromColor(Color color) {
  int a = (color.toARGB32() >> 24) & 0xFF;
  int r = (color.toARGB32() >> 16) & 0xFF;
  int g = (color.toARGB32() >> 8) & 0xFF;
  int b = color.toARGB32() & 0xFF;

  // Color colorx = Color.fromARGB(a, r, g, b);
  return '$a, $r, $g, $b';
}
