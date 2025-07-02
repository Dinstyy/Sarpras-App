import 'package:sarpras_app/models/item_unit.dart';
import 'package:sarpras_app/services/dio_service.dart';

class CartService {
  final DioService _dioService = DioService();

  Future<void> submitBorrowRequest({
    required String borrowDateExpected,
    required String returnDateExpected,
    required String reason,
    String? notes,
    required List<Map<String, dynamic>> items,
  }) async {
    final data = {
      'borrow_date_expected': borrowDateExpected,
      'return_date_expected': returnDateExpected,
      'reason': reason,
      'notes': notes,
      'items': items,
    };
    await _dioService.post(endpoint: '/borrow-requests', data: data);
  }

  Future<List<ItemUnit>> getCart() async {
    try {
      final response = await _dioService.get(endpoint: '/user/cart');
      final List<dynamic> items = response['items'];
      return items.map((item) => ItemUnit.fromJson(item)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveCart(List<ItemUnit> items) async {
    try {
      final data = {
        'items': items.map((item) => item.toJson()).toList(),
      };
      await _dioService.post(endpoint: '/user/cart', data: data);
    } catch (e) {
      print('Failed to save cart: $e');
    }
  }
}