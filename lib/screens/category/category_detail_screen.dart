import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/dio_service.dart';
import '../../services/api_services/category_service.dart';
import '../../services/api_services/item_service.dart';
import '../../models/category.dart';
import '../../models/item.dart';

class CategoryDetailScreen extends StatefulWidget {
  final String categoryId;

  const CategoryDetailScreen({
    Key? key,
    required this.categoryId,
  }) : super(key: key);

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  final TextEditingController _searchController = TextEditingController();
  final CategoryService _categoryService = CategoryService(DioService());
  final ItemService _itemService = ItemService(DioService());

  Category? _category;
  List<Item> _items = [];
  List<Item> _filteredItems = [];
  bool _isLoading = true;
  String? _error;

  final Map<String, IconData> _categoryIcons = {
    'elektronik': Icons.devices,
    'furnitur': Icons.chair,
    'alat tulis': Icons.edit,
    'komputer': Icons.computer,
    'olahraga': Icons.sports_soccer,
    'buku': Icons.book,
    'laboratorium': Icons.science,
    'musik': Icons.music_note,
    'default': Icons.category,
  };

  @override
  void initState() {
    super.initState();
    _fetchCategoryDetails();
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

  IconData _getIconForCategory(String categoryName) {
    final lowerCaseName = categoryName.toLowerCase();

    for (final entry in _categoryIcons.entries) {
      if (lowerCaseName.contains(entry.key)) {
        return entry.value;
      }
    }

    return _categoryIcons['default']!;
  }

  Future<void> _fetchCategoryDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Fetch category details
      final category = await _categoryService.getById(int.parse(widget.categoryId));

      // Fetch items for the category
      final items = await _itemService.getByCategoryId(category.id);

      if (mounted) {
        setState(() {
          _category = category;
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
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          _category?.name ?? 'Detail Kategori',
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
                        onPressed: _fetchCategoryDetails,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B5CF6),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : _category == null
                  ? const Center(
                      child: Text(
                        'Kategori tidak ditemukan',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    )
                  : Column(
                      children: [
                        // Category Info Card
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
                                        child: Icon(
                                          _getIconForCategory(_category!.name),
                                          color: const Color(0xFF8B5CF6),
                                          size: 30,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Text(
                                          _category!.name,
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
                                  Text(
                                    'Jumlah Barang: ${_items.length}',
                                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                                  ),
                                  if (_category!.description != null && _category!.description!.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Deskripsi',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _category!.description!,
                                      style: const TextStyle(fontSize: 14, color: Colors.white70),
                                    ),
                                  ],
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
                              hintText: 'Cari barang dalam kategori...',
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
                        // Item List
                        Expanded(
                          child: _filteredItems.isEmpty
                              ? const Center(
                                  child: Text(
                                    'Barang tidak ditemukan',
                                    style: TextStyle(fontSize: 16, color: Colors.white),
                                  ),
                                )
                              : RefreshIndicator(
                                  onRefresh: _fetchCategoryDetails,
                                  color: const Color(0xFF8B5CF6),
                                  child: ListView.builder(
                                    padding: const EdgeInsets.all(16),
                                    itemCount: _filteredItems.length,
                                    itemBuilder: (context, index) {
                                      final item = _filteredItems[index];
                                      return Card(
                                        elevation: 2,
                                        margin: const EdgeInsets.only(bottom: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        color: Colors.grey[900],
                                        child: InkWell(
                                          onTap: () {
                                            context.push('/items/${item.id}');
                                          },
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
                                                  child: item.image == null || item.image!.isEmpty
                                                      ? const Icon(
                                                          Icons.inventory,
                                                          size: 40,
                                                          color: Colors.white70,
                                                        )
                                                      : ClipRRect(
                                                          borderRadius: BorderRadius.circular(8),
                                                          child: Image.network(
                                                            item.image!,
                                                            fit: BoxFit.cover,
                                                            errorBuilder: (context, error, stackTrace) {
                                                              return const Icon(
                                                                Icons.inventory,
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
                                                          const Icon(Icons.description,
                                                              size: 14, color: Colors.white70),
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
                                                  padding:
                                                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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