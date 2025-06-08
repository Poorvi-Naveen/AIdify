import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:aidify/screens/bookmark_screen.dart';
import 'package:aidify/screens/call_screen.dart';
import 'package:aidify/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'topic_detail_screen.dart';
import 'package:aidify/screens/profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/bookmark_manager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> allTopics = [];
  List<Map<String, dynamic>> filteredTopics = [];
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    loadTopics();
  }

  Future<void> loadTopics() async {
    final String jsonString = await rootBundle.loadString('assets/data/topics.json');
    final List<dynamic> jsonList = jsonDecode(jsonString);
    setState(() {
      allTopics = List<Map<String, dynamic>>.from(jsonList);
      filteredTopics = allTopics;
    });
  }

  void _onSearchChanged(String value) {
    setState(() {
      isSearching = value.trim().isNotEmpty;
      filteredTopics = allTopics
          .where((topic) =>
              topic['title'].toString().toLowerCase().contains(value.trim().toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(width: 412, height: 917, color: Colors.white),

          // Top Navbar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 100,
            child: AppBar(
              backgroundColor: const Color(0xFFF6E2E2),
              elevation: 0,
              
              leading: Padding(
                padding: const EdgeInsets.all(12),
                child: Image.asset('assets/images/logo_image1.png'),
              ),
              title: const Text(
                'AIdify',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 22,
                ),
              ),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.person_outline, color: Colors.black),
                  onPressed: () {
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
          ),

          // Search bar
          Positioned(
            top: 135,
            left: 23,
            child: Container(
              width: 320,
              height: 59,
              decoration: BoxDecoration(
                color: Color(0xFFD8EEFF),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Quick search First Aid...',
                    border: InputBorder.none,
                    icon: Icon(Icons.search_outlined, size: 30),
                  ),
                  onChanged: _onSearchChanged,
                ),
              ),
            ),
          ),

          // Search results list
          if (isSearching)
            Positioned(
              top: 200,
              left: 23,
              right: 23,
              bottom: 100,
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: filteredTopics.isEmpty
                    ? Center(child: Text("No topics found."))
                    : ListView.builder(
                        itemCount: filteredTopics.length,
                        itemBuilder: (context, index) {
                          final topic = filteredTopics[index];
                          return ListTile(
                            leading: topic['imagePath'] != null
                                ? Image.asset(topic['imagePath'], width: 40, height: 40)
                                : null,
                            title: Text(topic['title']),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TopicDetailScreen(topicLabel: topic['title']),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ),

          // Only show scrollable sections if not searching
          if (!isSearching)
            Positioned(
              top: 225,
              left: 0,
              right: 0,
              bottom: 60,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    buildHorizontalScrollSection(
                      title: "Quick Help",
                      cards: [
                        {"label": "Sprain", "image": "assets/images/sprain.jpg"},
                        {
                          "label": "Snake Bite",
                          "image": "assets/images/snake.png",
                        },
                      ],
                    ),
                    buildHorizontalScrollSection(
                      title: "Circulatory FirstAid",
                      cards: [
                        {"label": "CPR", "image": "assets/images/cpr.png"},
                        {
                          "label": "Cardiac Arrest",
                          "image": "assets/images/cardiac_arrest.png",
                        },
                      ],
                    ),
                    buildHorizontalScrollSection(
                      title: "Respiratory FirstAid",
                      cards: [
                        {
                          "label": "Asthma attack",
                          "image": "assets/images/asthma.png",
                        },
                        {"label": "Choking", "image": "assets/images/snake.png"},
                      ],
                    ),
                    buildHorizontalScrollSection(
                      title: "Other Help",
                      cards: [
                        {"label": "Allergy", "image": "assets/images/sprain.jpg"},
                        {"label": "Burns", "image": "assets/images/burns.png"},
                      ],
                    ),
                  ],
                ),
              ),
            ),

          // Bottom Navbar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 60,
            child: Container(
              color: Color.fromRGBO(229, 57, 53, 0.99),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Icon(Icons.home, color: Colors.white),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => BookmarksPage()),
                      );
                    },
                    child: Icon(Icons.bookmark, color: Colors.white),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ChatScreen()),
                      );
                    },
                    child: Icon(Icons.message, color: Colors.white),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => EmergencyContactsPage()),
                      );
                    },
                    child: Icon(Icons.phone, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildHorizontalScrollSection({
    required String title,
    required List<Map<String, String>> cards, // Expect image & label
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              title,
              style: const TextStyle(fontFamily: 'Josefin Sans', fontSize: 24),
            ),
          ),
          SizedBox(
            height: 160,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: cards.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: BlueCard(
                    imagePath: cards[index]['image']!,
                    label: cards[index]['label']!,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class BlueCard extends StatefulWidget {
  final String imagePath;
  final String label;

  const BlueCard({required this.imagePath, required this.label, Key? key})
      : super(key: key);

  @override
  _BlueCardState createState() => _BlueCardState();
}

class _BlueCardState extends State<BlueCard> {
  late bool isFavorited;

  @override
  void initState() {
    super.initState();
    isFavorited = BookmarkManager().isBookmarked(widget.label);
    BookmarkManager().addListener(_updateBookmark);
  }

  @override
  void dispose() {
    BookmarkManager().removeListener(_updateBookmark);
    super.dispose();
  }

  void _updateBookmark() {
    setState(() {
      isFavorited = BookmarkManager().isBookmarked(widget.label);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TopicDetailScreen(topicLabel: widget.label),
          ),
        );
      },
      child: Container(
        width: 237,
        height: 130,
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF8BE6FF), Color(0xFF8BE6FF)],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            // Image
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(widget.imagePath, fit: BoxFit.cover),
              ),
            ),
            // Label at the bottom
            Positioned(
              bottom: 10,
              left: 10,
              child: Text(
                widget.label,
                style: const TextStyle(
                  fontFamily: 'Josefin Sans',
                  fontSize: 18,
                  color: Colors.white,
                  shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                ),
              ),
            ),
            // Star at the top right
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () async {
                  if (isFavorited) {
                    await BookmarkManager().removeBookmark(context, widget.label);
                  } else {
                    BookmarkManager().addBookmark(widget.label);
                  }
                },
                child: Icon(
                  isFavorited ? Icons.star : Icons.star_border,
                  color: isFavorited ? Colors.yellow[700] : Colors.white,
                  size: 28,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
