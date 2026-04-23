import 'package:flutter/material.dart';

import 'router.dart';
import 'theme.dart';

class EtalenteApp extends StatelessWidget {
  EtalenteApp({super.key});

  final _router = buildRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'eTalente',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      routerConfig: _router,
    );
  }
}
