import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../services/user_service.dart';
import '../theme/app_theme.dart';
import 'dart:math';

class SubjectScreen extends StatefulWidget {
  const SubjectScreen({Key? key}) : super(key: key);

  @override
  State<SubjectScreen> createState() => _SubjectScreenState();
}

class _SubjectScreenState extends State<SubjectScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();
  List<Map<String, dynamic>> subjects = [];
  List<String> departments = [];
  bool isLoading = true;
  int? userRole;

  final TextEditingController _subjectNameController = TextEditingController();
  final TextEditingController _subjectCodeController = TextEditingController();
  String? _selectedDepartment;
  List<TextEditingController> _blockControllers = [TextEditingController()];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _subjectNameController.dispose();
    _subjectCodeController.dispose();
    for (var controller in _blockControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    try {
      subjects = await _firestoreService.getSubjects();
      await _loadDepartments();
      await _loadUserRole();
    } catch (e) {
      if (mounted) _showErrorSnackBar('Error loading data: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _loadUserRole() async {
    var userData = await _authService.getUserData();
    if (userData != null && userData.containsKey('role') && mounted) {
      setState(() {
        userRole = userData['role'] as int;
      });
    }
  }

  Future<void> _loadDepartments() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('departments').get();
      if (mounted) {
        setState(() {
          departments =
              querySnapshot.docs.map((doc) => doc['name'] as String).toList();
        });
      }
    } catch (e) {
      print('Error loading departments: $e');
      if (mounted)
        _showErrorSnackBar('Failed to load departments. Please try again.');
    }
  }

  String _generateCode() {
    const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(
        5, (_) => characters[Random().nextInt(characters.length)]).join();
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _addBlock() {
    setState(() {
      _blockControllers.add(TextEditingController());
    });
  }

  void _removeBlock(int index) {
    if (_blockControllers.length > 1) {
      setState(() {
        _blockControllers[index].dispose();
        _blockControllers.removeAt(index);
      });
    }
  }

  Future<void> _addSubject() async {
    if (userRole != 2) {
      _showErrorSnackBar('Only teachers can add subjects');
      return;
    }

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Add Subject', style: AppTheme.titleStyle),
              content: SingleChildScrollView(
                child: Container(
                  width: double.maxFinite,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _subjectNameController,
                        decoration: InputDecoration(labelText: 'Subject Name'),
                        style: AppTheme.bodyStyle,
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _subjectCodeController,
                        decoration: InputDecoration(labelText: 'Subject Code'),
                        style: AppTheme.bodyStyle,
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: _selectedDepartment,
                        onChanged: (newValue) =>
                            setState(() => _selectedDepartment = newValue),
                        items: departments
                            .map((department) => DropdownMenuItem(
                                  child: Text(
                                    department,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  value: department,
                                ))
                            .toList(),
                        decoration: InputDecoration(labelText: 'Department'),
                        style: AppTheme.bodyStyle,
                      ),
                      const SizedBox(height: 10),
                      ..._blockControllers.asMap().entries.map((entry) {
                        int idx = entry.key;
                        return Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: entry.value,
                                    decoration: InputDecoration(
                                        labelText: 'Block ${idx + 1}'),
                                    style: AppTheme.bodyStyle,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.remove),
                                  onPressed: () => _removeBlock(idx),
                                ),
                                IconButton(
                                  icon: Icon(Icons.add),
                                  onPressed: _addBlock,
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  child: Text('Cancel',
                      style: TextStyle(color: AppTheme.primaryColor)),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                ElevatedButton(
                  child: Text('Add'),
                  onPressed: () async {
                    if (_subjectNameController.text.isEmpty ||
                        _subjectCodeController.text.isEmpty ||
                        _selectedDepartment == null) {
                      _showErrorSnackBar('Please fill in all required fields');
                      return;
                    }
                    try {
                      await _firestoreService.addSubject({
                        'name': _subjectNameController.text,
                        'code': _subjectCodeController.text,
                        'department': _selectedDepartment,
                        'blocks': _blockControllers
                            .map((c) => c.text)
                            .where((b) => b.isNotEmpty)
                            .toList(),
                        'generatedCode': _generateCode(),
                      });
                      Navigator.of(context).pop();
                      if (mounted) {
                        _loadData();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Subject added successfully')),
                        );
                      }
                    } catch (e) {
                      _showErrorSnackBar('Failed to add subject: $e');
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      _subjectNameController.clear();
      _subjectCodeController.clear();
      _selectedDepartment = null;
      _blockControllers = [TextEditingController()];
    });
  }

  Future<void> _editSubject(Map<String, dynamic> subject) async {
    if (userRole != 1 && userRole != 2) {
      // Assuming 1 is admin and 2 is teacher
      _showErrorSnackBar('Only admins and teachers can edit subjects');
      return;
    }

    _subjectNameController.text = subject['name'];
    _subjectCodeController.text = subject['code'];
    _selectedDepartment = subject['department'];
    _blockControllers = (subject['blocks'] as List)
        .map((block) => TextEditingController(text: block.toString()))
        .toList();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Edit Subject', style: AppTheme.titleStyle),
              content: SingleChildScrollView(
                child: Container(
                  width: double.maxFinite,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _subjectNameController,
                        decoration: InputDecoration(labelText: 'Subject Name'),
                        style: AppTheme.bodyStyle,
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _subjectCodeController,
                        decoration: InputDecoration(labelText: 'Subject Code'),
                        style: AppTheme.bodyStyle,
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: _selectedDepartment,
                        onChanged: (newValue) =>
                            setState(() => _selectedDepartment = newValue),
                        items: departments
                            .map((department) => DropdownMenuItem(
                                  child: Text(
                                    department,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  value: department,
                                ))
                            .toList(),
                        decoration: InputDecoration(labelText: 'Department'),
                        style: AppTheme.bodyStyle,
                      ),
                      const SizedBox(height: 10),
                      ..._blockControllers.asMap().entries.map((entry) {
                        int idx = entry.key;
                        return Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: entry.value,
                                    decoration: InputDecoration(
                                        labelText: 'Block ${idx + 1}'),
                                    style: AppTheme.bodyStyle,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.add),
                                  onPressed: () => setState(() =>
                                      _blockControllers
                                          .add(TextEditingController())),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  child: Text('Cancel',
                      style: TextStyle(color: AppTheme.primaryColor)),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                ElevatedButton(
                  child: Text('Update'),
                  onPressed: () async {
                    if (_subjectNameController.text.isEmpty ||
                        _subjectCodeController.text.isEmpty ||
                        _selectedDepartment == null) {
                      _showErrorSnackBar('Please fill in all required fields');
                      return;
                    }
                    try {
                      await _firestoreService.updateSubject(
                        subject['id'],
                        {
                          'name': _subjectNameController.text,
                          'code': _subjectCodeController.text,
                          'department': _selectedDepartment,
                          'blocks': _blockControllers
                              .map((c) => c.text)
                              .where((b) => b.isNotEmpty)
                              .toList(),
                        },
                      );
                      Navigator.of(context).pop();
                      if (mounted) {
                        _loadData();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Subject updated successfully')),
                        );
                      }
                    } catch (e) {
                      _showErrorSnackBar('Failed to update subject: $e');
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      _subjectNameController.clear();
      _subjectCodeController.clear();
      _selectedDepartment = null;
      _blockControllers = [TextEditingController()];
    });
  }

  Future<void> _deleteSubject(String subjectId) async {
    if (userRole != 1 && userRole != 2) {
      // Assuming 1 is admin and 2 is teacher
      _showErrorSnackBar('Only admins and teachers can delete subjects');
      return;
    }

    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this subject?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            ElevatedButton(
              child: Text('Delete'),
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        );
      },
    );

    if (confirmDelete) {
      try {
        await _firestoreService.deleteSubject(subjectId);
        _loadData();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Subject deleted successfully')),
        );
      } catch (e) {
        _showErrorSnackBar('Failed to delete subject: $e');
      }
    }
  }

  Widget _buildSubjectCard(Map<String, dynamic> subject) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: AppTheme.surfaceColor,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    subject['name'],
                    style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.orange),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (userRole == 1 || userRole == 2) // Admin or Teacher
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _editSubject(subject);
                      } else if (value == 'delete') {
                        _deleteSubject(subject['id']);
                      }
                    },
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'edit',
                        child: Text('Edit'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
                  ),
              ],
            ),
            SizedBox(height: 4),
            Text(subject['code'], style: AppTheme.bodyStyle),
            SizedBox(height: 4),
            Text(
              subject['department'],
              style: AppTheme.bodyStyle.copyWith(fontStyle: FontStyle.italic),
            ),
            SizedBox(height: 8),
            Text('Block ${(subject['blocks'] as List).join(', Block ')}',
                style: AppTheme.bodyStyle),
            SizedBox(height: 4),
            Text(
              'Code: ${subject['generatedCode']}',
              style: AppTheme.bodyStyle.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor))
          : subjects.isEmpty
              ? Center(
                  child: Text('No subjects found', style: AppTheme.bodyStyle))
              : ListView.builder(
                  itemCount: subjects.length,
                  itemBuilder: (context, index) =>
                      _buildSubjectCard(subjects[index]),
                ),
      floatingActionButton: userRole == 2 // Only show FAB for teachers
          ? FloatingActionButton(
              onPressed: _addSubject,
              child: Icon(Icons.add),
              backgroundColor: AppTheme.primaryColor,
            )
          : null,
    );
  }
}
