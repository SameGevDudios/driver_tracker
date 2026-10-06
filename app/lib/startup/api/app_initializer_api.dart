import 'package:flutter/widgets.dart';

abstract class AppInitializerApi {
  Future<void> initialize();
  Widget createRootWidget();
}
