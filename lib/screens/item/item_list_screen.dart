import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/dio_service.dart';
import '../../services/api_services/item_service.dart';
import '../../services/api_services/category_service.dart';
import '../../services/api_services/warehouse_service.dart';
import '../../services/api_services/item_unit_service.dart';
import '../../models/item.dart';
import '../../models/category.dart';
import '../../models/warehouse.dart';
import 'package:image_network/image_network.dart';

class ItemListScreen extends StatefulWidget {
  final String? warehouseId;
  final String? categoryId;
  final String title;

  ItemListScreen({
    Key? key,
    this.warehouseId,
    this.categoryId,
    required this.title,
  }) : super(key: key);

  @override
  State<ItemListScreen> createState() => _ItemListScreenState();
}

class _ItemListScreenState extends State<ItemListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ItemService _itemService = ItemService(DioService());
  final CategoryService _categoryService = CategoryService(DioService());
  final WarehouseService _warehouseService = WarehouseService(DioService());
  final ItemUnitService _itemUnitService = ItemUnitService(DioService());

  List<Item> _items = [];
  List<Item> _filteredItems = [];
  bool _isLoading = true;
  String? _error;

  Category? _category;
  Warehouse? _warehouse;

  @override
  void initState() {
    super.initState();
    _fetchItems();
    _searchController.addListener(_filterItems);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterItems);
    _searchController.dispose();
    super.dispose();
  }

  void _filterItems() {
    if (_searchController.text.isEmpty) {
      setState(() {
        _filteredItems = _items;
      });
    } else {
      setState(() {
        _filteredItems = _items
            .where((item) =>
                item.name.toLowerCase().contains(_searchController.text.toLowerCase()) ||
                (item.description?.toLowerCase().contains(_searchController.text.toLowerCase()) ?? false))
            .toList();
      });
    }
  }

  Future<void> _fetchItems() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      List<Item> items = [];

      if (widget.categoryId != null) {
        try {
          _category = await _categoryService.getById(int.parse(widget.categoryId!));
          items = await _itemService.getByCategoryId(_category!.id, withCategory: true);
        } catch (e) {
          _error = 'Gagal memuat data kategori: ${e.toString()}';
        }
      } else if (widget.warehouseId != null) {
        try {
          _warehouse = await _warehouseService.getById(int.parse(widget.warehouseId!));
          final itemUnits = await _itemUnitService.getByWarehouseId(int.parse(widget.warehouseId!));
          final itemIds = itemUnits.map((unit) => unit.itemId).toSet();
          items = [];
          for (var itemId in itemIds) {
            final item = await _itemService.getById(itemId, withCategory: true);
            items.add(item);
          }
          items.sort((a, b) => a.name.compareTo(b.name));
        } catch (e) {
          _error = 'Gagal memuat data gudang: ${e.toString()}';
        }
      } else {
        items = await _itemService.getAll(withCategory: true);
      }

      if (mounted) {
        setState(() {
          _items = items;
          _filteredItems = items;
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
    final displayTitle = widget.warehouseId != null && _warehouse != null
        ? _warehouse!.name
        : widget.categoryId != null && _category != null
            ? _category!.name
            : widget.title;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          displayTitle,
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Cari barang...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF8B5CF6)),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white70),
                        onPressed: () {
                          _searchController.clear();
                          _filterItems();
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
                              onPressed: _fetchItems,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF8B5CF6),
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Coba Lagi'),
                            ),
                          ],
                        ),
                      )
                    : _filteredItems.isEmpty
                        ? const Center(
                            child: Text(
                              'Barang tidak ditemukan',
                              style: TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _fetchItems,
                            color: const Color(0xFF8B5CF6),
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: _filteredItems.length,
                              itemBuilder: (context, index) {
                                final item = _filteredItems[index];
                                final categoryName = item.category?.name ?? 'Tidak ada kategori';

                                return Card(
                                  elevation: 2,
                                  margin: const EdgeInsets.only(bottom: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  color: Colors.grey[900],
                                  clipBehavior: Clip.hardEdge,
                                  child: InkWell(
                                    onTap: () {
                                      context.push('/items/${item.id}');
                                    },
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
                                              border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.2)),
                                            ),
                                            child: item.image == null || item.image!.isEmpty
                                                ? const Icon(
                                                    Icons.inventory,
                                                    size: 40,
                                                    color: Colors.white70,
                                                  )
                                                : ClipRRect(
                                                    borderRadius: BorderRadius.circular(8),
                                                    child: ImageNetwork(
                                                      image: item.image ?? '',
                                                      width: 80.0,
                                                      height: 80.0,
                                                      fitWeb: BoxFitWeb.cover,
                                                      fitAndroidIos: BoxFit.cover,
                                                      onLoading: const Center(child: CircularProgressIndicator()),
                                                      onError: const Icon(
                                                        Icons.inventory,
                                                        size: 40,
                                                        color: Colors.white70,
                                                      ),
                                                    ),
                                                  ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  item.name,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    const Icon(Icons.category, size: 14, color: Colors.white70),
                                                    const SizedBox(width: 4),
                                                    Expanded(
                                                      child: Text(
                                                        categoryName,
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.white70,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    const Icon(Icons.description, size: 14, color: Colors.white70),
                                                    const SizedBox(width: 4),
                                                    Expanded(
                                                      child: Text(
                                                        item.description ?? 'Tanpa deskripsi',
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.white70,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: item.type == 'consumable'
                                                  ? Colors.orange.withOpacity(0.2)
                                                  : const Color(0xFF8B5CF6).withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              item.type == 'consumable' ? 'Konsumabel' : 'Non-Konsumabel',
                                              style: TextStyle(
                                                color: item.type == 'consumable'
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