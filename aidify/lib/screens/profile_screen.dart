import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:aidify/screens/home_screen.dart'; // Import your HomeScreen
import 'package:aidify/screens/login_screen.dart'; // Import your LoginScreen

class ProfilePage extends StatelessWidget {
  final String userId;

  const ProfilePage({super.key, required this.userId});

  int _calculateAge(DateTime dob) {
    final today = DateTime.now();
    int age = today.year - dob.year;
    if (today.month < dob.month ||
        (today.month == dob.month && today.day < dob.day)) {
      age--;
    }
    return age;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final size = MediaQuery.of(context).size;
      final width = size.width;

      return Scaffold(
        backgroundColor: const Color(0xFFF6E2E2),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF6E2E2),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.red),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }
              },
            )
          ],
        ),
        body: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final userData = snapshot.data!.data() as Map<String, dynamic>;
            final username = userData['username'] ?? 'User';
            final email = userData['email'] ?? 'Email not available';
            final dob = DateTime.tryParse(userData['dob']) ?? DateTime(2000);
            final age = _calculateAge(dob);

            return SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Profile Icon
                  Container(
                    width: width * 0.35,
                    height: width * 0.35,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF9DDEFF),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromRGBO(84, 152, 167, 0.25),
                          offset: const Offset(0, 15),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Icon(Icons.person, size: width * 0.23, color: Colors.black),
                  ),

                  const SizedBox(height: 20),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFF7F7),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                      border: Border(
                        top: BorderSide(color: Color(0xFFFF0909), width: 6),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildProfileText(username, fontSize: 24, fontWeight: FontWeight.bold),
                        const SizedBox(height: 8),
                        _buildProfileText(email, color: Colors.black54),
                        const SizedBox(height: 16),
                        _buildProfileText("Age: $age years"),
                        const SizedBox(height: 10),
                        _buildProfileText("Blood Group: ${userData['blood_group'] ?? ''}"),
                        const SizedBox(height: 10),
                        _buildProfileText("Rh Factor: ${userData['rh_factor'] ?? ''}"),
                        const SizedBox(height: 10),
                        _buildProfileText("Health Concerns: ${userData['health_concerns'] ?? ''}"),
                        const SizedBox(height: 10),
                        _buildProfileText("Address: ${userData['address'] ?? ''}"),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditProfilePage(userId: userId),
                              ),
                            );
                          },
                          child: const Text('Edit Profile'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    } else {
      return LoginPage();
    }
  }

  Widget _buildProfileText(String text,
      {double fontSize = 20,
      FontWeight fontWeight = FontWeight.w400,
      Color color = Colors.black}) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontFamily: 'Josefin Sans',
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      ),
    );
  }
}

class EditProfilePage extends StatefulWidget {
  final String userId;
  const EditProfilePage({super.key, required this.userId});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _dobController;
  late TextEditingController _bloodGroupController;
  late TextEditingController _rhFactorController;
  late TextEditingController _healthConcernsController;
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _dobController = TextEditingController();
    _bloodGroupController = TextEditingController();
    _rhFactorController = TextEditingController();
    _healthConcernsController = TextEditingController();
    _addressController = TextEditingController();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();
    final data = doc.data() ?? {};
    _usernameController.text = data['username'] ?? '';
    _emailController.text = data['email'] ?? '';
    _dobController.text = data['dob'] ?? '';
    _bloodGroupController.text = data['blood_group'] ?? '';
    _rhFactorController.text = data['rh_factor'] ?? '';
    _healthConcernsController.text = data['health_concerns'] ?? '';
    _addressController.text = data['address'] ?? '';
    setState(() {});
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance.collection('users').doc(widget.userId).update({
        'username': _usernameController.text,
        'email': _emailController.text,
        'dob': _dobController.text,
        'blood_group': _bloodGroupController.text,
        'rh_factor': _rhFactorController.text,
        'health_concerns': _healthConcernsController.text,
        'address': _addressController.text,
      });
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _dobController,
                decoration: const InputDecoration(labelText: 'Date of Birth (YYYY-MM-DD)'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _bloodGroupController,
                decoration: const InputDecoration(labelText: 'Blood Group'),
              ),
              TextFormField(
                controller: _rhFactorController,
                decoration: const InputDecoration(labelText: 'Rh Factor'),
              ),
              TextFormField(
                controller: _healthConcernsController,
                decoration: const InputDecoration(labelText: 'Health Concerns'),
              ),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _save,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
