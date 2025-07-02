import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sarpras_app/screens/cart_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/onboarding.dart';
import '../screens/login.dart';
import '../screens/home.dart';
import '../screens/warehouse/warehouse_list_screen.dart';
import '../screens/category/category_list_screen.dart';
import '../screens/item/item_list_screen.dart';
import '../screens/item/item_detail_screen.dart';
import '../screens/item/item_units_selection_screen.dart';
import '../screens/profile_screen.dart';
import 'package:sarpras_app/screens/request/borrow_request_screen.dart';
import 'package:sarpras_app/screens/request/return_request_screen.dart';
import 'package:sarpras_app/screens/detail/borrow_detail_screen.dart';
import 'package:sarpras_app/screens/detail/return_detail_screen.dart';
import 'package:sarpras_app/screens/history_screen.dart';
import 'package:sarpras_app/screens/active_borrows_screen.dart';

final router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/cart',
      name: 'cart',
      builder: (context, state) => const CartScreen(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final role = extra?['role'] as String? ?? 'siswa';
        return HomeScreen(role: role);
      },
    ),
    GoRoute(
      path: '/warehouses',
      name: 'warehouses',
      builder: (context, state) => const WarehouseListScreen(),
      routes: [
        GoRoute(
          path: ':id',
          name: 'warehouse-detail',
          builder: (context, state) {
            final warehouseId = state.pathParameters['id']!;
            return ItemListScreen(warehouseId: warehouseId, title: 'Barang di Gudang');
          },
        ),
      ],
    ),
    GoRoute(
      path: '/categories',
      name: 'categories',
      builder: (context, state) => const CategoryListScreen(),
      routes: [
        GoRoute(
          path: ':id',
          name: 'category-detail',
          builder: (context, state) {
            final categoryId = state.pathParameters['id']!;
            return ItemListScreen(categoryId: categoryId, title: 'Barang di Kategori');
          },
        ),
      ],
    ),
    GoRoute(
      path: '/borrow-request',
      name: 'borrow-request',
      builder: (context, state) => const BorrowRequestScreen(),
    ),
    GoRoute(
      path: '/return-request',
      name: 'return-request',
      builder: (context, state) {
        final borrowId = state.extra as int?; // Ambil borrowId dari extra
        return ReturnRequestScreen(borrowId: borrowId);
      },
    ),
    GoRoute(
      path: '/active-borrows',
      name: 'active-borrows',
      builder: (context, state) => const ActiveBorrowsScreen(),
    ),
    GoRoute(
      path: '/history',
      name: 'history',
      builder: (context, state) {
        final filter = state.uri.queryParameters['filter'];
        return HistoryScreen(filter: filter);
      },
    ),
    GoRoute(
      path: '/borrow-requests/:borrowId',
      name: 'borrow-detail',
      builder: (context, state) {
        final borrowId = int.parse(state.pathParameters['borrowId']!);
        return BorrowDetailScreen(borrowId: borrowId);
      },
    ),
    GoRoute(
      path: '/return-requests/:returnId',
      name: 'return-detail',
      builder: (context, state) {
        final returnId = int.parse(state.pathParameters['returnId']!);
        return ReturnDetailScreen(returnId: returnId);
      },
    ),
    GoRoute(
      path: '/items',
      name: 'items',
      builder: (context, state) => ItemListScreen(title: 'Semua Barang'),
      routes: [
        GoRoute(
          path: ':id',
          name: 'item-detail',
          builder: (context, state) {
            final itemId = state.pathParameters['id']!;
            return ItemDetailScreen(itemId: itemId);
          },
        ),
      ],
    ),
    GoRoute(
      path: '/item-units-select',
      name: 'item-units-select',
      builder: (context, state) {
        final addItemCallback = state.extra as Function(Map<String, dynamic>)?;
        return ItemUnitSelectionScreen(addItemCallback: addItemCallback);
      },
    ),
    GoRoute(
      path: '/profile',
      name: 'profile',
      builder: (context, state) => const ProfileScreen(),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(body: Center(child: Text('Navigation Error: ${state.error}'))),
);