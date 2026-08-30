import 'package:flutter/material.dart';

void main() {
  runApp(const SkyPlanApp());
}

class SkyPlanApp extends StatelessWidget {
  const SkyPlanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SkyPlan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SkyPlan')),
      body: const Center(child: Text('Hello SkyPlan')),
    );
  }
}
