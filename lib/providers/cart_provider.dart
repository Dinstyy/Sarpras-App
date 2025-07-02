import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CartProvider with ChangeNotifier {
  List<Map<String, dynamic>> _cartItems = [];
  List<int> _selectedItemIndices = [];

  CartProvider() {
    _loadCart();
  }

  List<Map<String, dynamic>> get cartItems => List.unmodifiable(_cartItems);
  List<int> get selectedItemIndices => List.unmodifiable(_selectedItemIndices);
  List<Map<String, dynamic>> get selectedItems =>
      _selectedItemIndices.map((index) => _cartItems[index]).toList();

  void addItem(Map<String, dynamic> item) {
    final newItem = {
      'itemUnitId': item['itemUnitId'],
      'quantity': item['quantity'] ?? 1,
      'unitCode': item['unitCode'] ?? 'Unknown Unit',
      'qrImage': item['qrImage'] ?? '',
      'type': item['type'] ?? 'non-consumable',
    };
    _cartItems.add(newItem);
    _saveCart();
    notifyListeners();
  }

  void removeItem(int index) {
    _cartItems.removeAt(index);
    _selectedItemIndices.remove(index);
    // Adjust indices for selected items after removal
    _selectedItemIndices = _selectedItemIndices.map((i) => i > index ? i - 1 : i).toList();
    _saveCart();
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    _selectedItemIndices.clear();
    _saveCart();
    notifyListeners();
  }

  void toggleSelection(int index) {
    if (_selectedItemIndices.contains(index)) {
      _selectedItemIndices.remove(index);
    } else {
      _selectedItemIndices.add(index);
    }
    _saveCart();
    notifyListeners();
  }

  void updateQuantity(int index, int newQuantity) {
    if (newQuantity < 1) {
      removeItem(index);
      return;
    }
    final item = _cartItems[index];
    final maxQuantity = item['type'] == 'consumable' ? 2 : 1;
    if (newQuantity <= maxQuantity) {
      _cartItems[index]['quantity'] = newQuantity;
      _saveCart();
      notifyListeners();
    }
  }

  bool canIncreaseQuantity(int index) {
    final item = _cartItems[index];
    final maxQuantity = item['type'] == 'consumable' ? 2 : 1;
    return item['quantity'] < maxQuantity;
  }

  Future<void> _loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartData = prefs.getString('cartItems');
    final selectedData = prefs.getString('selectedItemIndices');
    if (cartData != null) {
      _cartItems = List<Map<String, dynamic>>.from(jsonDecode(cartData));
    }
    if (selectedData != null) {
      _selectedItemIndices = List<int>.from(jsonDecode(selectedData));
    }
    notifyListeners();
  }

  Future<void> _saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cartItems', jsonEncode(_cartItems));
    await prefs.setString('selectedItemIndices', jsonEncode(_selectedItemIndices));
  }
}