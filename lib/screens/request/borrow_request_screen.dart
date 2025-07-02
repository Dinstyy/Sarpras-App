import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sarpras_app/services/api_services/borrow_request_service.dart';
import 'package:sarpras_app/services/dio_service.dart';
import 'package:intl/intl.dart';

class BorrowRequestScreen extends ConsumerStatefulWidget {
  const BorrowRequestScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<BorrowRequestScreen> createState() => _BorrowRequestScreenState();
}

class _BorrowRequestScreenState extends ConsumerState<BorrowRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _borrowDate;
  DateTime? _returnDate;
  String? _reason;
  String? _notes;
  List<Map<String, dynamic>> _items = [];
  bool _isLoading = false;

  Future<void> _selectDate(BuildContext context, bool isBorrowDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isBorrowDate) {
          _borrowDate = picked;
        } else {
          _returnDate = picked;
        }
      });
    }
  }

  void _addItem(Map<String, dynamic> item) {
    setState(() {
      _items.add(item); // Tambahkan item ke list
    });
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      if (_borrowDate == null || _returnDate == null || _items.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Silakan pilih tanggal pinjam, tanggal kembali, dan setidaknya satu item')),
        );
        return;
      }
      setState(() => _isLoading = true);
      try {
        final service = BorrowRequestService(DioService());
        await service.create(
          borrowDateExpected: _borrowDate!,
          returnDateExpected: _returnDate!,
          reason: _reason!,
          notes: _notes,
          items: _items,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Permintaan peminjaman berhasil diajukan')),
        );
        context.push('/active-borrows');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengajukan: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
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
          'Request Peminjaman',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Alasan Peminjaman',
                    labelStyle: GoogleFonts.poppins(color: Colors.white70),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.grey[900],
                  ),
                  style: TextStyle(color: Colors.white),
                  validator: (value) => value!.isEmpty ? 'Alasan wajib diisi' : null,
                  onSaved: (value) => _reason = value,
                ),
                SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Catatan (Opsional)',
                    labelStyle: GoogleFonts.poppins(color: Colors.white70),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.grey[900],
                  ),
                  style: TextStyle(color: Colors.white),
                  maxLines: 3,
                  onSaved: (value) => _notes = value,
                ),
                SizedBox(height: 16),
                ListTile(
                  title: Text(
                    _borrowDate == null
                        ? 'Pilih Tanggal Pinjam'
                        : DateFormat('dd/MM/yyyy').format(_borrowDate!),
                    style: GoogleFonts.poppins(color: Colors.white),
                  ),
                  trailing: Icon(Icons.calendar_today, color: Color(0xFF8B5CF6)),
                  onTap: () => _selectDate(context, true),
                ),
                ListTile(
                  title: Text(
                    _returnDate == null
                        ? 'Pilih Tanggal Kembali'
                        : DateFormat('dd/MM/yyyy').format(_returnDate!),
                    style: GoogleFonts.poppins(color: Colors.white),
                  ),
                  trailing: Icon(Icons.calendar_today, color: Color(0xFF8B5CF6)),
                  onTap: () => _selectDate(context, false),
                ),
                SizedBox(height: 16),
                Text(
                  'Item yang Dipinjam',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                ..._items.map((item) => ListTile(
                      title: Text(
                        'Unit ID: ${item['item_unit_id']}',
                        style: GoogleFonts.poppins(color: Colors.white),
                      ),
                      subtitle: Text(
                        'Jumlah: ${item['quantity']}',
                        style: GoogleFonts.poppins(color: Colors.grey[400]),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.remove_circle, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _items.remove(item);
                          });
                        },
                      ),
                    )),
                    ElevatedButton(
                      onPressed: () => context.push('/item-units-select', extra: (Map<String, dynamic> item) {
                        setState(() {
                          _items.add(item);
                        });
                      }),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF8B5CF6),
                        foregroundColor: Colors.white,
                      ),
                      child: Text('Tambah Item', style: GoogleFonts.poppins()),
                    ),
                SizedBox(height: 24),
                _isLoading
                    ? Center(child: CircularProgressIndicator(color: Color(0xFF8B5CF6)))
                    : ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF8B5CF6),
                          foregroundColor: Colors.white,
                          minimumSize: Size(double.infinity, 50),
                        ),
                        child: Text('Ajukan Peminjaman', style: GoogleFonts.poppins()),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}