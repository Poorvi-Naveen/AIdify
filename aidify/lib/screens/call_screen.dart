import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../screens/home_screen.dart';
import '../screens/bookmark_screen.dart';
import '../screens/message_screen.dart';
import '../screens/call_screen.dart';
import '../screens/profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmergencyContact {
  final String name;
  final String phone;

  EmergencyContact({required this.name, required this.phone});

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      name: json['name'],
      phone: json['phone'],
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'phone': phone,
  };
}

class EmergencyContactsPage extends StatefulWidget {
  const EmergencyContactsPage({super.key});

  @override
  State<EmergencyContactsPage> createState() => _EmergencyContactsPageState();
}

class _EmergencyContactsPageState extends State<EmergencyContactsPage> {
  List<EmergencyContact> contacts = [];


  @override
void initState() {
  super.initState();
  _loadEmergencyContacts();
}

Future<void> _loadEmergencyContacts() async {
  final prefs = await SharedPreferences.getInstance();
  final List<String>? savedContacts = prefs.getStringList('emergencyContacts');

  if (savedContacts != null) {
    setState(() {
      contacts = savedContacts.map((jsonString) {
        final data = jsonDecode(jsonString);
        return EmergencyContact.fromJson(data);
      }).toList();
    });
  }
}


Future<void> _pickContactAndSave() async {
  if (await Permission.contacts.request().isGranted) {
    final Contact? contact = await FlutterContacts.openExternalPick();
    if (contact != null && contact.phones.isNotEmpty) {
      final phone = contact.phones.first.number;
      final name = contact.displayName;

      final prefs = await SharedPreferences.getInstance();
      List<String> savedContacts = prefs.getStringList('emergencyContacts') ?? [];

      final newContact = EmergencyContact(name: name, phone: phone);
      savedContacts.add(jsonEncode(newContact.toJson()));
      await prefs.setStringList('emergencyContacts', savedContacts);

      setState(() {
        contacts.add(newContact);
      });
    }
  } else {
    openAppSettings();
  }
}


  void _makeCall(String number) async {
    if (await Permission.phone.request().isGranted) {
      final Uri callUri = Uri(scheme: 'tel', path: number);
      if (await canLaunchUrl(callUri)) {
        await launchUrl(callUri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch dialer')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Phone permission is required to make a call'),
        ),
      );
      openAppSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCEAEA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6E2E2),
        leading: Padding(
          padding: const EdgeInsets.all(12),
          child: Image.asset('assets/images/logo_image1.png'),
        ),
        title: const Text(
          'Emergency Contacts',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.black),
            onPressed: () async {
              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(userId: user.uid),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search contacts...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            color: Colors.red,
            child: ListTile(
              leading: const Icon(Icons.call, color: Colors.white),
              title: const Text(
                'EMERGENCY CONTACT\n112',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () => _makeCall('112'),
            ),
          ),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.only(left: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Emergency Contacts',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                final contact = contacts[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: ListTile(
                    title: Text(contact.name),
                    trailing: IconButton(
                            icon: const Icon(Icons.call),
                            onPressed: () => _makeCall(contact.phone),
                          )
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        height: 60,
        color: const Color.fromRGBO(229, 57, 53, 0.99),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.home, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.bookmark, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BookmarksPage()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.message, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MessageScreen()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.phone, color: Colors.white),
              onPressed: () {
                // Already on EmergencyContactsPage, so do nothing or maybe scroll to top
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        child: const Icon(Icons.person_add),
        onPressed: _pickContactAndSave,
      ),
    );
  }
}
