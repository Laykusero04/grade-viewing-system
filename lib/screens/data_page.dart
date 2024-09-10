import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DataPage extends StatefulWidget {
  const DataPage({Key? key}) : super(key: key);

  @override
  State<DataPage> createState() => _DataPageState();
}

class _DataPageState extends State<DataPage> {
  int teacherCount = 0;
  int studentCount = 0;
  int subjectCount = 0;
  int departmentCount = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return; // Check if the widget is still in the tree

    setState(() {
      isLoading = true;
    });

    try {
      // Count teachers (role 2)
      QuerySnapshot teacherSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 2)
          .get();
      teacherCount = teacherSnapshot.size;

      // Count students (role 3)
      QuerySnapshot studentSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 3)
          .get();
      studentCount = studentSnapshot.size;

      // Count subjects
      QuerySnapshot subjectSnapshot =
          await FirebaseFirestore.instance.collection('subjects').get();
      subjectCount = subjectSnapshot.size;

      // Count departments
      QuerySnapshot departmentSnapshot =
          await FirebaseFirestore.instance.collection('departments').get();
      departmentCount = departmentSnapshot.size;

      if (mounted) {
        // Check again before calling setState
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading data: $e');
      if (mounted) {
        // Check before calling setState
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Widget _buildDataCard(String title, int count, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: AppTheme.primaryColor),
          SizedBox(height: 8),
          Text(
            count.toString(),
            style: AppTheme.headlineStyle.copyWith(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            title,
            style: AppTheme.bodyStyle,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor))
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Overview', style: AppTheme.headlineStyle),
                    SizedBox(height: 16),
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        _buildDataCard('Teachers', teacherCount, Icons.people),
                        _buildDataCard('Students', studentCount, Icons.groups),
                        _buildDataCard('Subjects', subjectCount, Icons.book),
                        _buildDataCard(
                            'Departments', departmentCount, Icons.business),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
