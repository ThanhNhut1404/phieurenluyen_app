import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phieurenluyen_app/screens/cham_diem_screen.dart';
import 'package:phieurenluyen_app/screens/profile_screen.dart';

import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final Color primaryGreen = const Color(0xFF157F1F); // Màu xanh trường học
  String _userName = 'Sinh viên';

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_name') ?? 'Sinh viên';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA), // Nền xám nhạt
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildDashboard(context), // 0: Trang chủ
          const Center(child: Text('Lịch RL đang cập nhật...')), // 1: Lịch RL
          const Center(child: Text('Điểm danh đang cập nhật...')), // 2: Điểm danh
          const ProfileScreen(), // 3: Cá nhân
        ],
      ),
      
      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2))
          ]
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: primaryGreen,
          unselectedItemColor: Colors.grey[500],
          selectedLabelStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500),
          backgroundColor: Colors.white,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Lịch RL'),
            BottomNavigationBarItem(icon: Icon(Icons.fact_check_outlined), label: 'Điểm danh'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Cá nhân'),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboard(BuildContext context) {
    return Column(
      children: [
        // Phần Header xanh và Thẻ đè lên
        Stack(
          clipBehavior: Clip.none,
          children: [
            // Header màu xanh
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: primaryGreen,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar
                      const CircleAvatar(
                        radius: 22,
                        backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11'),
                      ),
                      const SizedBox(width: 12),
                      // Tên sinh viên
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Xin chào, $_userName',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      // Nút thông báo
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.notifications, color: Colors.white, size: 20),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Thẻ Thông báo nổi (Overlapping Card)
            Positioned(
              top: 140,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    // Icon/Hình minh họa
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.campaign, color: Colors.blue, size: 28),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Đợt rèn luyện hiện tại:',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Học kỳ hiện tại',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
        
        // Khoảng trống bù cho thẻ nổi
        const SizedBox(height: 60),
        
        // Nội dung cuộn bên dưới
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tiêu đề Chức năng & Nút Tùy chỉnh
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Chức năng',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E88E5), // Màu xanh dương chữ
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.tune, size: 14, color: Colors.grey[700]),
                            const SizedBox(width: 4),
                            Text(
                              'Tuỳ chỉnh',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Lưới chức năng (4 cột)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Wrap(
                    spacing: 0,
                    runSpacing: 20,
                    alignment: WrapAlignment.start,
                    children: [
                      _buildFunctionIcon(context, Icons.assignment, Colors.blue, 'Chấm điểm\nRèn luyện', () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const ChamDiemScreen()));
                      }),
                      _buildFunctionIcon(context, Icons.school, Colors.green, 'Xem kết quả', () {}),
                      _buildFunctionIcon(context, Icons.gavel, Colors.orange, 'Quy định', () {}),
                      _buildFunctionIcon(context, Icons.receipt_long, Colors.teal, 'Minh chứng', () {}),
                      _buildFunctionIcon(context, Icons.menu_book, Colors.red, 'Chương trình\nkhung', () {}),
                      _buildFunctionIcon(context, Icons.calendar_month, Colors.deepOrange, 'Lịch học/\nlịch thi', () {}),
                      _buildFunctionIcon(context, Icons.pie_chart, Colors.amber[700]!, 'Thống kê', () {}),
                      _buildFunctionIcon(context, Icons.grid_view, Colors.blue[800]!, 'Tất cả', () {}),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Khu vực Banner quảng cáo
                SizedBox(
                  height: 120,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _buildBannerCard('https://images.unsplash.com/photo-1523240795612-9a054b0db644?q=80&w=2070&auto=format&fit=crop'), // Ảnh sinh viên đại học
                      _buildBannerCard('https://images.unsplash.com/photo-1517245386807-bb43f82c33c4?q=80&w=2070&auto=format&fit=crop'), // Ảnh phòng máy
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Hàm tạo Icon Chức năng (4 ô 1 hàng)
  Widget _buildFunctionIcon(BuildContext context, IconData icon, Color color, String title, VoidCallback onTap) {
    double itemWidth = MediaQuery.of(context).size.width / 4 - 4; // Chia đều 4 cột
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: itemWidth,
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ],
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Hàm tạo Banner Cuộn ngang
  Widget _buildBannerCard(String imageUrl) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
