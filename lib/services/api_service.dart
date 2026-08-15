import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Nếu chạy máy ảo Android, dùng 10.0.2.2 thay cho localhost.
  // Đang chạy nội bộ trên Chrome nên dùng localhost
  static const String baseUrl = 'http://localhost/phieurenluyen/api/';

  // Lấy header chuẩn, bao gồm cả Token nếu đã lưu
  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // Hàm đăng nhập
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final url = Uri.parse('${baseUrl}login.php');
      final headers = await _getHeaders();
      final body = jsonEncode({
        'email': email,
        'password': password,
      });

      final response = await http.post(url, headers: headers, body: body)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        
        // Kiểm tra status từ JSON trả về
        if (decoded['status'] == 'success') {
          // Lưu token nếu có trong data
          if (decoded['data'] != null && decoded['data']['token'] != null) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('token', decoded['data']['token']);
            
            // Lưu thêm thông tin user
            if (decoded['data']['user'] != null) {
              final user = decoded['data']['user'];
              final name = user['ten_sinh_vien'] ?? 'Sinh viên';
              final email = user['email'] ?? '';
              
              await prefs.setString('user_name', name);
              await prefs.setString('user_email', email);
            }
          }
        }
        
        return decoded; // Trả về toàn bộ decoded object (status, message, data...)
      } else {
        return {
          'status': 'error',
          'message': 'Lỗi server (Mã: ${response.statusCode})',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Lỗi kết nối: ${e.toString()}',
      };
    }
  }

  // Hàm lấy phiếu chấm điểm hiện tại
  static Future<Map<String, dynamic>> getPhieuChamDiem() async {
    try {
      final url = Uri.parse('${baseUrl}get_phieu_cham_diem.php');
      final headers = await _getHeaders();

      final response = await http.get(url, headers: headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Lỗi server (Mã: ${response.statusCode})',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Lỗi kết nối: ${e.toString()}',
      };
    }
  }

  // Hàm gửi kết quả chấm điểm và minh chứng
  static Future<Map<String, dynamic>> submitChamDiem(int idPhieu, List<String> kqSv, List<Map<String, dynamic>> minhChung) async {
    try {
      final url = Uri.parse('${baseUrl}cham_diem.php');
      final headers = await _getHeaders();
      final body = jsonEncode({
        'id_phieu': idPhieu,
        'kq_sv': kqSv,
        'minh_chung': minhChung,
      });

      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Lỗi server (Mã: ${response.statusCode})',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Lỗi kết nối: ${e.toString()}',
      };
    }
  }

  // Hàm yêu cầu kích hoạt tài khoản
  static Future<Map<String, dynamic>> yeuCauKichHoat(String email) async {
    try {
      final url = Uri.parse('${baseUrl}yeu_cau_kich_hoat.php');
      final headers = await _getHeaders();
      final body = jsonEncode({
        'email': email,
      });

      final response = await http.post(url, headers: headers, body: body)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Lỗi server (Mã: ${response.statusCode})',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Lỗi kết nối: ${e.toString()}',
      };
    }
  }

  // Hàm quên mật khẩu (gửi OTP)
  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final url = Uri.parse('${baseUrl}forgot_password.php');
      final headers = await _getHeaders();
      final body = jsonEncode({
        'email': email,
      });

      final response = await http.post(url, headers: headers, body: body)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Lỗi server (Mã: ${response.statusCode})',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Lỗi kết nối: ${e.toString()}',
      };
    }
  }

  // Hàm khôi phục mật khẩu (xác minh OTP & đổi pass)
  static Future<Map<String, dynamic>> resetPassword(String email, String otpCode, String newPassword) async {
    try {
      final url = Uri.parse('${baseUrl}reset_password.php');
      final headers = await _getHeaders();
      final body = jsonEncode({
        'email': email,
        'otp_code': otpCode,
        'new_password': newPassword,
      });

      final response = await http.post(url, headers: headers, body: body)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Lỗi server (Mã: ${response.statusCode})',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Lỗi kết nối: ${e.toString()}',
      };
    }
  }

  // Hàm đổi mật khẩu
  static Future<Map<String, dynamic>> changePassword(String oldPassword, String newPassword) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('${baseUrl}change_password.php');
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode({
          'old_password': oldPassword,
          'new_password': newPassword,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  // Hàm đăng xuất
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user_name');
    await prefs.remove('user_email');
  }
}
