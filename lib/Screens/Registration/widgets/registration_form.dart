import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:gptransco/const/colors/colors.dart';
import 'package:intl/intl.dart'; // For formatting dates

class RegistrationForm extends StatefulWidget {
  const RegistrationForm({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RegistrationFormState createState() => _RegistrationFormState();
}

enum Gender { male, female }

class _RegistrationFormState extends State<RegistrationForm> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _middleNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _birthdateController = TextEditingController();
  final TextEditingController _totalSeatsController = TextEditingController();
  final TextEditingController _vehicleColorController = TextEditingController();
  final TextEditingController _plateNumberController = TextEditingController();
  final TextEditingController _fuelTypeController = TextEditingController();
  final TextEditingController _strictedController = TextEditingController();

  Gender? _selectedGender;
  String? _selectedRole;
  String? _selectedFilePath;
  Uint8List? _selectedImageFile; // Use Uint8List for web image data

  // Function to open a date picker and set the selected birthdate
  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _birthdateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  // Function to upload the image to Firebase Storage and get the download URL
  Future<String?> _uploadImage(String uid) async {
    if (_selectedFilePath != null && _selectedImageFile != null) {
      String fileName = _selectedFilePath!; // Use the file name
      try {
        Reference storageReference = _storage
            .ref()
            .child('DriverImages/$uid/$fileName'); // Path in Firebase Storage
        UploadTask uploadTask = storageReference
            .putData(_selectedImageFile!); // Use putData for web (bytes)
        TaskSnapshot snapshot = await uploadTask;
        String downloadURL = await snapshot.ref.getDownloadURL();
        return downloadURL; // Return the download URL
      } catch (e) {
        // ignore: avoid_print
        print('Error uploading image: $e');
        return null;
      }
    }
    return null;
  }

  // Function to ask for confirmation before registering
  Future<void> _showConfirmationDialog() async {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobileOrTablet = screenWidth < 850;

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap a button to dismiss
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: navy,
          title: Text('Confirm Registration',
              style: TextStyle(
                  color: Colors.white, fontSize: isMobileOrTablet ? 16 : 18)),
          content: Text('Are you sure you want to register this user?',
              style: TextStyle(
                  color: Colors.white, fontSize: isMobileOrTablet ? 14 : 16)),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: isMobileOrTablet ? 14 : 16)),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text('Confirm',
                  style: TextStyle(
                      color: Colors.green,
                      fontSize: isMobileOrTablet ? 14 : 16)),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _register(); // Proceed with registration if confirmed
              },
            ),
          ],
        );
      },
    );
  }

  // Registration function
  Future<void> _register() async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      User? user = userCredential.user;

      if (user != null) {
        String? imageURL = await _uploadImage(user.uid);

        String fullName =
            '${_lastNameController.text.trim()}, ${_firstNameController.text.trim()} ${_middleNameController.text.trim()}';

        // Determine the value of isDriver and Availability based on the selected role
        bool isDriver = _selectedRole == 'Driver';
        bool availability = _selectedRole == 'Driver';

        // Store driver data in Firestore 'Driver' collection
        await _firestore.collection('Driver').doc(user.uid).set({
          'driverName': fullName,
          'Price': "",
          'Availability': availability,
          'birthdate': _birthdateController.text.trim(),
          'gender': _selectedGender == Gender.male ? 'Male' : 'Female',
          'nickname': _nicknameController.text.trim(),
          'address': _addressController.text.trim(),
          'mobileNumber': _mobileController.text.trim(),
          'role': _selectedRole,
          'isDriver': isDriver, // Add isDriver field here
          'email': user.email,
          'password': _passwordController.text
              .trim(), // Save password (insecure, for demonstration)
          'uid': user.uid,
          'driverImage': imageURL,
          'totalSeats': _totalSeatsController.text.trim(),
          'vehicleColor': _vehicleColorController.text.trim(),
          'plateNumber': _plateNumberController.text.trim(),
          'fuelType': _fuelTypeController.text.trim(),
          'Stricted': _strictedController.text.trim(),
        });

        // Clear all fields after successful registration
        _clearAllFields();

        // Show success message
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Registration successful!',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
            duration: Duration(milliseconds: 700),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = '';
      if (e.code == 'email-already-in-use') {
        message = 'The email is already in use.';
      } else if (e.code == 'weak-password') {
        message = 'The password is too weak.';
      } else {
        message = 'An error occurred. Please try again.';
      }
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  // Clear all input fields
  void _clearAllFields() {
    _firstNameController.clear();
    _lastNameController.clear();
    _middleNameController.clear();
    _emailController.clear();
    _passwordController.clear();
    _nicknameController.clear();
    _addressController.clear();
    _mobileController.clear();
    _birthdateController.clear();
    _totalSeatsController.clear();
    _vehicleColorController.clear();
    _plateNumberController.clear();
    _fuelTypeController.clear();
    _strictedController.clear();
    _selectedGender = null;
    _selectedRole = null;
    _selectedFilePath = null;
    _selectedImageFile = null;
    setState(() {});
  }

  // Function to select an image (Web-specific)
  void _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
      withData: true, // Required for accessing the file bytes in the web
    );

    if (result != null) {
      setState(() {
        _selectedFilePath =
            result.files.single.name; // Only file name is available on web
        _selectedImageFile = result.files.single.bytes; // Use bytes for web
      });
    }
  }

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
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          color: secondaryColor,
        ),
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Register New User',
                style: TextStyle(
                  fontSize: isMobileOrTablet ? 20 : 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // Role Dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Role',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Driver',
                    child: Text('Driver'),
                  ),
                  DropdownMenuItem(
                    value: 'Dispatcher',
                    child: Text('Dispatcher'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedRole = value;
                  });
                },
              ),
              const SizedBox(height: 24),

              // Name Fields
              isMobileOrTablet
                  ? Column(
                      children: [
                        TextFormField(
                          controller: _lastNameController,
                          decoration: const InputDecoration(
                            labelText: 'Last Name',
                            border: OutlineInputBorder(),
                          ),
                          enabled: _selectedRole != null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _firstNameController,
                          decoration: const InputDecoration(
                            labelText: 'First Name',
                            border: OutlineInputBorder(),
                          ),
                          enabled: _selectedRole != null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _middleNameController,
                          decoration: const InputDecoration(
                            labelText: 'Middle Name',
                            border: OutlineInputBorder(),
                          ),
                          enabled: _selectedRole != null,
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _lastNameController,
                            decoration: const InputDecoration(
                              labelText: 'Last Name',
                              border: OutlineInputBorder(),
                            ),
                            enabled: _selectedRole != null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _firstNameController,
                            decoration: const InputDecoration(
                              labelText: 'First Name',
                              border: OutlineInputBorder(),
                            ),
                            enabled: _selectedRole != null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _middleNameController,
                            decoration: const InputDecoration(
                              labelText: 'Middle Name',
                              border: OutlineInputBorder(),
                            ),
                            enabled: _selectedRole != null,
                          ),
                        ),
                      ],
                    ),
              const SizedBox(height: 24),

              // Birthdate Field with DatePicker
              TextFormField(
                controller: _birthdateController,
                readOnly: true, // Makes the field non-editable
                decoration: const InputDecoration(
                  labelText: 'Birthdate',
                  border: OutlineInputBorder(),
                ),
                enabled: _selectedRole != null,
                onTap: _selectedRole != null
                    ? () => _selectDate(context) // Opens the date picker on tap
                    : null,
              ),
              const SizedBox(height: 24),

              // Gender Selection
              Text(
                'Gender',
                style: TextStyle(fontSize: isMobileOrTablet ? 14 : 16),
              ),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<Gender>(
                      title: Text('Male',
                          style:
                              TextStyle(fontSize: isMobileOrTablet ? 14 : 16)),
                      value: Gender.male,
                      groupValue: _selectedGender,
                      onChanged: _selectedRole != null
                          ? (Gender? value) {
                              setState(() {
                                _selectedGender = value;
                              });
                            }
                          : null,
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<Gender>(
                      title: Text('Female',
                          style:
                              TextStyle(fontSize: isMobileOrTablet ? 14 : 16)),
                      value: Gender.female,
                      groupValue: _selectedGender,
                      onChanged: _selectedRole != null
                          ? (Gender? value) {
                              setState(() {
                                _selectedGender = value;
                              });
                            }
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Nickname Field
              TextFormField(
                controller: _nicknameController,
                decoration: const InputDecoration(
                  labelText: 'Nickname',
                  border: OutlineInputBorder(),
                ),
                enabled: _selectedRole != null,
              ),
              const SizedBox(height: 24),

              // Address Field
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                ),
                enabled: _selectedRole != null,
              ),
              const SizedBox(height: 24),

              // Mobile Field
              TextFormField(
                controller: _mobileController,
                decoration: const InputDecoration(
                  labelText: 'Mobile Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                enabled: _selectedRole != null,
              ),
              const SizedBox(height: 24),

              // Email Field
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                enabled: _selectedRole != null,
              ),
              const SizedBox(height: 24),

              // Password Field
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                enabled: _selectedRole != null,
              ),
              const SizedBox(height: 24),

              // Total Seats Field
              TextFormField(
                controller: _totalSeatsController,
                decoration: const InputDecoration(
                  labelText: 'Total Seats',
                  border: OutlineInputBorder(),
                ),
                enabled: _selectedRole == 'Driver',
              ),
              const SizedBox(height: 24),

              // Vehicle Color Field
              TextFormField(
                controller: _vehicleColorController,
                decoration: const InputDecoration(
                  labelText: 'Vehicle Color',
                  border: OutlineInputBorder(),
                ),
                enabled: _selectedRole == 'Driver',
              ),
              const SizedBox(height: 24),

              // Plate Number Field
              TextFormField(
                controller: _plateNumberController,
                decoration: const InputDecoration(
                  labelText: 'Plate Number',
                  border: OutlineInputBorder(),
                ),
                enabled: _selectedRole == 'Driver',
              ),
              const SizedBox(height: 24),

              // Fuel Type Field
              TextFormField(
                controller: _fuelTypeController,
                decoration: const InputDecoration(
                  labelText: 'Fuel Type',
                  border: OutlineInputBorder(),
                ),
                enabled: _selectedRole == 'Driver',
              ),
              const SizedBox(height: 24),

              // Stricted Field
              TextFormField(
                controller: _strictedController,
                decoration: const InputDecoration(
                  labelText: 'Stricted',
                  border: OutlineInputBorder(),
                ),
                enabled: _selectedRole != null && _selectedRole != 'Dispatcher',
              ),
              const SizedBox(height: 32),

              // Image Picker section
              GestureDetector(
                onTap: _selectedRole != null ? _pickImage : null,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DottedBorder(
                    color: Colors.blue,
                    strokeWidth: 1,
                    dashPattern: const [6, 3],
                    borderType: BorderType.RRect,
                    radius: const Radius.circular(10),
                    child: Container(
                      width: double.infinity,
                      height: isMobileOrTablet ? 100 : 150,
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: _selectedImageFile != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.memory(
                                _selectedImageFile!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: isMobileOrTablet ? 100 : 150,
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image,
                                  color: Colors.blue,
                                  size: isMobileOrTablet ? 40 : 50,
                                ),
                                const SizedBox(height: 10),
                                Text.rich(
                                  TextSpan(
                                    text: 'Drop your image here, or ',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: isMobileOrTablet ? 12 : 14),
                                    children: [
                                      TextSpan(
                                        text: 'browse',
                                        style: TextStyle(
                                          color: Colors.blue,
                                          decoration: TextDecoration.underline,
                                          fontSize: isMobileOrTablet ? 12 : 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'Supports: JPG, JPEG2000, PNG',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: isMobileOrTablet ? 12 : 14),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
              if (_selectedImageFile != null)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: _clearImage,
                    icon: const Icon(Icons.delete, color: Colors.red),
                    label: Text(
                      'Remove Image',
                      style: TextStyle(
                          color: Colors.red,
                          fontSize: isMobileOrTablet ? 12 : 14),
                    ),
                  ),
                ),
              const SizedBox(height: 32),

              // Register Button
              Center(
                child: ElevatedButton(
                  onPressed: _selectedRole != null
                      ? () {
                          _showConfirmationDialog(); // Show confirmation dialog
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(
                        vertical: isMobileOrTablet ? 12 : 16,
                        horizontal: isMobileOrTablet ? 16 : 24),
                    backgroundColor: darkGreen,
                    elevation: 0.7,
                    shadowColor: white,
                  ),
                  child: Text(
                    'Register',
                    style: TextStyle(
                        fontSize: isMobileOrTablet ? 14 : 16,
                        color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
