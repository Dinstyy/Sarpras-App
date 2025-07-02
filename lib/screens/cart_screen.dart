import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sarpras_app/services/api_services/cart_service.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../providers/cart_provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartService _cartService = CartService();
  bool _isLoading = false;

  Future<void> _submitRequest(BuildContext context) async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    if (cartProvider.selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih setidaknya satu item untuk membuat permintaan')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final DateTime now = DateTime.now();
    final borrowDate = now.toIso8601String().split('T')[0];
    final returnDate = now.add(const Duration(days: 7)).toIso8601String().split('T')[0];

    try {
      await _cartService.submitBorrowRequest(
        borrowDateExpected: borrowDate,
        returnDateExpected: returnDate,
        reason: 'Peminjaman barang',
        notes: 'Mohon diproses segera',
        items: cartProvider.selectedItems
            .map((item) => {
                  'item_unit_id': item['itemUnitId'],
                  'quantity': item['quantity'],
                })
            .toList(),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permintaan peminjaman berhasil dikirim')),
      );
      cartProvider.clearCart();
      context.push('/home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        // Debug: Print cart items to check qrImage values
        print('Cart Items: ${cartProvider.cartItems}');
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            title: Text('Keranjang', style: GoogleFonts.poppins(color: Colors.white)),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.pop(),
            ),
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF8B5CF6)))
              : cartProvider.cartItems.isEmpty
                  ? Center(child: Text('Keranjang kosong', style: GoogleFonts.poppins(color: Colors.white)))
                  : Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: cartProvider.cartItems.length,
                            itemBuilder: (context, index) {
                              final cartItem = cartProvider.cartItems[index];
                              final isSelected = cartProvider.selectedItemIndices.contains(index);
                              return Card(
                                color: isSelected
                                    ? const Color(0xFF8B5CF6).withOpacity(0.2)
                                    : Colors.grey[900],
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                child: InkWell(
                                  onTap: () => cartProvider.toggleSelection(index),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Row(
                                      children: [
                                        Checkbox(
                                          value: isSelected,
                                          onChanged: (_) => cartProvider.toggleSelection(index),
                                          activeColor: const Color(0xFF8B5CF6),
                                          checkColor: Colors.white,
                                        ),
                                        Container(
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            color: Colors.black,
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(
                                              color: const Color(0xFF8B5CF6).withOpacity(0.2),
                                            ),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: (cartItem['qrImage'] != null && cartItem['qrImage'].isNotEmpty)
                                                ? SvgPicture.network(
                                                    cartItem['qrImage'],
                                                    width: 50,
                                                    height: 50,
                                                    fit: BoxFit.contain,
                                                    placeholderBuilder: (context) =>
                                                        const Center(child: CircularProgressIndicator(color: Color(0xFF8B5CF6))),
                                                  )
                                                : const Icon(Icons.qr_code, color: Colors.white, size: 50),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                cartItem['unitCode'] ?? 'Unknown Unit',
                                                style: GoogleFonts.poppins(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                margin: const EdgeInsets.only(top: 7),
                                                decoration: BoxDecoration(
                                                  color: cartItem['type'] == 'consumable'
                                                      ? Colors.orange.withOpacity(0.2)
                                                      : const Color(0xFF8B5CF6).withOpacity(0.2),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  cartItem['type'] == 'consumable'
                                                      ? 'Konsumabel'
                                                      : 'Non-Konsumabel',
                                                  style: GoogleFonts.poppins(
                                                    color: cartItem['type'] == 'consumable'
                                                        ? Colors.orange
                                                        : const Color(0xFF8B5CF6),
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: Icon(
                                                Icons.remove,
                                                color: cartItem['quantity'] > 1
                                                    ? Colors.white
                                                    : Colors.grey,
                                              ),
                                              onPressed: () => cartProvider.updateQuantity(
                                                  index, cartItem['quantity'] - 1),
                                            ),
                                            Text(
                                              '${cartItem['quantity']}',
                                              style: GoogleFonts.poppins(color: Colors.white),
                                            ),
                                            IconButton(
                                              icon: Icon(
                                                Icons.add,
                                                color: cartProvider.canIncreaseQuantity(index)
                                                    ? Colors.white
                                                    : Colors.grey,
                                              ),
                                              onPressed: cartProvider.canIncreaseQuantity(index)
                                                  ? () => cartProvider.updateQuantity(
                                                      index, cartItem['quantity'] + 1)
                                                  : null,
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete, color: Colors.red),
                                              onPressed: () => cartProvider.removeItem(index),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : () => _submitRequest(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF8B5CF6),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : Text(
                                      'Make Request (${cartProvider.selectedItemIndices.length})',
                                      style: GoogleFonts.poppins(color: Colors.white),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
        );
      },
    );
  }
}