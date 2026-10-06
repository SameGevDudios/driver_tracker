import 'package:flutter/material.dart';
import 'startup/impl/app_initializer_impl.dart';

void main() async {
  final initializer = AppInitializerImpl();
  await initializer.initialize();
  runApp(initializer.createRootWidget());
}
