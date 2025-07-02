import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sarpras_app/models/item_unit.dart';
import 'package:sarpras_app/services/api_services/item_unit_service.dart';
import 'package:sarpras_app/services/dio_service.dart';

class ItemUnitSelectionScreen extends StatefulWidget {
  final Function(Map<String, dynamic>)? addItemCallback; // Receive callback explicitly

  const ItemUnitSelectionScreen({Key? key, this.addItemCallback}) : super(key: key);

  @override
  State<ItemUnitSelectionScreen> createState() => _ItemUnitSelectionScreenState();
}

class _ItemUnitSelectionScreenState extends State<ItemUnitSelectionScreen> {
  final ItemUnitService _itemUnitService = ItemUnitService(DioService());
  List<ItemUnit> _itemUnits = [];
  List<ItemUnit> _selectedItems = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchItemUnits();
  }

  Future<void> _fetchItemUnits() async {
    setState(() => _isLoading = true);
    try {
      final itemUnits = await _itemUnitService.getAll();
      setState(() {
        _itemUnits = itemUnits;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _toggleItemSelection(ItemUnit itemUnit) {
    setState(() {
      if (_selectedItems.contains(itemUnit)) {
        _selectedItems.remove(itemUnit);
      } else {
        _selectedItems.add(itemUnit);
      }
    });
  }

  void _confirmSelection() {
    if (widget.addItemCallback != null) {
      for (var item in _selectedItems) {
        widget.addItemCallback!({
          'item_unit_id': item.id,
          'quantity': 1, // Default quantity, bisa diubah dengan input jika diperlukan
        });
      }
    }
    Navigator.pop(context); // Kembali ke BorrowRequestScreen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Pilih Item',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        actions: [
          if (_selectedItems.isNotEmpty)
            TextButton(
              onPressed: _confirmSelection,
              child: Text(
                'Konfirmasi',
                style: GoogleFonts.poppins(color: Color(0xFF8B5CF6)),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xFF8B5CF6)))
          : _error != null
              ? Center(child: Text('Error: $_error', style: GoogleFonts.poppins(color: Colors.white)))
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: _itemUnits.length,
                  itemBuilder: (context, index) {
                    final itemUnit = _itemUnits[index];
                    final isSelected = _selectedItems.contains(itemUnit);
                    return Card(
                      color: Colors.grey[900],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: Icon(
                          isSelected ? Icons.check_circle : Icons.circle_outlined,
                          color: isSelected ? Color(0xFF8B5CF6) : Colors.white70,
                        ),
                        title: Text(
                          '${itemUnit.item?.name ?? 'Unknown'} (Unit: ${itemUnit.unitCode})',
                          style: GoogleFonts.poppins(color: Colors.white),
                        ),
                        subtitle: Text(
                          'Status: ${itemUnit.status}, Jumlah: ${itemUnit.quantity}',
                          style: GoogleFonts.poppins(color: Colors.grey[400]),
                        ),
                        onTap: () => _toggleItemSelection(itemUnit),
                      ),
                    );
                  },
                ),
    );
  }
}