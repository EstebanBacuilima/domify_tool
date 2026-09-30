import 'package:domify_tool/app.dart';
import 'package:domify_tool/bootstrap.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  await bootstrap();
  runApp(const DomifyApp());
}
