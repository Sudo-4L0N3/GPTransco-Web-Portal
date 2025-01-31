import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:gptransco/const/colors/colors.dart';
import 'package:intl/intl.dart';

class RegisteredUsersList extends StatefulWidget {
  const RegisteredUsersList({super.key});

  @override
  _RegisteredUsersListState createState() => _RegisteredUsersListState();
}

class _RegisteredUsersListState extends State<RegisteredUsersList> {
  String? _selectedFilter = 'All'; // Initialize filter to show all users
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  Uint8List? _selectedImageFile; // For image updating
  String? _selectedFilePath;

  // Function to fetch users from Firestore
  Stream<QuerySnapshot> _fetchUsers() {
    if (_selectedFilter == 'All') {
      return _firestore.collection('Driver').snapshots(); // Fetch all users
    } else {
      return _firestore
          .collection('Driver')
          .where('role', isEqualTo: _selectedFilter)
          .snapshots(); // Fetch users by role based on filter
    }
  }

  // Function to show update dialog with image picker
  Future<void> _showUpdateDialog(
      Map<String, dynamic> userData, String docId) async {
    final TextEditingController nameController =
        TextEditingController(text: userData['driverName'] ?? '');
    final TextEditingController addressController =
        TextEditingController(text: userData['address'] ?? '');
    final TextEditingController mobileController =
        TextEditingController(text: userData['mobileNumber'] ?? '');
    final TextEditingController nicknameController =
        TextEditingController(text: userData['nickname'] ?? '');
    final TextEditingController birthdateController =
        TextEditingController(text: userData['birthdate'] ?? '');
    final TextEditingController fuelTypeController =
        TextEditingController(text: userData['fuelType'] ?? '');
    final TextEditingController plateNumberController =
        TextEditingController(text: userData['plateNumber'] ?? '');
    final TextEditingController totalSeatsController =
        TextEditingController(text: userData['totalSeats'] ?? '');
    final TextEditingController vehicleColorController =
        TextEditingController(text: userData['vehicleColor'] ?? '');
    final TextEditingController strictedController =
        TextEditingController(text: userData['Stricted'] ?? '');
    bool isDriver = userData['isDriver'] ?? false;

    _selectedImageFile = null; // Clear previously selected image

    final screenWidth = MediaQuery.of(context).size.width;
    final isMobileOrTablet = screenWidth < 850;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: navy,
              title: Text(
                'Update User',
                style: TextStyle(
                    color: Colors.white, fontSize: isMobileOrTablet ? 16 : 18),
              ),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    // Full Name Field
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                          labelText: 'Full Name',
                          suffixStyle: TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(height: 16),

                    // Address Field
                    TextFormField(
                      controller: addressController,
                      decoration: const InputDecoration(
                          labelText: 'Address',
                          suffixStyle: TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(height: 16),

                    // Mobile Number Field
                    TextFormField(
                      controller: mobileController,
                      decoration: const InputDecoration(
                          labelText: 'Mobile Number',
                          suffixStyle: TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(height: 16),

                    // Nickname Field
                    TextFormField(
                      controller: nicknameController,
                      decoration: const InputDecoration(
                          labelText: 'Nickname',
                          suffixStyle: TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(height: 16),

                    // Birthdate Field with DatePicker
                    TextFormField(
                      controller: birthdateController,
                      readOnly: true, // Makes the field non-editable
                      decoration: const InputDecoration(
                          labelText: 'Birthdate',
                          suffixStyle: TextStyle(color: Colors.white)),
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            birthdateController.text =
                                DateFormat('yyyy-MM-dd').format(pickedDate);
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Fuel Type Field
                    TextFormField(
                      controller: fuelTypeController,
                      decoration: const InputDecoration(
                          labelText: 'Fuel Type',
                          suffixStyle: TextStyle(color: Colors.white)),
                      enabled: isDriver,
                    ),
                    const SizedBox(height: 16),

                    // Plate Number Field
                    TextFormField(
                      controller: plateNumberController,
                      decoration: const InputDecoration(
                          labelText: 'Plate Number',
                          suffixStyle: TextStyle(color: Colors.white)),
                      enabled: isDriver,
                    ),
                    const SizedBox(height: 16),

                    // Total Seats Field
                    TextFormField(
                      controller: totalSeatsController,
                      decoration: const InputDecoration(
                          labelText: 'Total Seats',
                          suffixStyle: TextStyle(color: Colors.white)),
                      enabled: isDriver,
                    ),
                    const SizedBox(height: 16),

                    // Vehicle Color Field
                    TextFormField(
                      controller: vehicleColorController,
                      decoration: const InputDecoration(
                          labelText: 'Vehicle Color',
                          suffixStyle: TextStyle(color: Colors.white)),
                      enabled: isDriver,
                    ),
                    const SizedBox(height: 16),

                    // Stricted Field
                    TextFormField(
                      controller: strictedController,
                      decoration: const InputDecoration(
                          labelText: 'Stricted',
                          suffixStyle: TextStyle(color: Colors.white)),
                      enabled: isDriver,
                    ),
                    const SizedBox(height: 16),

                    // Image Picker Section with Dotted Border and Preview
                    GestureDetector(
                      onTap: () async {
                        FilePickerResult? result =
                            await FilePicker.platform.pickFiles(
                          type: FileType.custom,
                          allowedExtensions: ['jpg', 'jpeg', 'png'],
                          withData: true, // Required for accessing the file bytes
                        );

                        if (result != null) {
                          setState(() {
                            _selectedFilePath = result.files.single.name;
                            _selectedImageFile = result.files.single.bytes;
                          });
                        }
                      },
                      child: DottedBorder(
                        color: Colors.blue,
                        strokeWidth: 1,
                        dashPattern: const [6, 3],
                        borderType: BorderType.RRect,
                        radius: const Radius.circular(8),
                        child: Container(
                          width: isMobileOrTablet ? 150 : 200,
                          height: isMobileOrTablet ? 100 : 150,
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: _selectedImageFile != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.memory(
                                    _selectedImageFile!,
                                    height: isMobileOrTablet ? 80 : 100,
                                    width: isMobileOrTablet ? 80 : 100,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: (userData['driverImage'] != null &&
                                          userData['driverImage'].isNotEmpty)
                                      ? Image.network(
                                          userData['driverImage'],
                                          height: isMobileOrTablet ? 80 : 100,
                                          width: isMobileOrTablet ? 80 : 100,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.asset(
                                          'assets/images/camera.gif',
                                          height: isMobileOrTablet ? 80 : 100,
                                          width: isMobileOrTablet ? 80 : 100,
                                          fit: BoxFit.cover,
                                        ),
                                ),
                        ),
                      ),
                    ),
                    if (_selectedImageFile != null)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _clearImage(); // Clear the image when remove button is clicked
                            });
                          },
                          icon: const Icon(Icons.delete, color: Colors.red),
                          label: Text(
                            'Remove Image',
                            style: TextStyle(
                                color: Colors.red,
                                fontSize: isMobileOrTablet ? 12 : 14),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: isMobileOrTablet ? 14 : 16),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    // Update the user details in Firestore
                    await _updateUser(docId, {
                      'driverName': nameController.text.trim(),
                      'address': addressController.text.trim(),
                      'mobileNumber': mobileController.text.trim(),
                      'nickname': nicknameController.text.trim(),
                      'birthdate': birthdateController.text.trim(),
                      'fuelType': fuelTypeController.text.trim(),
                      'plateNumber': plateNumberController.text.trim(),
                      'totalSeats': totalSeatsController.text.trim(),
                      'vehicleColor': vehicleColorController.text.trim(),
                      'Stricted': strictedController.text.trim(),
                      'isDriver': isDriver,
                    });

                    if (_selectedImageFile != null) {
                      await _uploadImage(docId);
                    }

                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Update',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: isMobileOrTablet ? 14 : 16),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Function to upload image
  Future<void> _uploadImage(String uid) async {
    if (_selectedFilePath != null && _selectedImageFile != null) {
      String fileName = _selectedFilePath!;
      Reference storageReference =
          _storage.ref().child('DriverImages/$uid/$fileName');
      UploadTask uploadTask = storageReference.putData(_selectedImageFile!);
      TaskSnapshot snapshot = await uploadTask;
      String downloadURL = await snapshot.ref.getDownloadURL();

      // Update the Firestore document with the new image URL
      await _firestore.collection('Driver').doc(uid).update({
        'driverImage': downloadURL,
      });
    }
  }

  // Function to update user details in Firestore
  Future<void> _updateUser(
      String docId, Map<String, dynamic> updatedData) async {
    await _firestore.collection('Driver').doc(docId).update(updatedData);
  }

  // Function to clear selected image
  void _clearImage() {
    setState(() {
      _selectedFilePath = null;
      _selectedImageFile = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobileOrTablet = screenWidth < 850; // Adjust breakpoint as needed

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: secondaryColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Registered Users',
              style: TextStyle(
                fontSize: isMobileOrTablet ? 20 : 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Filter by Role',
                border: OutlineInputBorder(),
              ),
              value: _selectedFilter,
              items: const [
                DropdownMenuItem(
                  value: 'All',
                  child: Text('All', style: TextStyle(color: Colors.white)),
                ),
                DropdownMenuItem(
                  value: 'Driver',
                  child: Text('Driver', style: TextStyle(color: Colors.white)),
                ),
                DropdownMenuItem(
                  value: 'Dispatcher',
                  child:
                      Text('Dispatcher', style: TextStyle(color: Colors.white)),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedFilter = value;
                });
              },
            ),
            const SizedBox(height: 16),
            StreamBuilder<QuerySnapshot>(
              stream: _fetchUsers(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final users = snapshot.data!.docs;

                return ListView.builder(
                  shrinkWrap: true, // Added shrinkWrap
                  physics:
                      const NeverScrollableScrollPhysics(), // Disabled scrolling
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    final userData = user.data() as Map<String, dynamic>;
                    final userName = userData['driverName'] ?? 'No Name';
                    final userRole = userData['role'] ?? 'No Role';
                    final userImageURL = userData['driverImage'] ?? '';

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 4,
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: isMobileOrTablet ? 20 : 25,
                          backgroundImage:
                              (userImageURL != null && userImageURL.isNotEmpty)
                                  ? NetworkImage(userImageURL)
                                  : const AssetImage('assets/images/driver.png')
                                      as ImageProvider,
                          backgroundColor: bgColor,
                        ),
                        title: Text(
                          userName,
                          style: TextStyle(
                              fontSize: isMobileOrTablet ? 14 : 16),
                        ),
                        subtitle: Text(
                          'Role: $userRole',
                          style: TextStyle(
                              fontSize: isMobileOrTablet ? 12 : 14),
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'Update') {
                              _showUpdateDialog(userData, user.id);
                            } else if (value == 'Delete') {
                              _deleteUser(user.id, userData['uid'],
                                  userData['driverImage']);
                            }
                          },
                          itemBuilder: (BuildContext context) {
                            return const [
                              PopupMenuItem<String>(
                                value: 'Update',
                                child: Text('Update'),
                              ),
                              PopupMenuItem<String>(
                                value: 'Delete',
                                child: Text('Delete'),
                              ),
                            ];
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Function to delete user from Firebase Authentication, Firestore, and Firebase Storage
  Future<void> _deleteUser(
      String docId, String uid, String? imageURL) async {
    try {
      // Show confirmation dialog
      bool confirm = await _showDeleteConfirmationDialog();
      if (!confirm) return;

      // Delete from Firestore
      await _firestore.collection('Driver').doc(docId).delete();

      // Delete image from Firebase Storage if exists
      if (imageURL != null && imageURL.isNotEmpty) {
        await _storage.refFromURL(imageURL).delete();
      }

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'User deleted successfully.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: coral,
          duration: Duration(milliseconds: 600),
        ),
      );
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to delete user: $e',
                style: const TextStyle(color: Colors.white)),
            backgroundColor: orange,
            duration: const Duration(milliseconds: 600)),
      );
    }
  }

  // Function to show confirmation dialog before deletion
  Future<bool> _showDeleteConfirmationDialog() async {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobileOrTablet = screenWidth < 850;

    bool confirmed = false;
    await showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap a button to dismiss
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: darkGrey,
          title: Text('Confirm Deletion',
              style: TextStyle(
                  color: Colors.white, fontSize: isMobileOrTablet ? 16 : 18)),
          content: Text(
              'Are you sure you want to delete this user? All related data will be removed.',
              style: TextStyle(
                  color: Colors.white, fontSize: isMobileOrTablet ? 14 : 16)),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel',
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: isMobileOrTablet ? 14 : 16)),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                confirmed = false;
              },
            ),
            TextButton(
              child: Text('Confirm',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: isMobileOrTablet ? 14 : 16)),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                confirmed = true;
              },
            ),
          ],
        );
      },
    );
    return confirmed;
  }
}