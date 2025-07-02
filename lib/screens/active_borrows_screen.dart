import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sarpras_app/services/api_services/borrow_request_service.dart';
import 'package:sarpras_app/services/dio_service.dart';
import 'package:intl/intl.dart';
import 'package:sarpras_app/models/borrow_request.dart';
import 'package:sarpras_app/models/paginate_response.dart';
import 'package:sarpras_app/providers/auth_provider.dart';

class ActiveBorrowsScreen extends ConsumerStatefulWidget {
  const ActiveBorrowsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ActiveBorrowsScreen> createState() => _ActiveBorrowsScreenState();
}

class _ActiveBorrowsScreenState extends ConsumerState<ActiveBorrowsScreen> {
  late Future<PaginateResponse<BorrowRequest>> _borrowsFuture;

@override
void initState() {
  super.initState();
  final authState = ref.read(authProvider);
  final userId = authState.userData?.id;
  print('User ID from authProvider: $userId'); // Debug log
  if (userId == null) {
    _borrowsFuture = Future.error('User not authenticated. Please log in.');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.pushReplacement('/login');
      }
    });
  } else {
    _borrowsFuture = BorrowRequestService(DioService()).getActiveBorrows(userId);
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
          'Peminjaman Aktif',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
      ),
      body: FutureBuilder<PaginateResponse<BorrowRequest>>(
        future: _borrowsFuture,
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
          final borrows = snapshot.data?.data ?? [];
          if (borrows.isEmpty) {
            return Center(
              child: Text(
                'Tidak ada peminjaman aktif',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            );
          }
          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: borrows.length,
            itemBuilder: (context, index) {
              final borrow = borrows[index];
              if (borrow.id == null) {
                return Center(
                  child: Text(
                    'ID peminjaman tidak valid',
                    style: GoogleFonts.poppins(color: Colors.white),
                  ),
                );
              }
              return Card(
                color: Colors.grey[900],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  title: Text(
                    borrow.reason,
                    style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Status: ${borrow.status} | ${DateFormat('dd/MM/yyyy').format(borrow.borrowDateExpected)}',
                    style: GoogleFonts.poppins(color: Colors.grey[400]),
                  ),
                  trailing: borrow.status == 'approved'
                      ? ElevatedButton(
                          onPressed: () => context.push('/return-request', extra: borrow.id),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF8B5CF6),
                            foregroundColor: Colors.white,
                          ),
                          child: Text('Kembalikan', style: GoogleFonts.poppins()),
                        )
                      : borrow.status == 'rejected'
                          ? Text(
                              'Ditolak: ${borrow.rejectionReason}',
                              style: GoogleFonts.poppins(color: Colors.red),
                            )
                          : null,
                  onTap: () => context.push('/borrow-requests/${borrow.id}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}