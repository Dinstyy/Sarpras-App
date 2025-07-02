import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/dio_service.dart';
import '../../services/api_services/warehouse_service.dart';
import '../../models/warehouse.dart';

class WarehouseListScreen extends StatefulWidget {
  const WarehouseListScreen({Key? key}) : super(key: key);

  @override
  State<WarehouseListScreen> createState() => _WarehouseListScreenState();
}

class _WarehouseListScreenState extends State<WarehouseListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final WarehouseService _warehouseService = WarehouseService(DioService());

  List<Warehouse> _warehouses = [];
  List<Warehouse> _filteredWarehouses = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchWarehouses();
    _searchController.addListener(_filterWarehouses);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterWarehouses);
    _searchController.dispose();
    super.dispose();
  }

  void _filterWarehouses() {
    if (_searchController.text.isEmpty) {
      setState(() {
        _filteredWarehouses = _warehouses;
      });
    } else {
      setState(() {
        _filteredWarehouses = _warehouses
            .where((warehouse) =>
                warehouse.name.toLowerCase().contains(_searchController.text.toLowerCase()) ||
                warehouse.location.toLowerCase().contains(_searchController.text.toLowerCase()))
            .toList();
      });
    }
  }

  Future<void> _fetchWarehouses() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final warehouses = await _warehouseService.getAll(
        sortBy: 'name',
        sortDir: 'asc',
      );

      if (mounted) {
        setState(() {
          _warehouses = warehouses;
          _filteredWarehouses = warehouses;
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
        title: const Text(
          'Daftar Gudang',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Cari gudang...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF8B5CF6)),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.white70),
                          onPressed: () {
                            _searchController.clear();
                            _filterWarehouses();
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
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF8B5CF6)))
                  : _error != null
                      ? _buildErrorView()
                      : _filteredWarehouses.isEmpty
                          ? const Center(
                              child: Text(
                                'Gudang tidak ditemukan',
                                style: TextStyle(fontSize: 16, color: Colors.white),
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _fetchWarehouses,
                              color: const Color(0xFF8B5CF6),
                              child: ListView.builder(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.all(16),
                                itemCount: _filteredWarehouses.length,
                                itemBuilder: (context, index) {
                                  return _buildWarehouseCard(_filteredWarehouses[index]);
                                },
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
              onPressed: _fetchWarehouses,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                foregroundColor: Colors.white,
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWarehouseCard(Warehouse warehouse) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      color: Colors.grey[900],
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => context.push('/warehouses/${warehouse.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.warehouse,
                  color: Color(0xFF8B5CF6),
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      warehouse.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.inventory_2, size: 14, color: Colors.white70),
                        const SizedBox(width: 4),
                        Text(
                          '${warehouse.capacity} kapasitas',
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
                            warehouse.location,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 14, color: Colors.white70),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white70),
            ],
          ),
        ),
      ),
    );
  }
}