import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/dio_service.dart';
import '../../services/api_services/item_service.dart';
import '../../services/api_services/item_unit_service.dart';
import '../../services/api_services/cart_service.dart'; // Tambahkan impor ini
import '../../models/item.dart';
import '../../models/item_unit.dart';
import 'package:image_network/image_network.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../providers/cart_provider.dart';
import 'package:provider/provider.dart';

class ItemDetailScreen extends StatefulWidget {
  final String itemId;

  const ItemDetailScreen({Key? key, required this.itemId}) : super(key: key);

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> with SingleTickerProviderStateMixin {  
  final ItemService _itemService = ItemService(DioService());
  final ItemUnitService _itemUnitService = ItemUnitService(DioService());

  bool _isLoading = true;
  String? _error;
  late TabController _tabController;

  Item? _item;
  List<Map<String, dynamic>> _tempCart = [];
  List<ItemUnit> _units = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchItemDetails();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchItemDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final item = await _itemService.getById(int.parse(widget.itemId));
      List<ItemUnit> units = [];
      try {
        units = await _itemUnitService.getByItemId(item.id);
      } catch (_) {}

      if (mounted) {
        setState(() {
          _item = item;
          _units = units;
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

  int get _available => _units.where((unit) => unit.status == 'available').length;
  int get _quantity => _units.length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF8B5CF6)))
          : _error != null
              ? _buildError()
              : _item == null
                  ? Center(
                      child: Text(
                        'Item tidak ditemukan',
                        style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
                      ),
                    )
                  : DefaultTabController(
                      length: 2,
                      child: NestedScrollView(
                        headerSliverBuilder: (context, innerBoxIsScrolled) => [
                          SliverAppBar(
                            pinned: true,
                            expandedHeight: 280,
                            backgroundColor: Colors.black,
                            leading: IconButton(
                              icon: const Icon(Icons.arrow_back, color: Colors.white),
                              onPressed: () => context.pop(),
                            ),
                            actions: [
                              Padding(
                                padding: const EdgeInsets.only(right: 16.0),
                                child: IconButton(
                                  icon: const Icon(Icons.shopping_cart, color: Colors.white),
                                  onPressed: () => context.push('/cart'),
                                ),
                              ),
                            ],
                            flexibleSpace: FlexibleSpaceBar(
                              background: _buildHeroImage(_item!),
                            ),
                          ),
                        ],
                        body: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildDetailAndUnitsTab(),
                          ],
                        ),
                      ),
                    ),
    );
  }

Widget _buildDetailAndUnitsTab() {
  return ListView(
    padding: const EdgeInsets.all(16),
    children: [
      Text(
        _item!.name,
        style: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      const SizedBox(height: 12),
      _buildInfoRow(Icons.category, _item!.category?.name ?? 'Tanpa kategori'),
      _buildInfoRow(Icons.info_outline,
          _item!.type == 'consumable' ? 'Konsumabel' : 'Non-Konsumabel'),
      _buildInfoRow(Icons.inventory_2,
          'Tersedia: $_available dari $_quantity unit'),
      const SizedBox(height: 24),
      Text(
        'Deskripsi',
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: Colors.white,
        ),
      ),
      const SizedBox(height: 8),
      Text(
        _item!.description ?? 'Tanpa deskripsi',
        style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
      ),
      const SizedBox(height: 24),
      Divider(color: Colors.white24),
      const SizedBox(height: 12),
      Text(
        'Daftar Unit Barang',
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: Colors.white,
        ),
      ),
      const SizedBox(height: 12),
      if (_units.isEmpty)
        Padding(
          padding: const EdgeInsets.only(left: 2.0), // Menggeser ke kiri dengan padding
          child: Text(
            'tidak ada unit yang tersedia',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
          ),
        )
      else
        ..._units.map((unit) => _buildUnitCard(unit)).toList(),
    ],
  );
}

  Widget _buildHeroImage(Item item) {
    return ClipRRect(
      child: item.image == null || item.image!.isEmpty
          ? Container(
              height: 250,
              color: Colors.black,
              child: Center(
                child: Icon(
                  _getIconForItem(item),
                  size: 120,
                  color: Colors.white70,
                ),
              ),
            )
          : ImageNetwork(
              image: item.image!,
              height: 300,
              width: 500,
              fitAndroidIos: BoxFit.cover,
              fitWeb: BoxFitWeb.cover,
              onLoading: Shimmer.fromColors(
                baseColor: Colors.grey[800]!,
                highlightColor: Colors.grey[700]!,
                child: Container(height: 250, color: Colors.black),
              ),
              onError: Center(
                child: Icon(
                  _getIconForItem(item),
                  size: 120,
                  color: Colors.white70,
                ),
              ),
            ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF8B5CF6)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
            onPressed: _fetchItemDetails,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6),
              foregroundColor: Colors.white,
            ),
            child: Text('Coba Lagi', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }

  IconData _getIconForItem(Item item) {
    final name = item.name.toLowerCase();
    if (item.type == 'consumable') return Icons.inventory_2;
    if (name.contains('laptop')) return Icons.laptop;
    if (name.contains('komputer')) return Icons.computer;
    if (name.contains('proyektor')) return Icons.videocam;
    if (name.contains('meja')) return Icons.table_bar;
    if (name.contains('kursi')) return Icons.chair;
    return Icons.devices_other;
  }

Widget _buildUnitCard(ItemUnit unit) {
    final isAvailable = unit.status == 'available';

    void _addToCart() {
      if (isAvailable) {
        setState(() {
          _tempCart.add({
            'itemId': _item!.id,
            'itemUnitId': unit.id,
            'unitCode': unit.unitCode,
            'quantity': 1,
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ditambahkan ke keranjang sementara')),
          );
          // Navigasi ke CartScreen dengan mengirim _tempCart sebagai extra
          context.push('/cart', extra: _tempCart);
        });
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: unit.qrImage == null
                      ? Icon(Icons.qr_code, size: 40, color: Colors.white38)
                      : SvgPicture.network(
                          unit.qrImage!,
                          height: 90,
                          width: 90,
                          placeholderBuilder: (context) => Center(child: CircularProgressIndicator(color: Color(0xFF8B5CF6))),
                          errorBuilder: (context, error, stackTrace) => Icon(Icons.error, color: Colors.red, size: 40),
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(unit.unitCode,
                          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 8),
                      Text('Merk: ${unit.merk}',
                          style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70)),
                      Text('Kondisi: ${unit.condition}',
                          style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70)),
                      if (unit.warehouse?.name != null)
                        Text('Gudang: ${unit.warehouse!.name}',
                            style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70)),
                      if (unit.currentLocation != null && unit.currentLocation!.isNotEmpty)
                        Text('Lokasi: ${unit.currentLocation}',
                            style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isAvailable ? Colors.green[800] : Colors.orange[800],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    isAvailable ? 'Tersedia' : unit.status,
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
                ElevatedButton(
                onPressed: () {
                  if (unit.status == 'available') { // Only add if available
                    final item = {
                      'itemUnitId': unit.id, // Use unit.id
                      'quantity': 1,
                      'unitCode': unit.unitCode, // Use unit.unitCode
                    };
                    Provider.of<CartProvider>(context, listen: false).addItem(item);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Item ditambahkan ke keranjang')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Unit tidak tersedia')),
                    );
                  }
                },
                child: const Text('Tambah ke Keranjang'),
              ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}