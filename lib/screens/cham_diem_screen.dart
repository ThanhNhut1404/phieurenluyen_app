import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phieurenluyen_app/services/api_service.dart';

class ChamDiemScreen extends StatefulWidget {
  const ChamDiemScreen({super.key});

  @override
  State<ChamDiemScreen> createState() => _ChamDiemScreenState();
}

class _ChamDiemScreenState extends State<ChamDiemScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _phieuData;
  
  // State lưu điểm: Map<idMuc, diem>
  final Map<int, int> _diemDaCham = {};
  
  // State lưu minh chứng: Map<idMuc, base64String>
  final Map<int, String> _minhChung = {};
  
  // State lưu tên file minh chứng: Map<idMuc, fileName>
  final Map<int, String> _minhChungName = {};
  
  // Biến kiểm tra xem sinh viên đã chấm điểm chưa
  bool _daChamDiem = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await ApiService.getPhieuChamDiem();
    if (!mounted) return;

    if (response['status'] == 'success') {
      setState(() {
        _phieuData = response['data'];
        
        // Parse điểm đã chấm (nếu có)
        if (_phieuData!['kq_sv_da_cham'] != null) {
          for (String kq in _phieuData!['kq_sv_da_cham']) {
            if (kq.isNotEmpty && kq.contains('-')) {
              var parts = kq.split('-');
              _diemDaCham[int.parse(parts[0])] = int.parse(parts[1]);
            }
          }
          if (_diemDaCham.isNotEmpty) {
            _daChamDiem = true;
          }
        }

        // Parse minh chứng đã nộp (nếu có)
        if (_phieuData!['minh_chung_da_nop'] != null) {
          for (var mc in _phieuData!['minh_chung_da_nop']) {
            int idMuc = int.parse(mc['id_muc'].toString());
            _minhChung[idMuc] = mc['hinh_anh'];
            // Lấy tên file từ đường dẫn
            String filePath = mc['hinh_anh'].toString();
            _minhChungName[idMuc] = filePath.contains('/') ? filePath.split('/').last : filePath;
          }
        }
        
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = response['message'];
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage(int idMuc) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800, // Nén ảnh để không quá nặng
        imageQuality: 60,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        final base64String = 'data:image/jpeg;base64,' + base64Encode(bytes);
        setState(() {
          _minhChung[idMuc] = base64String;
          _minhChungName[idMuc] = image.name;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể chọn ảnh.')),
      );
    }
  }

  void _confirmSubmit() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text('Xác nhận lưu', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: const Color(0xFF2B6CB0), fontSize: 18)),
          content: Text(
            _daChamDiem 
                ? 'Bạn có chắc chắn muốn lưu cập nhật minh chứng này không?'
                : 'Bạn có chắc chắn muốn lưu kết quả chấm điểm này không? Sau khi lưu, bạn sẽ không thể thay đổi điểm số, chỉ có thể bổ sung minh chứng.', 
            style: GoogleFonts.plusJakartaSans(fontSize: 14)
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Hủy', style: GoogleFonts.plusJakartaSans(color: Colors.grey[600], fontWeight: FontWeight.w600)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _submit();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3182CE),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('Đồng ý', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _submit() async {
    // Đã bỏ qua validate bắt buộc có minh chứng theo yêu cầu

    setState(() {
      _isLoading = true;
    });

    // Format kết quả
    List<String> kqSv = _diemDaCham.entries.map((e) => '${e.key}-${e.value}').toList();
    List<Map<String, dynamic>> minhChungList = _minhChung.entries.map((e) => {
      'id_muc': e.key,
      'base64': e.value,
    }).toList();

    int idPhieu = int.parse(_phieuData!['id_phieu'].toString());

    final response = await ApiService.submitChamDiem(idPhieu, kqSv, minhChungList);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (response['status'] == 'success') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lưu điểm thành công!'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'] ?? 'Có lỗi xảy ra'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Chấm điểm', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF2B6CB0), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color(0xFF2D3748)),
        elevation: 0,
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _phieuData!['tieu_chi'].length,
                        itemBuilder: (context, index) {
                          var dieu = _phieuData!['tieu_chi'][index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    dieu['ten_dieu'],
                                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 16, color: const Color(0xFF2B6CB0)),
                                  ),
                                  const SizedBox(height: 8),
                                  ...dieu['khoan'].map<Widget>((khoan) {
                                    return Padding(
                                      padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            khoan['ten_khoan'],
                                            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, color: const Color(0xFF4A5568)),
                                          ),
                                          const SizedBox(height: 4),
                                          ...khoan['muc'].map<Widget>((muc) {
                                            int idMuc = int.parse(muc['id_muc'].toString());
                                            bool isQuyenSv = muc['quyen_sv'] == 1;
                                            int maxDiem = int.parse(muc['diem_toi_da'].toString());
                                            bool coMinhChung = muc['co_minh_chung'] == 1;

                                            return Container(
                                              margin: const EdgeInsets.symmetric(vertical: 4),
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.grey[50],
                                                borderRadius: BorderRadius.circular(8),
                                                border: Border.all(color: Colors.grey[200]!),
                                              ),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          muc['ten_muc'],
                                                          style: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.black87),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      SizedBox(
                                                        width: 60,
                                                        child: TextFormField(
                                                          enabled: isQuyenSv && !_daChamDiem,
                                                          initialValue: _diemDaCham[idMuc]?.toString() ?? '',
                                                          keyboardType: TextInputType.number,
                                                          textAlign: TextAlign.center,
                                                          decoration: InputDecoration(
                                                            isDense: true,
                                                            contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                                                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
                                                            hintText: 'Max: $maxDiem',
                                                            hintStyle: const TextStyle(fontSize: 10),
                                                          ),
                                                          onChanged: (val) {
                                                            int? d = int.tryParse(val);
                                                            setState(() {
                                                              if (d != null && d >= 0 && d <= maxDiem) {
                                                                _diemDaCham[idMuc] = d;
                                                              } else if (val.isEmpty) {
                                                                _diemDaCham.remove(idMuc);
                                                              }
                                                            });
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  if (coMinhChung && isQuyenSv)
                                                    Padding(
                                                      padding: const EdgeInsets.only(top: 12.0),
                                                      child: _minhChung.containsKey(idMuc)
                                                          ? Container(
                                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                              decoration: BoxDecoration(
                                                                color: Colors.green.withOpacity(0.05),
                                                                border: Border.all(color: Colors.green.withOpacity(0.3)),
                                                                borderRadius: BorderRadius.circular(8),
                                                              ),
                                                              child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                children: [
                                                                  Expanded(
                                                                    child: Row(
                                                                      children: [
                                                                        const Icon(Icons.check_circle, color: Colors.green, size: 20),
                                                                        const SizedBox(width: 8),
                                                                        Expanded(
                                                                          child: Text(
                                                                            _minhChungName[idMuc] ?? 'Đã đính kèm minh chứng',
                                                                            style: GoogleFonts.plusJakartaSans(
                                                                              fontSize: 13,
                                                                              color: Colors.green[700],
                                                                              fontWeight: FontWeight.w600,
                                                                            ),
                                                                            maxLines: 1,
                                                                            overflow: TextOverflow.ellipsis,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  const SizedBox(width: 8),
                                                                  Row(
                                                                    children: [
                                                                      IconButton(
                                                                        icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 20),
                                                                        onPressed: () => _pickImage(idMuc),
                                                                        constraints: const BoxConstraints(),
                                                                        padding: const EdgeInsets.all(4),
                                                                        tooltip: 'Thay thế',
                                                                      ),
                                                                      const SizedBox(width: 8),
                                                                      IconButton(
                                                                        icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                                                        onPressed: () {
                                                                          setState(() {
                                                                            _minhChung.remove(idMuc);
                                                                            _minhChungName.remove(idMuc);
                                                                          });
                                                                        },
                                                                        constraints: const BoxConstraints(),
                                                                        padding: const EdgeInsets.all(4),
                                                                        tooltip: 'Xóa',
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            )
                                                          : OutlinedButton.icon(
                                                              onPressed: () => _pickImage(idMuc),
                                                              icon: const Icon(Icons.upload_file, size: 18, color: Color(0xFF3182CE)),
                                                              label: Text('Thêm minh chứng', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF3182CE), fontWeight: FontWeight.w600)),
                                                              style: OutlinedButton.styleFrom(
                                                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                                                side: const BorderSide(color: Color(0xFF3182CE)),
                                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                                backgroundColor: const Color(0xFF3182CE).withOpacity(0.05),
                                                                elevation: 0,
                                                              ),
                                                            ),
                                                    )
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2))],
                      ),
                      width: double.infinity,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Tổng điểm đã chấm:',
                                style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                              ),
                              Text(
                                '${_diemDaCham.values.fold<int>(0, (int sum, int item) => sum + item)} / 100',
                                style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF157F1F)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _confirmSubmit,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                backgroundColor: const Color(0xFF3182CE),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: Text(
                                _daChamDiem ? 'Cập nhật minh chứng' : 'Lưu kết quả',
                                style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
    );
  }
}
