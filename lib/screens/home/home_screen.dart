import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:juntaai/screens/planning_screen.dart';
import 'package:juntaai/screens/profile_screen.dart';
import 'package:juntaai/screens/transactions/transactions_screen.dart';
import 'package:juntaai/service/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  User? _currentUser;
  final FirebaseService _firebaseService = FirebaseService();

  static final List<Widget> _screens = [
    Container(),
    const PlanningScreen(),
    const Placeholder(),
    const TransactionsScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  void _getCurrentUser() {
    setState(() {
      _currentUser = _firebaseService.getCurrentUser();
      // print(_currentUser);
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _currentUser != null
            ? Text(
                'Bem-vindo, ${_currentUser!.displayName ?? _currentUser!.email}')
            : const Text('Bem-vindo'),
        automaticallyImplyLeading: false,
        // actions: [
        //   IconButton(
        //     icon: const Icon(CupertinoIcons.person),
        //     onPressed: () {
        //       Navigator.push(
        //         context,
        //         MaterialPageRoute(
        //           builder: (context) => const ProfileScreen(),
        //         ),
        //       );
        //     },
        //   ),
        // ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            buildNavBarItem(CupertinoIcons.home, 'Principal', 0),
            buildNavBarItem(CupertinoIcons.flag, 'Planejamentos', 1),
            const SizedBox(width: 20),
            buildNavBarItem(CupertinoIcons.chart_bar, 'Transações', 3),
            buildNavBarItem(CupertinoIcons.person, 'Usuário', 4),
          ],
        ),
      ),
      floatingActionButton: const ClipOval(
        child: Material(
          color: Colors.orange,
          elevation: 10,
          child: InkWell(
            child: SizedBox(
              width: 56,
              height: 56,
              child: Icon(
                CupertinoIcons.add,
                size: 28,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget buildNavBarItem(IconData icon, String label, int index) {
    return InkWell(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: _selectedIndex == index ? Colors.orange : Colors.black87,
          ),
          Text(
            label,
            style: TextStyle(
              color: _selectedIndex == index ? Colors.orange : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
