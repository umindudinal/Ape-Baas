import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_colors.dart';
import 'customer_profile_screen.dart';
import 'provider_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _userRole = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _userRole = prefs.getString('user_role') ?? 'customer';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.surfaceBg,
        appBar: AppBar(
          title: const Text('ගිණුම (Profile)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
          backgroundColor: AppColors.navyDark,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator(color: AppColors.navyDark)),
      );
    }

    if (_userRole == 'provider') {
      return const ProviderProfileScreen();
    } else {
      return const CustomerProfileScreen();
    }
  }
}