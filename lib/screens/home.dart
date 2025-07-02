import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sarpras_app/services/api_services/index.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/auth_provider.dart';
import '../services/dio_service.dart';
import '../services/api_services/item_service.dart';
import '../models/item.dart';
import 'package:image_network/image_network.dart';
import '../../providers/cart_provider.dart';
import 'package:provider/provider.dart' as provider;

class HomeScreen extends ConsumerStatefulWidget {
  final String role;

  const HomeScreen({Key? key, required this.role}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ItemService _itemService = ItemService(DioService());
  int _currentIndex = 0;
  int? _hoveredIndex;
  int hoveredMenuIndex = -1;
  int hoveredRequestIndex = -1;

  bool _isLoading = true;
  String? _error;
  List<Item> _recentItems = [];
  late List<Widget> _pages; // Moved here and initialized as late

  @override
  void initState() {
    super.initState();
    _saveRole();
    _fetchData();
    _pages = []; // Initial empty list
  }

  Future<void> _saveRole() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('role', widget.role);
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final items = await _itemService.getAll(
        sortBy: 'created_at',
        sortDir: 'desc',
        withCategory: true,
        withItemUnits: true,
      );

      if (mounted) {
        setState(() {
          _recentItems = items.take(5).toList();
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
    // Assign _pages here based on the current state
    _pages = [
      RefreshIndicator(
        onRefresh: _fetchData,
        color: const Color(0xFF8B5CF6),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Cari barang...',
                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                          prefixIcon: const Icon(Icons.search, color: Color(0xFF8B5CF6)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 0),
                          fillColor: Colors.grey[900],
                          filled: true,
                        ),
                        readOnly: true,
                        onTap: () => context.push('/items'),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          const Icon(Icons.shopping_cart, color: Colors.white),
                          if (provider.Provider.of<CartProvider>(context).cartItems.isNotEmpty)
                            Positioned(
                              top: -6,
                              right: -6,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.deepPurpleAccent,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(minWidth: 15, minHeight: 15),
                                child: Center(
                                  child: Text(
                                    '${provider.Provider.of<CartProvider>(context).cartItems.length}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      onPressed: () => context.push('/cart'),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.notifications_none_rounded, color: Colors.white),
                      onPressed: () => context.push('/notifications'),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16151F),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Color(0xFF8B5CF6), width: 1),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF8B5CF6).withOpacity(0.1),
                        ),
                        child: const Icon(Icons.access_time_rounded, color: Color(0xFF8B5CF6), size: 22),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Selamat datang!',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Sarpras buka pukul 07.00 - 19.00',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Request',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildRequestButton(
                            title: 'Request\nPeminjaman',
                            icon: Icons.send,
                            onTap: () => context.push('/borrow-request'),
                            index: 0,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildRequestButton(
                            title: 'Request\nPengembalian',
                            icon: Icons.inbox,
                            onTap: () => context.push('/return-request'),
                            index: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildRequestButton(
                            title: 'Lapor\nBarang Rusak',
                            icon: Icons.report_problem,
                            onTap: () => context.push('/damage-report'),
                            index: 2,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildRequestButton(
                            title: 'Request Permintaan',
                            icon: Icons.bookmark_add,
                            onTap: () => context.push('/pay-fine'),
                            index: 3,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Menu Utama',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 4,
                    itemBuilder: (context, index) {
                      final menuItems = [
                        {
                          'title': 'Daftar Gudang',
                          'icon': Icons.warehouse,
                          'onTap': () => context.push('/warehouses'),
                        },
                        {
                          'title': 'Kategori Barang',
                          'icon': Icons.category,
                          'onTap': () => context.push('/categories'),
                        },
                        {
                          'title': 'Daftar Barang',
                          'icon': Icons.inventory_2,
                          'onTap': () => context.push('/items'),
                        },
                        {
                          'title': 'Bayar Denda',
                          'icon': Icons.attach_money,
                          'onTap': () => context.push('/history'),
                        },
                      ];
                      final item = menuItems[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 17.0),
                        child: MouseRegion(
                          onEnter: (_) => setState(() => hoveredMenuIndex = index),
                          onExit: (_) => setState(() => hoveredMenuIndex = -1),
                          child: GestureDetector(
                            onTap: item['onTap'] as VoidCallback,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 100,
                              decoration: BoxDecoration(
                                color: hoveredMenuIndex == index ? Colors.grey[800] : Colors.grey[900],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.15)),
                              ),
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(item['icon'] as IconData, size: 30, color: const Color(0xFF8B5CF6)),
                                  const SizedBox(height: 10),
                                  Text(
                                    item['title'] as String,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Barang Terbaru',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push('/items'),
                      child: Text(
                        'Lihat Semua',
                        style: GoogleFonts.poppins(color: const Color(0xFF8B5CF6)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFF8B5CF6)))
                    : _error != null
                        ? Center(
                            child: Column(
                              children: [
                                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                                const SizedBox(height: 16),
                                Text(
                                  'Error: $_error',
                                  style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _fetchData,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF8B5CF6),
                                    foregroundColor: Colors.white,
                                  ),
                                  child: Text('Coba Lagi', style: GoogleFonts.poppins()),
                                ),
                              ],
                            ),
                          )
                        : _recentItems.isEmpty
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Text('Belum ada barang terbaru', style: TextStyle(color: Colors.white)),
                                ),
                              )
                            : GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _recentItems.length,
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: 0.80,
                                ),
                                itemBuilder: (context, index) {
                                  final item = _recentItems[index];
                                  return _buildRecentItemCard(
                                    item: item,
                                    onTap: () => context.push('/items/${item.id}'),
                                  );
                                },
                              ),
              ],
            ),
          ),
        ),
      ),
      Center(child: Text('Kategori Barang', style: GoogleFonts.poppins(fontSize: 24, color: Colors.white))),
      Center(child: Text('Profil', style: GoogleFonts.poppins(fontSize: 24, color: Colors.white))),
    ];

    // Ensure _currentIndex is within bounds
    if (_currentIndex < 0 || _currentIndex >= _pages.length) {
      _currentIndex = 0;
    }

    final authState = ref.watch(authProvider);
    final userName = authState.userData?.username ?? 'User';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.black,
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.2), width: 1)),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        padding: const EdgeInsets.only(top: 12, left: 10, right: 10, bottom: 16),
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(4, (index) {
              List<IconData> outlinedIcons = [
                Icons.home_outlined,
                Icons.storefront_outlined,
                Icons.favorite_border,
                Icons.person_outline,
              ];

              List<IconData> filledIcons = [
                Icons.home,
                Icons.storefront,
                Icons.favorite,
                Icons.person,
              ];

              List<String> labels = [
                'Home',
                'Store',
                'Active Borrows',
                'Profile'
              ];

              bool isSelected = _currentIndex == index;
              bool isHovered = _hoveredIndex == index;

              final IconData icon = isSelected ? filledIcons[index] : outlinedIcons[index];
              final Color iconColor = isSelected || isHovered ? const Color(0xFF8B5CF6) : Colors.grey;

              final FontWeight textWeight = isSelected ? FontWeight.w600 : FontWeight.w400;

              return MouseRegion(
                onEnter: (_) => setState(() => _hoveredIndex = index),
                onExit: (_) => setState(() => _hoveredIndex = null),
                child: GestureDetector(
                  onTap: () {
                    setState(() => _currentIndex = index);
                    if (index == 1) {
                      context.push('/categories');
                    } else if (index == 2) {
                      context.push('/active-borrows');
                    } else if (index == 3) {
                      context.push('/profile');
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 70,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: const BoxDecoration(color: Colors.transparent),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icon, color: iconColor),
                        const SizedBox(height: 4),
                        Text(
                          labels[index],
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: textWeight,
                            color: iconColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: Colors.grey[900],
        clipBehavior: Clip.hardEdge,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF8B5CF6),
                  size: 30,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequestButton({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    required int index,
  }) {
    return MouseRegion(
      onEnter: (_) => setState(() => hoveredRequestIndex = index),
      onExit: (_) => setState(() => hoveredRequestIndex = -1),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: hoveredRequestIndex == index ? Colors.grey[800] : Colors.grey[900],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.1)),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF8B5CF6),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentItemCard({
    required Item item,
    required VoidCallback onTap,
  }) {
    final IconData itemIcon = _getIconForItem(item);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.grey[900],
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.2)),
                  ),
                  child: item.image != null && item.image!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: ImageNetwork(
                            image: item.image ?? '',
                            width: double.infinity,
                            height: double.infinity,
                            fitWeb: BoxFitWeb.cover,
                            fitAndroidIos: BoxFit.cover,
                            onError: const Icon(
                              Icons.inventory,
                              size: 50,
                              color: Colors.white70,
                            ),
                          ),
                        )
                      : Icon(
                          itemIcon,
                          size: 50,
                          color: Colors.white70,
                        ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                item.name,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                item.category?.name ?? 'Tidak ada kategori',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey[400],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: item.type == 'consumable' ? Colors.orange.withOpacity(0.2) : const Color(0xFF8B5CF6).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      item.type == 'consumable' ? 'Konsumabel' : 'Non-Konsumabel',
                      style: GoogleFonts.poppins(
                        color: item.type == 'consumable' ? Colors.orange : const Color(0xFF8B5CF6),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForItem(Item item) {
    if (item.type == 'consumable') {
      return Icons.inventory;
    } else {
      final name = item.name.toLowerCase();
      if (name.contains('laptop')) return Icons.laptop;
      if (name.contains('komputer')) return Icons.computer;
      if (name.contains('proyektor')) return Icons.videocam;
      if (name.contains('meja')) return Icons.table_bar;
      if (name.contains('kursi')) return Icons.chair;
      return Icons.devices;
    }
  }
}