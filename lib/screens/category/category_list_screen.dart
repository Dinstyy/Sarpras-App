import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/dio_service.dart';
import '../../services/api_services/category_service.dart';
import '../../models/category.dart';

class CategoryListScreen extends StatefulWidget {
  const CategoryListScreen({Key? key}) : super(key: key);

  @override
  State<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final CategoryService _categoryService = CategoryService(DioService());

  List<Category> _categories = [];
  List<Category> _filteredCategories = [];
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
    _fetchCategories();
    _searchController.addListener(_filterCategories);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterCategories);
    _searchController.dispose();
    super.dispose();
  }

  void _filterCategories() {
    if (_searchController.text.isEmpty) {
      setState(() {
        _filteredCategories = _categories;
      });
    } else {
      setState(() {
        _filteredCategories = _categories
            .where((category) =>
                category.name.toLowerCase().contains(_searchController.text.toLowerCase()) ||
                (category.description?.toLowerCase().contains(_searchController.text.toLowerCase()) ?? false))
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

  Future<void> _fetchCategories() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final categories = await _categoryService.getAll(
        sortBy: 'name',
        sortDir: 'asc',
        withItems: true,
      );

      if (mounted) {
        setState(() {
          _categories = categories;
          _filteredCategories = categories;
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
          'Kategori Barang',
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
                  hintText: 'Cari kategori...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF8B5CF6)),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.white70),
                          onPressed: () {
                            _searchController.clear();
                            _filterCategories();
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
                      : _filteredCategories.isEmpty
                          ? const Center(
                              child: Text(
                                'Kategori tidak ditemukan',
                                style: TextStyle(fontSize: 16, color: Colors.white),
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _fetchCategories,
                              color: const Color(0xFF8B5CF6),
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  final width = constraints.maxWidth;
                                  final crossAxisCount =
                                      width < 600 ? 2 : (width < 900 ? 3 : 4);

                                  return GridView.builder(
                                    padding: const EdgeInsets.all(16),
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: crossAxisCount,
                                      childAspectRatio: 1.0,
                                      crossAxisSpacing: 12,
                                      mainAxisSpacing: 12,
                                    ),
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    itemCount: _filteredCategories.length,
                                    itemBuilder: (context, index) {
                                      return _buildCategoryCard(
                                          _filteredCategories[index], index);
                                    },
                                  );
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
              onPressed: _fetchCategories,
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

  Widget _buildCategoryCard(Category category, int index) {
    final itemCount = category.items?.length ?? 0;
    final categoryIcon = _getIconForCategory(category.name);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: Colors.grey[900],
      child: InkWell(
        onTap: () => context.push('/categories/${category.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                flex: 5,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    categoryIcon,
                    color: const Color(0xFF8B5CF6),
                    size: 30,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Flexible(
                flex: 3,
                child: Text(
                  category.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Flexible(
                flex: 2,
                child: Text(
                  '$itemCount barang',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}