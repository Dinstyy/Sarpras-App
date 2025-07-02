import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sarpras_app/services/dio_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sarpras_app/services/api_services/return_request_service.dart';
import 'package:sarpras_app/services/api_services/borrow_request_service.dart';
import 'package:sarpras_app/providers/auth_provider.dart';
import 'package:sarpras_app/models/borrow_request.dart';
import 'package:dio/dio.dart'; // Impor untuk MultipartFile

class ReturnRequestScreen extends ConsumerStatefulWidget {
  final int? borrowId;

  const ReturnRequestScreen({Key? key, this.borrowId}) : super(key: key);

  @override
  ConsumerState<ReturnRequestScreen> createState() => _ReturnRequestScreenState();
}

class _ReturnRequestScreenState extends ConsumerState<ReturnRequestScreen> {
  late Future<BorrowRequest> _borrowFuture;
  final TextEditingController _notesController = TextEditingController();
  File? _selectedImage;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.borrowId != null) {
      _borrowFuture = BorrowRequestService(DioService()).getById(widget.borrowId!);
    } else {
      _borrowFuture = Future.error('No borrow ID provided');
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitReturnRequest() async {
    if (widget.borrowId != null) {
      final service = ReturnRequestService(DioService());
      try {
        final formData = FormData.fromMap({
          'borrow_request_id': widget.borrowId,
          'notes': _notesController.text,
          'items': [], // Tambahkan logika item jika diperlukan
        });
        if (_selectedImage != null) {
          formData.files.add(
            MapEntry(
              'image',
              await MultipartFile.fromFile(_selectedImage!.path, filename: 'return_proof.jpg'),
            ),
          );
        }
        await service.create(
          borrowRequestId: widget.borrowId!,
          notes: _notesController.text,
          items: [], // Sesuaikan dengan kebutuhan API
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Permintaan pengembalian berhasil diajukan')),
          );
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
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
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Ajukan Pengembalian',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
      ),
      body: FutureBuilder<BorrowRequest>(
        future: _borrowFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF8B5CF6)));
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            );
          }
          final borrow = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Alasan Peminjaman: ${borrow.reason}',
                    style: GoogleFonts.poppins(color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _notesController,
                    decoration: InputDecoration(
                      labelText: 'Catatan Pengembalian',
                      labelStyle: GoogleFonts.poppins(color: Colors.grey[400]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[700]!),
                      ),
                    ),
                    style: GoogleFonts.poppins(color: Colors.white),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),
                  _selectedImage == null
                      ? ElevatedButton(
                          onPressed: _pickImage,
                          style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF8B5CF6), foregroundColor: Colors.white),
                          child: Text('Unggah Foto Bukti', style: GoogleFonts.poppins()),
                        )
                      : Column(
                          children: [
                            Image.file(
                              _selectedImage!,
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                            TextButton(
                              onPressed: _pickImage,
                              child: Text('Ganti Foto', style: GoogleFonts.poppins(color: Color(0xFF8B5CF6))),
                            ),
                          ],
                        ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _submitReturnRequest,
                    style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF8B5CF6), foregroundColor: Colors.white),
                    child: Text('Ajukan', style: GoogleFonts.poppins()),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}