import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phieurenluyen_app/services/api_service.dart';

class KetQuaScreen extends StatefulWidget {
  const KetQuaScreen({super.key});

  @override
  State<KetQuaScreen> createState() => _KetQuaScreenState();
}

class _KetQuaScreenState extends State<KetQuaScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<dynamic> _allKetQua = [];
  List<dynamic> _filteredKetQua = [];

  // Danh sách filter
  List<String> _namHocList = ['Tất cả'];
  List<String> _hocKyList = ['Tất cả'];

  String _selectedNamHoc = 'Tất cả';
  String _selectedHocKy = 'Tất cả';

  @override
  void initState() {
    super.initState();
    _fetchKetQua();
  }

  Future<void> _fetchKetQua() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await ApiService.getKetQua();
    if (!mounted) return;

    if (response['status'] == 'success') {
      List<dynamic> data = response['data'] ?? [];
      
      // Trích xuất các năm học và học kỳ duy nhất
      Set<String> namHocs = {};
      Set<String> hocKys = {};
      
      for (var item in data) {
        if (item['ten_nam_hoc'] != null) namHocs.add(item['ten_nam_hoc']);
        if (item['ten_hoc_ky'] != null) hocKys.add(item['ten_hoc_ky']);
      }

      setState(() {
        _allKetQua = data;
        _namHocList = ['Tất cả', ...namHocs.toList()..sort()];
        _hocKyList = ['Tất cả', ...hocKys.toList()..sort()];
        _isLoading = false;
        _applyFilter();
      });
    } else {
      setState(() {
        _errorMessage = response['message'];
        _isLoading = false;
      });
    }
  }

  void _applyFilter() {
    setState(() {
      _filteredKetQua = _allKetQua.where((item) {
        bool matchNamHoc = _selectedNamHoc == 'Tất cả' || item['ten_nam_hoc'] == _selectedNamHoc;
        bool matchHocKy = _selectedHocKy == 'Tất cả' || item['ten_hoc_ky'] == _selectedHocKy;
        return matchNamHoc && matchHocKy;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Kết quả rèn luyện', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF2B6CB0), fontWeight: FontWeight.bold)),
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
                    // Filter Section
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Năm học', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey[600])),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey[300]!),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      isExpanded: true,
                                      value: _selectedNamHoc,
                                      items: _namHocList.map((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 14)),
                                        );
                                      }).toList(),
                                      onChanged: (newValue) {
                                        if (newValue != null) {
                                          setState(() {
                                            _selectedNamHoc = newValue;
                                            _applyFilter();
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Học kỳ', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey[600])),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey[300]!),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      isExpanded: true,
                                      value: _selectedHocKy,
                                      items: _hocKyList.map((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 14)),
                                        );
                                      }).toList(),
                                      onChanged: (newValue) {
                                        if (newValue != null) {
                                          setState(() {
                                            _selectedHocKy = newValue;
                                            _applyFilter();
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Danh sách kết quả
                    Expanded(
                      child: _filteredKetQua.isEmpty
                          ? Center(
                              child: Text(
                                'Không có kết quả nào.',
                                style: GoogleFonts.plusJakartaSans(fontSize: 16, color: Colors.grey[600]),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _filteredKetQua.length,
                              itemBuilder: (context, index) {
                                var item = _filteredKetQua[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${item['ten_dot']} (${item['ten_hoc_ky']} - ${item['ten_nam_hoc']})',
                                          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 16, color: const Color(0xFF2B6CB0)),
                                        ),
                                        const Divider(height: 24),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('Điểm SV tự chấm:', style: GoogleFonts.plusJakartaSans(fontSize: 14, color: Colors.grey[700])),
                                            Text(item['diem_sv'] != null ? '${item['diem_sv']}' : 'Đang chờ', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('Điểm tổng cuối cùng:', style: GoogleFonts.plusJakartaSans(fontSize: 14, color: Colors.grey[700])),
                                            Text((item['tong_diem_xep_loai'] ?? item['diem_gv']) != null ? '${item['tong_diem_xep_loai'] ?? item['diem_gv']}' : 'Đang chờ', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                          decoration: BoxDecoration(
                                            color: Colors.blue[50],
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('Xếp loại:', style: GoogleFonts.plusJakartaSans(fontSize: 14, color: Colors.blue[800], fontWeight: FontWeight.w600)),
                                              Text(
                                                '${item['xep_loai']}',
                                                style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[800]),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
    );
  }
}
