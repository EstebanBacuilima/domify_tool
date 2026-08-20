import 'package:domify_tool/bootstrap.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  await bootstrap();
  runApp(const MainApp());
}

/// Composition root: the only widget that names concrete implementations.
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(body: Center(child: Text('DomifyTool'))),
    );
  }
}
