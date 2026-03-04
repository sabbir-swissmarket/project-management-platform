import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/utils/global_keys.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = createRouter(ref);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      key: navigatorKey,
      routerConfig: router,
      theme: ThemeData(useMaterial3: true, primarySwatch: Colors.blue),
    );
  }
}
