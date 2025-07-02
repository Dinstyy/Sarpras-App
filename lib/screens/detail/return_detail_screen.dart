import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sarpras_app/services/dio_service.dart';
import 'package:intl/intl.dart';
import 'package:sarpras_app/models/return_request.dart';
import 'package:sarpras_app/services/api_services/return_request_service.dart';

class ReturnDetailScreen extends ConsumerStatefulWidget {
  final int returnId;

  const ReturnDetailScreen({Key? key, required this.returnId}) : super(key: key);

  @override
  ConsumerState<ReturnDetailScreen> createState() => _ReturnDetailScreenState();
}

class _ReturnDetailScreenState extends ConsumerState<ReturnDetailScreen> {
  late Future<ReturnRequest> _returnFuture;

  @override
  void initState() {
    super.initState();
    _returnFuture = ReturnRequestService(DioService()).getById(widget.returnId);
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
          'Detail Pengembalian',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
      ),
      body: FutureBuilder<ReturnRequest>(
        future: _returnFuture,
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
          final returnRequest = snapshot.data!;
          return Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pengembalian #${returnRequest.id}',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Tanggal: ${DateFormat('dd/MM/yyyy').format(returnRequest.createdAt)}',
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
                Text(
                  'Status: ${returnRequest.status}',
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
                if (returnRequest.rejectionReason != null)
                  Text(
                    'Alasan Ditolak: ${returnRequest.rejectionReason}',
                    style: GoogleFonts.poppins(color: Colors.red),
                  ),
                SizedBox(height: 16),
                Text(
                  'Item yang Dikembalikan',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                ...?returnRequest.returnDetails?.map((detail) => ListTile(
                      title: Text(
                        detail.itemUnit?.item?.name ?? 'Unknown',
                        style: GoogleFonts.poppins(color: Colors.white),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Jumlah: ${detail.quantity}',
                            style: GoogleFonts.poppins(color: Colors.grey[400]),
                          ),
                          Text(
                            'Kondisi: ${detail.condition}',
                            style: GoogleFonts.poppins(color: Colors.grey[400]),
                          ),
                          if (detail.photo != null)
                            Image.network(
                              detail.photo!,
                              height: 100,
                              width: 100,
                            ),
                        ],
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