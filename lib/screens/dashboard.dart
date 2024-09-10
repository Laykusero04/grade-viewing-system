import 'package:flutter/material.dart';
import 'package:grade_viewing_system/screens/data_page.dart';
import 'package:grade_viewing_system/screens/home.dart';
import 'package:grade_viewing_system/screens/notification.dart';
import 'package:grade_viewing_system/screens/request.dart';
import 'package:grade_viewing_system/screens/subjects.dart';
import 'package:provider/provider.dart';
import '../components/custom_bottom_nav_bar.dart';
import '../services/user_service.dart';
import '../theme/app_theme.dart';
import 'department.dart';
import 'manage_users.dart';
import 'profile.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  late Future<Map<String, dynamic>?> _userDataFuture;

  @override
  void initState() {
    super.initState();
    _userDataFuture =
        Provider.of<AuthService>(context, listen: false).getUserData();
  }

  List<Widget> _getPages(int userRole) {
    if (userRole == 1) {
      // Admin
      return [
        DataPage(),
        SubjectScreen(),
        ManageDepartment(),
        ManageUsers(),
        ProfileScreen(),
      ];
    } else if (userRole == 2) {
      // Teacher
      return [
        SubjectScreen(),
        RequestScreen(),
        ProfileScreen(),
      ];
    } else {
      // Student
      return [
        SubjectScreen(),
        RequestScreen(),
        NotificationScreen(),
        ProfileScreen(),
      ];
    }
  }

  List<BottomNavigationBarItem> _getNavBarItems(int userRole) {
    if (userRole == 1) {
      // Admin
      return [
        BottomNavigationBarItem(
            icon: Icon(Icons.dashboard), label: 'Dashboard'),
        BottomNavigationBarItem(icon: Icon(Icons.subject), label: 'Subjects'),
        BottomNavigationBarItem(
            icon: Icon(Icons.business), label: 'Department'),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Users'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ];
    } else if (userRole == 2) {
      // Teacher
      return [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.note_alt), label: 'Request'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ];
    } else {
      // Student
      return [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.note_alt), label: 'Request'),
        BottomNavigationBarItem(
            icon: Icon(Icons.notifications), label: 'Notification'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _userDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(
              body: Center(
                  child: Text('Error loading user data',
                      style: AppTheme.bodyStyle)));
        }

        final userData = snapshot.data!;
        final userRole = userData['role'] as int;
        final pages = _getPages(userRole);
        final navBarItems = _getNavBarItems(userRole);

        return Scaffold(
          appBar: AppBar(
            title: Text('Grade Viewer', style: AppTheme.titleStyle),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.exit_to_app,
                  color: Colors.red,
                ),
                onPressed: () async {
                  await Provider.of<AuthService>(context, listen: false)
                      .signOut();
                  Navigator.of(context).pushReplacementNamed('/login');
                },
              ),
            ],
          ),
          body: pages[_currentIndex],
          bottomNavigationBar: CustomBottomNavBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: navBarItems,
          ),
        );
      },
    );
  }
}
