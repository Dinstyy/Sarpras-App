import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sarpras_app/services/api_services/borrow_request_service.dart';
import 'package:sarpras_app/services/dio_service.dart';
import 'package:intl/intl.dart';
import 'package:sarpras_app/models/borrow_request.dart';

class BorrowDetailScreen extends ConsumerStatefulWidget {
  final int borrowId;

  const BorrowDetailScreen({Key? key, required this.borrowId}) : super(key: key);

  @override
  ConsumerState<BorrowDetailScreen> createState() => _BorrowDetailScreenState();
}

class _BorrowDetailScreenState extends ConsumerState<BorrowDetailScreen> {
  late Future<BorrowRequest> _borrowFuture;

  @override
  void initState() {
    super.initState();
    _borrowFuture = BorrowRequestService(DioService()).getById(widget.borrowId);
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
          'Detail Peminjaman',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
      ),
      body: FutureBuilder<BorrowRequest>(
        future: _borrowFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Color(0xFF8B5CF6)));
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
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Peminjaman #${borrow.id}',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Alasan: ${borrow.reason}',
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
                Text(
                  'Tanggal Pinjam: ${DateFormat('dd/MM/yyyy').format(borrow.borrowDateExpected)}',
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
                Text(
                  'Tanggal Kembali: ${DateFormat('dd/MM/yyyy').format(borrow.returnDateExpected)}',
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
                Text(
                  'Status: ${borrow.status}',
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
                if (borrow.rejectionReason != null)
                  Text(
                    'Alasan Ditolak: ${borrow.rejectionReason}',
                    style: GoogleFonts.poppins(color: Colors.red),
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
                ...?borrow.borrowDetails?.map((detail) => ListTile(
                      title: Text(
                        detail.itemUnit?.item?.name ?? 'Unknown',
                        style: GoogleFonts.poppins(color: Colors.white),
                      ),
                      subtitle: Text(
                        'Jumlah: ${detail.quantity}',
                        style: GoogleFonts.poppins(color: Colors.grey[400]),
                      ),
                    )),
              ],
            ),
          );
        },
      ),
    );
  }
}