import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';

class ManageDepartment extends StatefulWidget {
  const ManageDepartment({Key? key}) : super(key: key);

  @override
  State<ManageDepartment> createState() => _ManageDepartmentState();
}

class _ManageDepartmentState extends State<ManageDepartment> {
  final FirestoreService _firestoreService = FirestoreService();
  List<Map<String, dynamic>> departments = [];
  bool isLoading = true;

  // Department form controllers
  final TextEditingController _departmentNameController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDepartments();
  }

  @override
  void dispose() {
    _departmentNameController.dispose();
    super.dispose();
  }

  Future<void> _loadDepartments() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('departments').get();
      if (!mounted) return;
      setState(() {
        departments = querySnapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          return data;
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      print('Error loading departments: $e');
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to load departments. Please try again.')),
      );
    }
  }

  Future<void> _addDepartment() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Department', style: AppTheme.titleStyle),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _departmentNameController,
                  decoration: InputDecoration(
                    labelText: 'Department Name',
                    hintText: 'Enter department name',
                  ),
                  style: AppTheme.bodyStyle,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel',
                  style: TextStyle(color: AppTheme.primaryColor)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Add'),
              onPressed: () async {
                if (_departmentNameController.text.isNotEmpty) {
                  try {
                    await FirebaseFirestore.instance
                        .collection('departments')
                        .add({
                      'name': _departmentNameController.text,
                    });
                    Navigator.of(context).pop();
                    if (!mounted) return;
                    _loadDepartments(); // Reload the department list
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Department added successfully')),
                    );
                  } catch (e) {
                    print('Error adding department: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              'Failed to add department. Please try again.')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please fill in all fields')),
                  );
                }
              },
            ),
          ],
        );
      },
    ).then((_) {
      // Clear the form fields after the dialog is closed
      _departmentNameController.clear();
    });
  }

  Future<void> _editDepartment(Map<String, dynamic> department) async {
    _departmentNameController.text = department['name'];

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Department', style: AppTheme.titleStyle),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _departmentNameController,
                  decoration: InputDecoration(
                    labelText: 'Department Name',
                    hintText: 'Enter department name',
                  ),
                  style: AppTheme.bodyStyle,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel',
                  style: TextStyle(color: AppTheme.primaryColor)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Update'),
              onPressed: () async {
                if (_departmentNameController.text.isNotEmpty) {
                  try {
                    await FirebaseFirestore.instance
                        .collection('departments')
                        .doc(department['id'])
                        .update({
                      'name': _departmentNameController.text,
                    });
                    Navigator.of(context).pop();
                    if (!mounted) return;
                    _loadDepartments(); // Reload the department list
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Department updated successfully')),
                    );
                  } catch (e) {
                    print('Error updating department: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              'Failed to update department. Please try again.')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please fill in all fields')),
                  );
                }
              },
            ),
          ],
        );
      },
    ).then((_) {
      // Clear the form fields after the dialog is closed
      _departmentNameController.clear();
    });
  }

  Future<void> _deleteDepartment(String id) async {
    bool confirmDelete = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Confirm Delete', style: AppTheme.titleStyle),
              content: Text('Are you sure you want to delete this department?',
                  style: AppTheme.bodyStyle),
              actions: [
                TextButton(
                  child: Text('Cancel',
                      style: TextStyle(color: AppTheme.primaryColor)),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                TextButton(
                  child: Text('Delete', style: TextStyle(color: Colors.red)),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            );
          },
        ) ??
        false;

    if (confirmDelete) {
      try {
        await FirebaseFirestore.instance
            .collection('departments')
            .doc(id)
            .delete();
        setState(() {
          departments.removeWhere((department) => department['id'] == id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Department deleted successfully')),
        );
      } catch (e) {
        print('Error deleting department: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to delete department. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor))
          : ListView.builder(
              itemCount: departments.length,
              itemBuilder: (context, index) {
                final department = departments[index];
                return Slidable(
                  endActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    extentRatio: 0.5,
                    children: [
                      SlidableAction(
                        onPressed: (context) => _editDepartment(department),
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        icon: Icons.edit,
                        label: 'Edit',
                      ),
                      SlidableAction(
                        onPressed: (context) =>
                            _deleteDepartment(department['id']),
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        label: 'Delete',
                      ),
                    ],
                  ),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 2,
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: ListTile(
                        title: Text(
                          department['name'],
                          style: AppTheme.titleStyle,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addDepartment,
        child: Icon(Icons.add),
        backgroundColor: AppTheme.orange,
      ),
    );
  }
}
