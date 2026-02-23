import 'package:flutter/material.dart';
import 'package:rappels_app/pages/product_demo_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rappels Produits',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFA60000)),
        useMaterial3: true,
      ),
      home: const ProductDemoPage(),
    );
  }
}
