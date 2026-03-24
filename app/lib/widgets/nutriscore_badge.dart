import 'package:flutter/material.dart';

/// Badge coloré affichant le Nutri-Score d'un produit.
/// Couleurs officielles Yuka : A=vert, B=vert clair, C=jaune, D=orange, E=rouge.
class NutriscoreBadge extends StatelessWidget {
  final String grade; // 'a', 'b', 'c', 'd', 'e' ou ''

  const NutriscoreBadge({super.key, required this.grade});

  static Color colorForGrade(String g) {
    switch (g.toLowerCase()) {
      case 'a': return const Color(0xFF038141);
      case 'b': return const Color(0xFF85BB2F);
      case 'c': return const Color(0xFFFECC02);
      case 'd': return const Color(0xFFEF8200);
      case 'e': return const Color(0xFFE63E11);
      default:  return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final g = grade.isEmpty ? '?' : grade.toUpperCase();
    final color = colorForGrade(grade);
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(
        g,
        style: TextStyle(
          color: grade.toLowerCase() == 'c' ? Colors.black87 : Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}
