import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Automatically detects Web / Chrome and Mobile Devices
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5000/api';
    }
    return 'http://192.168.43.193:5000/api';
  }

  static Future<Map<String, dynamic>> login(String email, String password, {String? role}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email, 
          'password': password,
          if (role != null) 'role': role,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // ලොග් වීම සාර්ථක නම්, Access Token එක සහ User ID, Email, Name, Phone Save කරගන්න
        SharedPreferences prefs = await SharedPreferences.getInstance();
        if (data['session'] != null) {
          await prefs.setString('token', data['session']['access_token']);
        }
        if (data['user'] != null) {
          final user = data['user'];
          await prefs.setString('user_id', user['id'] ?? '');
          await prefs.setString('email', user['email'] ?? '');

          final userMetadata = user['user_metadata'] ?? {};
          if (userMetadata['full_name'] != null) {
            await prefs.setString('full_name', userMetadata['full_name']);
          }
          if (userMetadata['phone'] != null) {
            await prefs.setString('phone', userMetadata['phone']);
          }
          if (userMetadata['role'] != null) {
            await prefs.setString('user_role', userMetadata['role']);
          } else if (userMetadata['user_role'] != null) {
            await prefs.setString('user_role', userMetadata['user_role']);
          } else if (role != null) {
            await prefs.setString('user_role', role);
          }

          if (userMetadata['profile_image_url'] != null) {
            await prefs.setString('profile_image_url', userMetadata['profile_image_url']);
          }
          if (data['user']['profile_image_url'] != null) {
            await prefs.setString('profile_image_url', data['user']['profile_image_url']);
          }
        }
        
        return {'success': true, 'message': 'ලොග් වීම සාර්ථකයි!', 'user': data['user']};
      } else {
        return {'success': false, 'message': data['error'] ?? 'ලොග් වීමට නොහැකි විය'};
      }
    } catch (e) {
      return {'success': false, 'message': 'සර්වර් එකට සම්බන්ධ වීමට නොහැකි විය: $e'};
    }
  }

  // OTP සංකේතය ඊමේල් එකට යැවීම
  static Future<Map<String, dynamic>> sendRegisterOtp({
    required String fullName,
    required String email,
    required String phone,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/send-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'full_name': fullName,
          'email': email,
          'phone': phone,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'message': data['message'] ?? 'OTP සංකේතය යවන ලදී.'};
      } else {
        return {'success': false, 'message': data['error'] ?? 'OTP සංකේතය යැවීමට නොහැකි විය.'};
      }
    } catch (e) {
      return {'success': false, 'message': 'සර්වර් එකට සම්බන්ධ වීමට නොහැකි විය: $e'};
    }
  }

  // OTP සංකේතය පරීක්ෂා කර ලියාපදිංචි වීම තහවුරු කිරීම
  static Future<Map<String, dynamic>> verifyOtpAndRegister({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String role,
    required String otp,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify-and-register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'full_name': fullName,
          'email': email,
          'phone': phone,
          'password': password,
          'role': role,
          'otp': otp,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (data['user'] != null) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          final user = data['user'];
          await prefs.setString('user_id', user['id'] ?? '');
          await prefs.setString('email', user['email'] ?? email);
          await prefs.setString('full_name', fullName);
          await prefs.setString('phone', phone);
          await prefs.setString('user_role', role);
        }

        return {'success': true, 'message': data['message'] ?? 'සාර්ථකව ලියාපදිංචි විය!'};
      } else {
        return {'success': false, 'message': data['error'] ?? 'ලියාපදිංචි වීමට නොහැකි විය.'};
      }
    } catch (e) {
      return {'success': false, 'message': 'සර්වර් එකට සම්බන්ධ වීමේ ගැටළුවක්: $e'};
    }
  }

  // මුරපදය අමතක වූ විට OTP සංකේතය යැවීම (Forgot Password OTP)
  static Future<Map<String, dynamic>> sendForgotPasswordOtp({
    required String email,
    String? role,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          if (role != null) 'role': role,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'message': data['message'] ?? 'OTP සංකේතය ඔබගේ ඊමේල් ලිපිනයට යවන ලදී.'};
      } else {
        return {'success': false, 'message': data['error'] ?? 'OTP සංකේතය යැවීමට නොහැකි විය.'};
      }
    } catch (e) {
      return {'success': false, 'message': 'සර්වර් එකට සම්බන්ධ වීමට නොහැකි විය: $e'};
    }
  }

  // මුරපදය අමතක වූ විට OTP සංකේතය නැවත යැවීම (Resend Forgot Password OTP)
  static Future<Map<String, dynamic>> resendForgotPasswordOtp({
    required String email,
    String? role,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/resend-forgot-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          if (role != null) 'role': role,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'message': data['message'] ?? 'නව OTP සංකේතය නැවත යවන ලදී.'};
      } else {
        return {'success': false, 'message': data['error'] ?? 'OTP සංකේතය නැවත යැවීමට නොහැකි විය.'};
      }
    } catch (e) {
      return {'success': false, 'message': 'සර්වර් එකට සම්බන්ධ වීමට නොහැකි විය: $e'};
    }
  }

  // OTP මගින් නව මුරපදය සකස් කිරීම (Reset Password with OTP)
  static Future<Map<String, dynamic>> resetPasswordWithOtp({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'otp': otp,
          'new_password': newPassword,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'message': data['message'] ?? 'මුරපදය සාර්ථකව වෙනස් කරන ලදී!'};
      } else {
        return {'success': false, 'message': data['error'] ?? 'මුරපදය වෙනස් කිරීමට නොහැකි විය.'};
      }
    } catch (e) {
      return {'success': false, 'message': 'සර්වර් එකට සම්බන්ධ වීමේ ගැටළුවක්: $e'};
    }
  }


  // අලුතින් එකතු කරන Register Function එක
  static Future<Map<String, dynamic>> register(
      String fullName, String email, String phone, String password, String role) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'), // ඔබගේ backend route එකට ගැලපෙන සේ වෙනස් කරන්න
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'full_name': fullName,
          'email': email,
          'phone': phone,
          'password': password,
          'role': role
        }),
      );

      final data = jsonDecode(response.body);

      // Status code 200 හෝ 201 (Created) නම් සාර්ථකයි
      if (response.statusCode == 200 || response.statusCode == 201) {

        // අලුතින් එකතු කළ කොටස: user_id එක ෆෝන් එකේ සේව් කරගැනීම
        if (data['user'] != null) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          final user = data['user'];
          await prefs.setString('user_id', user['id'] ?? '');
          await prefs.setString('email', user['email'] ?? email);
          await prefs.setString('full_name', fullName);
          await prefs.setString('phone', phone);
          await prefs.setString('user_role', role);
        }

        return {'success': true, 'message': 'සාර්ථකව ලියාපදිංචි විය!'};
      } else {
        return {'success': false, 'message': data['error'] ?? 'ලියාපදිංචි වීමට නොහැකි විය.'};
      }
    } catch (e) {
      return {'success': false, 'message': 'සර්වර් එකට සම්බන්ධ වීමේ ගැටළුවක්!'};
    }
  }

  // බාස් කෙනෙකුගේ අමතර විස්තර Database එකට යැවීම
  static Future<Map<String, dynamic>> submitProviderDetails({
    required String userId,
    required String category,
    required String nic,
    required int experience,
    required double radius,
    String? district,
    String? city,
    String? address,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/providers/onboarding'), 
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'service_category': category,
          'nic_number': nic,
          'experience_years': experience,
          'working_radius_km': radius,
          'district': ?district,
          'city': ?city,
          'address': ?address,
        }),
      );

      final data = jsonDecode(response.body);

      // Status code 200 හෝ 201 නම් සාර්ථකයි
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'message': data['message'] ?? 'සාර්ථකව ඇතුළත් කරන ලදී!'};
      } else {
        return {'success': false, 'message': data['error'] ?? 'ඇතුළත් කිරීමට නොහැකි විය.'};
      }
    } catch (e) {
      debugPrint("❌ API Error එක: $e");
      return {'success': false, 'message': 'සර්වර් එකට සම්බන්ධ වීමේ ගැටළුවක්!'};
    }
  }

  // අලුත් Booking එකක් යැවීම
  static Future<Map<String, dynamic>> createBooking({
    required String customerId,
    required String providerId,
    required String issue,
    required String address,
    required String date,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/bookings'), 
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'customer_id': customerId,
          'provider_id': providerId,
          'issue': issue,
          'address': address,
          'date': date
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'message': data['message'] ?? 'සාර්ථකව ඉල්ලීම යවන ලදී!'};
      } else {
        return {'success': false, 'message': data['error'] ?? 'ඉල්ලීම යැවීමට නොහැකි විය.'};
      }
    } catch (e) {
      debugPrint("❌ Booking API Error: $e");
      return {'success': false, 'message': 'සර්වර් එකට සම්බන්ධ වීමේ ගැටළුවක්!'};
    }
  }

  // බාස් කෙනෙකුට ලැබී ඇති වැඩ (Bookings) ලබා ගැනීම
  static Future<List<dynamic>> getProviderBookings(String providerId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/bookings/provider/$providerId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? []; // දත්ත තිබේ නම් ඒවා යවන්න
      } else {
        return [];
      }
    } catch (e) {
      debugPrint("❌ Get Bookings API Error: $e");
      return [];
    }
  }

  // බාස් විසින් වැඩක් භාරගැනීම
  static Future<Map<String, dynamic>> acceptBooking(String bookingId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/bookings/$bookingId/accept'),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message'] ?? 'සාර්ථකව භාරගන්නා ලදී!'};
      } else {
        return {'success': false, 'message': data['error'] ?? 'ගැටළුවක් මතු විය.'};
      }
    } catch (e) {
      debugPrint("❌ Accept Booking API Error: $e");
      return {'success': false, 'message': 'සර්වර් එකට සම්බන්ධ වීමේ ගැටළුවක්!'};
    }
  }

  // බාස් විසින් භාරගත් සහ අවසන් කළ වැඩ ලබා ගැනීම
  static Future<List<dynamic>> getMyJobs(String providerId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/bookings/provider/$providerId/my-jobs'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? [];
      } else {
        return [];
      }
    } catch (e) {
      debugPrint("❌ Get My Jobs API Error: $e");
      return [];
    }
  }

  // බාස් කෙනෙකුගේ සියලුම විස්තර (Verification Status, Location, etc.) ලබා ගැනීම
  static Future<Map<String, dynamic>?> getProviderDetails(String providerId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/providers/details/$providerId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'];
      } else {
        return null;
      }
    } catch (e) {
      debugPrint("❌ Get Provider Details API Error: $e");
      return null;
    }
  }

  // පරිශීලකයෙකුගේ Profile දත්ත (Name, Email, Phone) ලබා ගැනීම
  static Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/profile/$userId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'];
      } else {
        return null;
      }
    } catch (e) {
      debugPrint("❌ Get User Profile API Error: $e");
      return null;
    }
  }

  // බාස් විසින් වැඩක් අවසන් කිරීම (Complete Booking)
  static Future<Map<String, dynamic>> completeBooking(String bookingId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/bookings/$bookingId/complete'),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message'] ?? 'සාර්ථකව අවසන් කරන ලදී!'};
      } else {
        return {'success': false, 'message': data['error'] ?? 'ගැටළුවක් මතු විය.'};
      }
    } catch (e) {
      debugPrint("❌ Complete Booking API Error: $e");
      return {'success': false, 'message': 'සර්වර් එකට සම්බන්ධ වීමේ ගැටළුවක්!'};
    }
  }

  // වෙන්කිරීමක් අවලංගු කිරීම (Cancel Booking)
  static Future<Map<String, dynamic>> cancelBooking(String bookingId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/bookings/$bookingId/cancel'),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message'] ?? 'සාර්ථකව අවලංගු කරන ලදී!'};
      } else {
        return {'success': false, 'message': data['error'] ?? 'අවලංගු කිරීමට නොහැකි විය.'};
      }
    } catch (e) {
      debugPrint("❌ Cancel Booking API Error: $e");
      return {'success': false, 'message': 'සර්වර් එකට සම්බන්ධ වීමේ ගැටළුවක්!'};
    }
  }

  // සියලුම සේවා සපයන්නන්ගේ (Providers) ලැයිස්තුව ලබා ගැනීම
  static Future<List<dynamic>> getAllProviders() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/providers/all'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? [];
      } else {
        return [];
      }
    } catch (e) {
      debugPrint("❌ Get All Providers API Error: $e");
      return [];
    }
  }

  // Profile තොරතුරු යාවත්කාලීන කිරීම (Update Profile)
  static Future<Map<String, dynamic>> updateUserProfile({
    required String userId,
    required String fullName,
    required String phone,
    required String address,
    String? district,
    String? city,
    String? profileImageUrl,
    String? serviceCategory,
    int? experienceYears,
    int? workingRadiusKm,
  }) async {
    try {
      final Map<String, dynamic> body = {
        'user_id': userId,
        'full_name': fullName,
        'phone': phone,
        'address': address,
        if (district != null) 'district': district,
        if (city != null) 'city': city,
        if (profileImageUrl != null) 'profile_image_url': profileImageUrl,
        if (serviceCategory != null) 'service_category': serviceCategory,
        if (experienceYears != null) 'experience_years': experienceYears,
        if (workingRadiusKm != null) 'working_radius_km': workingRadiusKm,
      };

      final response = await http.put(
        Uri.parse('$baseUrl/auth/profile/update'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('full_name', fullName);
        await prefs.setString('phone', phone);
        await prefs.setString('address', address);
        if (district != null) await prefs.setString('district', district);
        if (city != null) await prefs.setString('city', city);
        if (profileImageUrl != null) await prefs.setString('profile_image_url', profileImageUrl);

        return {'success': true, 'message': data['message'] ?? 'සාර්ථකව යාවත්කාලීන කරන ලදී!'};
      } else {
        return {'success': false, 'message': data['error'] ?? 'ගැටළුවක් මතු විය.'};
      }
    } catch (e) {
      debugPrint("❌ Update Profile API Error: $e");
      return {'success': false, 'message': 'සර්වර් එකට සම්බන්ධ වීමේ ගැටළුවක්!'};
    }
  }

  // Profile Photo පමණක් වෙනස් කිරීම
  static Future<Map<String, dynamic>> updateProfilePicture({
    required String userId,
    required String profileImageUrl,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/auth/profile/update'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'profile_image_url': profileImageUrl,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('profile_image_url', profileImageUrl);
        return {'success': true, 'message': data['message'] ?? 'ඡායාරූපය සාර්ථකව යාවත්කාලීන කරන ලදී!'};
      } else {
        return {'success': false, 'message': data['error'] ?? 'ඡායාරූපය යාවත්කාලීන කිරීමට නොහැකි විය.'};
      }
    } catch (e) {
      debugPrint("❌ Update Profile Picture API Error: $e");
      return {'success': false, 'message': 'සර්වර් එකට සම්බන්ධ වීමේ ගැටළුවක්!'};
    }
  }

  // පාරිභෝගිකයාගේ (Customer) වෙන්කිරීම් ලැයිස්තුව ලබා ගැනීම
  static Future<List<dynamic>> getCustomerBookings(String customerId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/bookings/customer/$customerId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? [];
      } else {
        return [];
      }
    } catch (e) {
      debugPrint("❌ Get Customer Bookings API Error: $e");
      return [];
    }
  }

  // සේවා සපයන්නාගේ NIC ඡායාරූප (Documents) යාවත්කාලීන කිරීම
  static Future<Map<String, dynamic>> updateProviderNicDocuments({
    required String providerId,
    required String nicFrontUrl,
    required String nicBackUrl,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/providers/nic-documents'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'provider_id': providerId,
          'nic_front_url': nicFrontUrl,
          'nic_back_url': nicBackUrl,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message'] ?? 'සාර්ථකව යවන ලදී!'};
      } else {
        return {'success': false, 'message': data['error'] ?? 'ගැටළුවක් මතු විය.'};
      }
    } catch (e) {
      debugPrint("❌ Update NIC Documents API Error: $e");
      return {'success': false, 'message': 'සර්වර් එකට සම්බන්ධ වීමේ ගැටළුවක්!'};
    }
  }

  // ----------------------------------------------------
  // Rating & Review API Endpoints
  // ----------------------------------------------------

  // 1. සමාලෝචනයක් (Review & Rating) ඇතුළත් කිරීම
  static Future<Map<String, dynamic>> submitReview({
    String? bookingId,
    required String customerId,
    required String providerId,
    required int rating,
    required String comment,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reviews/add'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'booking_id': bookingId,
          'customer_id': customerId,
          'provider_id': providerId,
          'rating': rating,
          'comment': comment,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'message': data['message'] ?? 'සමාලෝචනය සාර්ථකව එක් කරන ලදී!'};
      } else {
        return {'success': false, 'message': data['error'] ?? 'සමාලෝචනය ඇතුළත් කිරීමට නොහැකි විය.'};
      }
    } catch (e) {
      debugPrint("❌ Submit Review API Error: $e");
      return {'success': false, 'message': 'සර්වර් එකට සම්බන්ධ වීමේ ගැටළුවක්!'};
    }
  }

  // 2. සේවා සපයන්නාගේ සියලුම Reviews සහ Average Rating ලබා ගැනීම
  static Future<Map<String, dynamic>> getProviderReviews(String providerId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reviews/provider/$providerId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'average_rating': data['average_rating'] ?? 0.0,
          'total_reviews': data['total_reviews'] ?? 0,
          'reviews': data['reviews'] ?? [],
        };
      } else {
        return {'success': false, 'average_rating': 0.0, 'total_reviews': 0, 'reviews': []};
      }
    } catch (e) {
      debugPrint("❌ Get Provider Reviews API Error: $e");
      return {'success': false, 'average_rating': 0.0, 'total_reviews': 0, 'reviews': []};
    }
  }

  // 3. සේවා සපයන්නාගේ කළ වැඩවල ඡායාරූප (Portfolio Images) යාවත්කාලීන කිරීම
  static Future<Map<String, dynamic>> updateProviderPortfolio({
    required String providerId,
    required List<String> portfolioImages,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/providers/portfolio'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'provider_id': providerId,
          'portfolio_images': portfolioImages,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message'] ?? 'ඡායාරූප සාර්ථකව යාවත්කාලීන කරන ලදී!'};
      } else {
        return {'success': false, 'message': data['error'] ?? 'ඡායාරූප යාවත්කාලීන කිරීමට නොහැකි විය.'};
      }
    } catch (e) {
      debugPrint("❌ Update Provider Portfolio API Error: $e");
      return {'success': false, 'message': 'සර්වර් එකට සම්බන්ධ වීමේ ගැටළුවක්!'};
    }
  }

  // මුරපදය වෙනස් කිරීම (Change Password)
  static Future<Map<String, dynamic>> changePassword({
    required String userId,
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/change-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'old_password': oldPassword,
          'new_password': newPassword,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message'] ?? 'මුරපදය සාර්ථකව වෙනස් කරන ලදී!'};
      } else {
        return {'success': false, 'message': data['error'] ?? 'මුරපදය වෙනස් කිරීමට නොහැකි විය.'};
      }
    } catch (e) {
      debugPrint("❌ Change Password API Error: $e");
      return {'success': false, 'message': 'සර්වර් එකට සම්බන්ධ වීමේ ගැටළුවක්!'};
    }
  }

  // Get all active service categories from backend database
  static Future<List<dynamic>> getCategories() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/categories'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return data['data'];
        }
      }
    } catch (e) {
      debugPrint("❌ getCategories API Error: $e");
    }
    return [];
  }

  // Send Chat Message
  static Future<Map<String, dynamic>> sendMessage({
    required String senderId,
    required String receiverId,
    String? bookingId,
    required String text,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/messages/send'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'sender_id': senderId,
          'receiver_id': receiverId,
          'booking_id': bookingId,
          'text': text,
        }),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': data['data']};
      } else {
        return {'success': false, 'message': data['error'] ?? 'පණිවිඩය යැවීමට නොහැකි විය.'};
      }
    } catch (e) {
      debugPrint("❌ sendMessage API Error: $e");
      return {'success': false, 'message': 'සර්වර් එකට සම්බන්ධ වීමේ ගැටළුවක්!'};
    }
  }

  // Get Chat History
  static Future<List<dynamic>> getChatHistory({
    required String user1,
    required String user2,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/messages/history?user1=$user1&user2=$user2'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['messages'] ?? [];
      }
    } catch (e) {
      debugPrint("❌ getChatHistory API Error: $e");
    }
    return [];
  }

  // Get User Conversations
  static Future<List<dynamic>> getUserConversations(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/messages/conversations/$userId'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['conversations'] ?? [];
      }
    } catch (e) {
      debugPrint("❌ getUserConversations API Error: $e");
    }
    return [];
  }

  // Update FCM Device Push Token
  static Future<bool> updateFcmToken({
    required String userId,
    required String fcmToken,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/update-fcm-token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'fcmToken': fcmToken,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("❌ updateFcmToken API Error: $e");
      return false;
    }
  }

  // Get Admin Push Broadcast Notifications
  static Future<List<dynamic>> getAdminBroadcasts(String role) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/notifications/broadcast?role=$role'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return data['data'];
        }
      }
    } catch (e) {
      debugPrint("❌ getAdminBroadcasts Error: $e");
    }
    return [];
  }
}