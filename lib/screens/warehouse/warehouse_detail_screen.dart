import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/dio_service.dart';
import '../../services/api_services/warehouse_service.dart';
import '../../services/api_services/item_unit_service.dart';
import '../../models/warehouse.dart';
import '../../models/item_unit.dart';

class WarehouseDetailScreen extends StatefulWidget {
  final String warehouseId;

  const WarehouseDetailScreen({
    Key? key,
    required this.warehouseId,
  }) : super(key: key);

  @override
  State<WarehouseDetailScreen> createState() => _WarehouseDetailScreenState();
}

class _WarehouseDetailScreenState extends State<WarehouseDetailScreen> {
  final TextEditingController _searchController = TextEditingController();
  final WarehouseService _warehouseService = WarehouseService(DioService());
  final ItemUnitService _itemUnitService = ItemUnitService(DioService());

  Warehouse? _warehouse;
  List<ItemUnit> _units = [];
  List<ItemUnit> _filteredUnits = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchWarehouseDetails();
    _searchController.addListener(_filterUnits);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterUnits);
    _searchController.dispose();
    super.dispose();
  }

  void _filterUnits() {
    if (_searchController.text.isEmpty) {
      setState(() {
        _filteredUnits = _units;
      });
    } else {
      setState(() {
        _filteredUnits = _units
            .where((unit) =>
                unit.unitCode.toLowerCase().contains(_searchController.text.toLowerCase()) ||
                (unit.item?.name.toLowerCase().contains(_searchController.text.toLowerCase()) ?? false) ||
                (unit.notes?.toLowerCase().contains(_searchController.text.toLowerCase()) ?? false))
            .toList();
      });
    }
  }

  Future<void> _fetchWarehouseDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Fetch warehouse details
      final warehouse = await _warehouseService.getById(int.parse(widget.warehouseId));

      // Fetch item units for the warehouse
      final units = await _itemUnitService.getByWarehouseId(int.parse(widget.warehouseId));

      if (mounted) {
        setState(() {
          _warehouse = warehouse;
          _units = units;
          _filteredUnits = units;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          _warehouse?.name ?? 'Detail Gudang',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF8B5CF6)))
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        'Error: $_error',
                        style: const TextStyle(fontSize: 16, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchWarehouseDetails,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B5CF6),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : _warehouse == null
                  ? const Center(
                      child: Text(
                        'Gudang tidak ditemukan',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    )
                  : Column(
                      children: [
                        // Warehouse Info Card
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            color: Colors.grey[900],
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF8B5CF6).withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.warehouse,
                                          color: Color(0xFF8B5CF6),
                                          size: 30,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Text(
                                          _warehouse!.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.inventory_2, size: 14, color: Colors.white70),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Kapasitas: ${_warehouse!.capacity}',
                                        style: const TextStyle(fontSize: 14, color: Colors.white70),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on, size: 14, color: Colors.white70),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          _warehouse!.location,
                                          style: const TextStyle(fontSize: 14, color: Colors.white70),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Jumlah Unit: ${_units.length}',
                                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Search Bar
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: TextField(
                            controller: _searchController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Cari unit di gudang...',
                              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                              prefixIcon: const Icon(Icons.search, color: Color(0xFF8B5CF6)),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear, color: Colors.white70),
                                      onPressed: () {
                                        _searchController.clear();
                                        _filterUnits();
                                      },
                                    )
                                  : null,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                              ),
                              contentPadding: const EdgeInsets.symmetric(vertical: 0),
                              fillColor: Colors.grey[900],
                              filled: true,
                            ),
                          ),
                        ),
                        // Item Unit List
                        Expanded(
                          child: _filteredUnits.isEmpty
                              ? const Center(
                                  child: Text(
                                    'Unit tidak ditemukan',
                                    style: TextStyle(fontSize: 16, color: Colors.white),
                                  ),
                                )
                              : RefreshIndicator(
                                  onRefresh: _fetchWarehouseDetails,
                                  color: const Color(0xFF8B5CF6),
                                  child: ListView.builder(
                                    padding: const EdgeInsets.all(16),
                                    itemCount: _filteredUnits.length,
                                    itemBuilder: (context, index) {
                                      final unit = _filteredUnits[index];
                                      final isAvailable = unit.status == 'available';
                                      return Card(
                                        elevation: 2,
                                        margin: const EdgeInsets.only(bottom: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        color: Colors.grey[900],
                                        child: InkWell(
                                          onTap: unit.item != null
                                              ? () => context.push('/items/${unit.item!.id}')
                                              : null,
                                          borderRadius: BorderRadius.circular(10),
                                          child: Padding(
                                            padding: const EdgeInsets.all(12),
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 80,
                                                  height: 80,
                                                  decoration: BoxDecoration(
                                                    color: Colors.black,
                                                    borderRadius: BorderRadius.circular(8),
                                                    border: Border.all(
                                                        color: const Color(0xFF8B5CF6).withOpacity(0.2)),
                                                  ),
                                                  child: unit.qrImage == null || unit.qrImage!.isEmpty
                                                      ? const Icon(
                                                          Icons.qr_code,
                                                          size: 40,
                                                          color: Colors.white70,
                                                        )
                                                      : ClipRRect(
                                                          borderRadius: BorderRadius.circular(8),
                                                          child: Image.network(
                                                            unit.qrImage!,
                                                            fit: BoxFit.cover,
                                                            errorBuilder: (context, error, stackTrace) {
                                                              return const Icon(
                                                                Icons.qr_code,
                                                                size: 40,
                                                                color: Colors.white70,
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                ),
                                                const SizedBox(width: 16),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        unit.unitCode,
                                                        style: const TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 16,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        unit.item?.name ?? 'Item tidak diketahui',
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.white70,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        'Kondisi: ${unit.condition}',
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.white70,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: isAvailable
                                                        ? Colors.green.withOpacity(0.2)
                                                        : Colors.orange.withOpacity(0.2),
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: Text(
                                                    isAvailable ? 'Tersedia' : 'Dipinjam',
                                                    style: TextStyle(
                                                      color: isAvailable ? Colors.green : Colors.orange,
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                        ),
                      ],
                    ),
    );
  }
}