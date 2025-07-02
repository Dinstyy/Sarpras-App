import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sarpras_app/services/api_services/borrow_request_service.dart';
import 'package:sarpras_app/services/dio_service.dart';
import 'package:intl/intl.dart';
import 'package:sarpras_app/models/borrow_request.dart';
import 'package:sarpras_app/models/return_request.dart';
import 'package:sarpras_app/services/api_services/return_request_service.dart';
import 'package:sarpras_app/providers/auth_provider.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  final String? filter;

  const HistoryScreen({Key? key, this.filter}) : super(key: key);

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  late Future<List<dynamic>> _historyFuture;

  @override
  void initState() {
    super.initState();
    final userId = ref.read(authProvider).userData?.id ?? 0;
    if (widget.filter == 'returned') {
      _historyFuture = ReturnRequestService(DioService()).getUserReturnHistory(userId);
    } else {
      _historyFuture = BorrowRequestService(DioService()).getUserBorrowHistory(userId, status: 'returned');
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
          widget.filter == 'returned' ? 'Riwayat Pengembalian' : 'Riwayat Peminjaman',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _historyFuture,
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
          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return Center(
              child: Text(
                widget.filter == 'returned'
                    ? 'Tidak ada riwayat pengembalian'
                    : 'Tidak ada riwayat peminjaman',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            );
          }
          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              if (widget.filter == 'returned') {
                final returnRequest = item as ReturnRequest;
                return Card(
                  color: Colors.grey[900],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    title: Text(
                      'Pengembalian #${returnRequest.id}',
                      style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Status: ${returnRequest.status} | ${DateFormat('dd/MM/yyyy').format(returnRequest.createdAt)}',
                      style: GoogleFonts.poppins(color: Colors.grey[400]),
                    ),
                    trailing: returnRequest.status == 'rejected'
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Ditolak: ${returnRequest.rejectionReason}',
                                style: GoogleFonts.poppins(color: Colors.red),
                              ),
                              SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () => context.push('/return-request', extra: returnRequest.borrowRequestId),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF8B5CF6),
                                  foregroundColor: Colors.white,
                                ),
                                child: Text('Ajukan Lagi', style: GoogleFonts.poppins()),
                              ),
                            ],
                          )
                        : null,
                    onTap: () => context.push('/return-requests/${returnRequest.id}'),
                  ),
                );
              } else {
                final borrowRequest = item as BorrowRequest;
                return Card(
                  color: Colors.grey[900],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    title: Text(
                      borrowRequest.reason,
                      style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Status: ${borrowRequest.status} | ${DateFormat('dd/MM/yyyy').format(borrowRequest.borrowDateExpected)}',
                      style: GoogleFonts.poppins(color: Colors.grey[400]),
                    ),
                    onTap: () => context.push('/borrow-requests/${borrowRequest.id}'),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}