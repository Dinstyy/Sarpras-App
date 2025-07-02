import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider; // Alias to avoid conflict with Riverpod's Provider
import '../../providers/cart_provider.dart';
import './routes/router.dart'; // Import router.dart

void main() {
  runApp(
    provider.MultiProvider( // Use provider alias for MultiProvider
      providers: [
        provider.ChangeNotifierProvider(create: (_) => CartProvider()), // Use provider alias
        // Add other providers if needed
      ],
      child: const ProviderScope(child: MyApp()),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Sisfo Sarpras',
      theme: ThemeData.dark(),
      routerConfig: router,
    );
  }
}