import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:ticket_system/screens/auth_screen.dart';
import 'package:ticket_system/screens/home_screen.dart';
import 'package:ticket_system/screens/admin_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://cxfspguihoxoedlymdne.supabase.co',  // Replace with your Supabase project URL
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN4ZnNwZ3VpaG94b2VkbHltZG5lIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzE5Mjc5NDAsImV4cCI6MjA0NzUwMzk0MH0.BtpjveWfbZ_5NYKKyI1CH8grrME0_k6cFMc2MiebGBQ',  // Replace with your public anon key
  );
  
  runApp(const ProviderScope(child: MyApp()));
}

final goRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const AuthScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminDashboard(),
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Ticket System',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      routerConfig: goRouter,
    );
  }
}