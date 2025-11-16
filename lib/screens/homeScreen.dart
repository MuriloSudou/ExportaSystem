import 'package:exportasystem/controllers/authController.dart';
import 'package:exportasystem/models/userModel.dart';
import 'package:exportasystem/screens/bookingFormScreen.dart';
import 'package:exportasystem/screens/bookingsListScreen.dart';
import 'package:exportasystem/screens/calendarScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:exportasystem/controllers/bookingController.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthController _authController = Get.find<AuthController>();
  UserModel? _user;

  static const corPrincipal = Color(0xFF1E88E5);
  static const background = Color(0xFFF5F7FA);

  @override
  void initState() {
    super.initState();
    Get.put(BookingController());
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      _user = await _authController.getUserFromSession();

      if (_user == null) {
        print("⚠️ Nenhum usuário carregado da sessão, redirecionando para login...");
        Get.offAllNamed('/login');
        return;
      }

      print('✅ Usuário carregado da sessão: ${_user?.toMap()}');
      setState(() {});
    } catch (e) {
      print('❌ Erro ao carregar usuário: $e');
      Get.snackbar('Erro', 'Falha ao carregar usuário: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  void _logout() {
    _authController.emailController.clear();
    _authController.passwordController.clear();
    _authController.clearSession();
    Get.offAllNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1.0,
        centerTitle: false,
        title: Image.asset(
          "assets/images/logo.png",
          height: 35,
        ),
        iconTheme: IconThemeData(color: corPrincipal),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Obx(() => UserAccountsDrawerHeader(
                  decoration: BoxDecoration(
                    color: corPrincipal,
                  ),
                  accountName: Text(
                    _user?.name ?? 'Usuário',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  accountEmail: Text(
                    _user?.email ?? 'email@exemplo.com',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0.9),
                    backgroundImage: _authController.avatarUrl.value.isNotEmpty
                        ? NetworkImage(_authController.avatarUrl.value)
                        : null,
                    child: _authController.avatarUrl.value.isNotEmpty
                        ? null
                        : Icon(
                            Icons.person,
                            size: 50,
                            color: corPrincipal,
                          ),
                  ),
                  onDetailsPressed: () {
                    
                  },
                )),
            _buildDrawerItem(
              Icons.add_box_outlined,
              'Registrar Novo Booking',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BookingFormScreen()),
                );
              },
            ),
            _buildDrawerItem(
              Icons.list_alt_outlined,
              'Listar Meus Bookings',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => BookingsListScreen()),
                );
              },
            ),
            _buildDrawerItem(Icons.calendar_today, 'Calendário', onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CalendarScreen()),
              );
            }),
            const Divider(),
            _buildDrawerItem(Icons.logout, 'Logout', onTap: _logout),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Olá, ${_user?.name ?? 'Usuário'}!',
              style: TextStyle(
                color: Color(0xFF37474F),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'O que você gostaria de fazer hoje?',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 30),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildDashboardCard(
                  icon: Icons.add_box_outlined,
                  label: 'Registrar Novo Booking',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const BookingFormScreen()),
                    );
                  },
                ),
                _buildDashboardCard(
                  icon: Icons.list_alt_outlined,
                  label: 'Listar Meus Bookings',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => BookingsListScreen()),
                    );
                  },
                ),
                _buildDashboardCard(
                  icon: Icons.calendar_today_outlined,
                  label: 'Calendário',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CalendarScreen()),
                    );
                  },
                ),
                _buildDashboardCard(
                  icon: Icons.settings_outlined,
                  label: 'Configurações',
                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: corPrincipal),
            const SizedBox(height: 16),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF37474F),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title,
      {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.black54),
      title: Text(title),
      onTap: onTap,
    );
  }
}