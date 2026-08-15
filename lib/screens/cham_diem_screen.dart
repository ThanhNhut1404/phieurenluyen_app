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
        }

        // Parse minh chứng đã nộp (nếu có)
        if (_phieuData!['minh_chung_da_nop'] != null) {
          for (var mc in _phieuData!['minh_chung_da_nop']) {
            _minhChung[int.parse(mc['id_muc'].toString())] = mc['hinh_anh'];
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
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể chọn ảnh.')),
      );
    }
  }

  void _submit() async {
    // Validate: Kiểm tra các mục bắt buộc minh chứng
    bool hasError = false;
    String errorMsg = '';

    for (var dieu in _phieuData!['tieu_chi']) {
      for (var khoan in dieu['khoan']) {
        for (var muc in khoan['muc']) {
          if (muc['quyen_sv'] == 1 && muc['co_minh_chung'] == 1) {
            int idMuc = int.parse(muc['id_muc'].toString());
            // Chỉ yêu cầu minh chứng nếu có nhập điểm > 0
            if ((_diemDaCham[idMuc] ?? 0) > 0 && !_minhChung.containsKey(idMuc)) {
              hasError = true;
              errorMsg = 'Vui lòng bổ sung minh chứng cho mục: ${muc['ten_muc']}';
              break;
            }
          }
        }
        if (hasError) break;
      }
      if (hasError) break;
    }

    if (hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
      );
      return;
    }

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
                                                          enabled: isQuyenSv,
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
                                                            if (d != null && d >= 0 && d <= maxDiem) {
                                                              _diemDaCham[idMuc] = d;
                                                            } else if (val.isEmpty) {
                                                              _diemDaCham.remove(idMuc);
                                                            }
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  if (coMinhChung && isQuyenSv)
                                                    Padding(
                                                      padding: const EdgeInsets.only(top: 8.0),
                                                      child: Row(
                                                        children: [
                                                          ElevatedButton.icon(
                                                            onPressed: () => _pickImage(idMuc),
                                                            icon: const Icon(Icons.upload_file, size: 16),
                                                            label: const Text('Minh chứng', style: TextStyle(fontSize: 12)),
                                                            style: ElevatedButton.styleFrom(
                                                              visualDensity: VisualDensity.compact,
                                                              backgroundColor: _minhChung.containsKey(idMuc) ? Colors.green : null,
                                                            ),
                                                          ),
                                                          if (_minhChung.containsKey(idMuc))
                                                            const Padding(
                                                              padding: EdgeInsets.only(left: 8.0),
                                                              child: Icon(Icons.check_circle, color: Colors.green, size: 16),
                                                            )
                                                        ],
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
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, -2))],
                      ),
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: const Color(0xFF3182CE),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(
                          'Lưu kết quả',
                          style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
                  ],
                ),
    );
  }
}
