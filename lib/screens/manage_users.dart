import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../services/firestore_service.dart';
import '../services/user_service.dart';
import '../theme/app_theme.dart';
import 'package:provider/provider.dart';

class ManageUsers extends StatefulWidget {
  const ManageUsers({Key? key}) : super(key: key);

  @override
  State<ManageUsers> createState() => _ManageUsersState();
}

class _ManageUsersState extends State<ManageUsers> {
  final FirestoreService _firestoreService = FirestoreService();
  List<Map<String, dynamic>> users = [];
  bool isLoading = true;

  // Add user form controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _fullnameController = TextEditingController();
  final TextEditingController _schoolIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  int _selectedRole = 3; // Default to Student

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _fullnameController.dispose();
    _schoolIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('users').get();
      if (!mounted) return;
      setState(() {
        users = querySnapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          return data;
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      print('Error loading users: $e');
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load users. Please try again.')),
      );
    }
  }

  String _getRoleName(int role) {
    switch (role) {
      case 1:
        return 'Admin';
      case 2:
        return 'Teacher';
      case 3:
        return 'Student';
      default:
        return 'Unknown';
    }
  }

  Future<void> _addUser() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add User', style: AppTheme.titleStyle),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter email',
                  ),
                  style: AppTheme.bodyStyle,
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter password',
                  ),
                  style: AppTheme.bodyStyle,
                  obscureText: true,
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _fullnameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    hintText: 'Enter user full name',
                  ),
                  style: AppTheme.bodyStyle,
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _schoolIdController,
                  decoration: InputDecoration(
                    labelText: 'School ID (Optional)',
                    hintText: 'Enter school ID',
                  ),
                  style: AppTheme.bodyStyle,
                ),
                SizedBox(height: 10),
                DropdownButtonFormField<int>(
                  value: _selectedRole,
                  onChanged: (int? newValue) {
                    setState(() {
                      _selectedRole = newValue!;
                    });
                  },
                  items: [
                    DropdownMenuItem(child: Text('Admin'), value: 1),
                    DropdownMenuItem(child: Text('Teacher'), value: 2),
                    DropdownMenuItem(child: Text('Student'), value: 3),
                  ],
                  decoration: InputDecoration(labelText: 'Role'),
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
                if (_emailController.text.isNotEmpty &&
                    _fullnameController.text.isNotEmpty &&
                    _passwordController.text.isNotEmpty) {
                  try {
                    final authService =
                        Provider.of<AuthService>(context, listen: false);
                    await authService.createUser(
                      email: _emailController.text,
                      password: _passwordController.text,
                      fullname: _fullnameController.text,
                      role: _selectedRole,
                      schoolId: _schoolIdController.text,
                    );
                    Navigator.of(context).pop();
                    if (!mounted) return;
                    _loadUsers(); // Reload the user list
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('User added successfully')),
                    );
                  } catch (e) {
                    print('Error adding user: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text('Failed to add user. Please try again.')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Please fill in all required fields')),
                  );
                }
              },
            ),
          ],
        );
      },
    ).then((_) {
      // Clear the form fields after the dialog is closed
      _emailController.clear();
      _fullnameController.clear();
      _schoolIdController.clear();
      _passwordController.clear();
      if (mounted) {
        setState(() {
          _selectedRole = 3;
        });
      }
    });
  }

  Future<void> _editUser(Map<String, dynamic> user) async {
    // TODO: Implement edit user functionality
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit User', style: AppTheme.titleStyle),
          content: Text('Edit user functionality to be implemented.',
              style: AppTheme.bodyStyle),
          actions: [
            TextButton(
              child:
                  Text('Close', style: TextStyle(color: AppTheme.primaryColor)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteUser(String uid) async {
    bool confirmDelete = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Confirm Delete', style: AppTheme.titleStyle),
              content: Text('Are you sure you want to delete this user?',
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
        await FirebaseFirestore.instance.collection('users').doc(uid).delete();
        setState(() {
          users.removeWhere((user) => user['id'] == uid);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User deleted successfully')),
        );
      } catch (e) {
        print('Error deleting user: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete user. Please try again.')),
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
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return Slidable(
                  endActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    extentRatio: 0.5,
                    children: [
                      SlidableAction(
                        onPressed: (context) => _editUser(user),
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        icon: Icons.edit,
                        label: 'Edit',
                      ),
                      SlidableAction(
                        onPressed: (context) => _deleteUser(user['id']),
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        label: 'Delete',
                      ),
                    ],
                  ),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(10), // Rounded corners
                    ),
                    elevation: 2, // Subtle shadow

                    margin: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6), // Increased margin for spacing
                    child: Padding(
                      // Added padding for better content spacing
                      padding: const EdgeInsets.all(12.0),
                      child: ListTile(
                        title: Text(
                          user['fullname'],
                          style: AppTheme.titleStyle.copyWith(
                              fontSize: 18), // Slightly larger title font
                        ),
                        subtitle: Text(user['email'],
                            style: AppTheme.bodyStyle.copyWith(
                                color:
                                    Colors.grey[700])), // Subtle color change
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _getRoleName(user['role']),
                              style: AppTheme.bodyStyle.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme
                                    .primaryColor, // Color accent for role
                              ),
                            ),
                            SizedBox(
                                height:
                                    4), // Spacing between role and school ID
                            Text(
                              user['school_id'] ?? '',
                              style: AppTheme.bodyStyle
                                  .copyWith(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addUser,
        child: Icon(Icons.add),
        backgroundColor: AppTheme.orange,
      ),
    );
  }
}
