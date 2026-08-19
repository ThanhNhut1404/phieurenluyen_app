import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phieurenluyen_app/services/api_service.dart';
import 'package:phieurenluyen_app/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  bool _isLoadingProfile = true;
  String _userName = 'Sinh viên';
  Map<String, dynamic>? _profileData;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    setState(() => _isLoadingProfile = true);
    final response = await ApiService.getProfile();
    
    if (mounted) {
      if (response['status'] == 'success') {
        final data = response['data'];
        setState(() {
          _profileData = data;
          _userName = data['ten_sinh_vien'] ?? 'Sinh viên';
          _isLoadingProfile = false;
        });
        
        // Cập nhật lại cache để màn hình khác dùng
        final prefs = await SharedPreferences.getInstance();
        if (data['anh_dai_dien'] != null) {
          await prefs.setString('user_avatar', data['anh_dai_dien']);
        }
      } else {
        setState(() => _isLoadingProfile = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Lỗi lấy thông tin')),
        );
      }
    }
  }

  Future<void> _pickAndUploadAvatar() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);

    if (image != null) {
      setState(() => _isLoadingProfile = true);
      
      final response = await ApiService.uploadAvatar(image);
      
      if (mounted) {
        if (response['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cập nhật ảnh đại diện thành công!'), backgroundColor: Colors.green),
          );
          _fetchProfile(); // Reload
        } else {
          setState(() => _isLoadingProfile = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['message'] ?? 'Lỗi tải ảnh'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  void _showProfileInfo() {
    if (_profileData == null) return;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.9,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: (_profileData?['anh_dai_dien'] != null && _profileData?['anh_dai_dien'].toString().isNotEmpty == true)
                            ? NetworkImage(ApiService.baseUrl.replaceAll('api/', '') + _profileData!['anh_dai_dien'].toString() + "?v=${DateTime.now().millisecondsSinceEpoch}") 
                            : const NetworkImage('https://i.pravatar.cc/150?img=11') as ImageProvider,
                      ),
                      const SizedBox(height: 12),
                      Text('Hồ sơ Sinh viên', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF157F1F))),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildInfoRow('Mã sinh viên', _profileData!['ma_sinh_vien']?.toString()),
                        _buildInfoRow('Họ và tên', _profileData!['ten_sinh_vien']?.toString()),
                        _buildInfoRow('Ngày sinh', _profileData!['ngay_sinh']?.toString()),
                        _buildInfoRow('Giới tính', _profileData!['gioi_tinh']?.toString()),
                        _buildInfoRow('Điện thoại', _profileData!['so_dien_thoai_1']?.toString()),
                        _buildInfoRow('Email', _profileData!['email']?.toString()),
                        _buildInfoRow('Chức vụ', _profileData!['chuc_vu']?.toString()),
                        _buildInfoRow('Lớp', _profileData!['ten_lop_hoc']?.toString()),
                        _buildInfoRow('Ngành', _profileData!['ten_nganh_hoc']?.toString()),
                        _buildInfoRow('Khoa', _profileData!['ten_khoa']?.toString()),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 105,
            child: Text(label, style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 14)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              (value == null || value.isEmpty) ? 'Đang cập nhật' : value, 
              style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87)
            ),
          ),
        ],
      ),
    );
  }

  // Khúc code đổi mật khẩu giữ nguyên logic cũ
  bool _isValidPassword(String password) {
    final regex = RegExp(r'^(?=.*[a-zA-Z])(?=.*\d)(?=.*[!@#\$&*~]).{9,}$');
    return regex.hasMatch(password);
  }

  Future<void> _handleLogout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ApiService.logout();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    _oldPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text('Đổi mật khẩu', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(controller: _oldPasswordController, obscureText: true, decoration: const InputDecoration(labelText: 'Mật khẩu cũ', border: OutlineInputBorder())),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _newPasswordController, obscureText: true, 
                      decoration: const InputDecoration(labelText: 'Mật khẩu mới', border: OutlineInputBorder(), helperText: 'Tối thiểu 9 ký tự, có chữ, số & ký tự đặc biệt.', helperMaxLines: 2),
                    ),
                    const SizedBox(height: 16),
                    TextField(controller: _confirmPasswordController, obscureText: true, decoration: const InputDecoration(labelText: 'Xác nhận mật khẩu mới', border: OutlineInputBorder())),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
                ElevatedButton(
                  onPressed: _isLoading ? null : () async {
                    final oldPass = _oldPasswordController.text;
                    final newPass = _newPasswordController.text;
                    final confirmPass = _confirmPasswordController.text;

                    if (oldPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin!')));
                      return;
                    }
                    if (newPass != confirmPass) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mật khẩu xác nhận không khớp!')));
                      return;
                    }
                    if (!_isValidPassword(newPass)) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mật khẩu phải có ít nhất 9 ký tự, bao gồm chữ cái, số và ký tự đặc biệt (!@#\$&*~).')));
                      return;
                    }
                    
                    setStateDialog(() => _isLoading = true);
                    final result = await ApiService.changePassword(oldPass, newPass);
                    setStateDialog(() => _isLoading = false);

                    if (result['status'] == 'success') {
                      if (mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đổi mật khẩu thành công! Vui lòng đăng nhập lại.'), backgroundColor: Colors.green));
                        await ApiService.logout();
                        if (mounted) {
                          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
                        }
                      }
                    } else {
                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message'] ?? 'Có lỗi xảy ra'), backgroundColor: Colors.red));
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF157F1F)),
                  child: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Xác nhận', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          }
        );
      },
    );
  }

  Widget _buildAvatar() {
    String? avatarUrl = _profileData?['anh_dai_dien'];
    
    return Stack(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.grey[200],
          backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
            ? NetworkImage(ApiService.baseUrl.replaceAll('api/', '') + avatarUrl + "?v=${DateTime.now().millisecondsSinceEpoch}") 
            : const NetworkImage('https://i.pravatar.cc/150?img=11') as ImageProvider,
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: _pickAndUploadAvatar,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF157F1F),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))
                ]
              ),
              child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return _isLoadingProfile 
      ? const Center(child: CircularProgressIndicator(color: Color(0xFF157F1F)))
      : SingleChildScrollView(
          child: Column(
            children: [
              // Header Profile
              Container(
                color: Colors.white,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                child: Column(
                  children: [
                    _buildAvatar(),
                    const SizedBox(height: 16),
                    Text(
                      _userName,
                      style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      (_profileData?['chuc_vu'] == null || _profileData?['chuc_vu'] == '') 
                          ? 'Sinh viên' 
                          : _profileData!['chuc_vu'].toString(),
                      style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Menu Options
              Container(
                color: Colors.white,
                child: Column(
                  children: [
                    _buildMenuTile(
                      icon: Icons.person_outline,
                      title: 'Thông tin cá nhân',
                      onTap: _showProfileInfo, // Gọi bottom sheet
                    ),
                    const Divider(height: 1, indent: 56),
                    _buildMenuTile(
                      icon: Icons.lock_outline,
                      title: 'Đổi mật khẩu',
                      onTap: _showChangePasswordDialog,
                    ),
                    const Divider(height: 1, indent: 56),
                    _buildMenuTile(
                      icon: Icons.settings_outlined,
                      title: 'Cài đặt',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Logout Section
              Container(
                color: Colors.white,
                child: _buildMenuTile(
                  icon: Icons.logout,
                  title: 'Đăng xuất',
                  color: Colors.red,
                  onTap: _handleLogout,
                ),
              ),
            ],
          ),
        );
  }

  Widget _buildMenuTile({required IconData icon, required String title, required VoidCallback onTap, Color? color}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (color ?? const Color(0xFF157F1F)).withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color ?? const Color(0xFF157F1F)),
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: color ?? Colors.black87,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}
