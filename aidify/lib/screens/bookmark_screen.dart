import 'package:aidify/screens/topic_detail_screen.dart';
import 'package:flutter/material.dart';
import '../models/bookmark_manager.dart';
import 'package:aidify/screens/profile_screen.dart';
import 'package:aidify/screens/home_screen.dart';
import 'package:aidify/screens/chat_screen.dart';
import 'package:aidify/screens/call_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookmarksPage extends StatefulWidget {
  const BookmarksPage({Key? key}) : super(key: key);

  @override
  _BookmarksPageState createState() => _BookmarksPageState();
}

class _BookmarksPageState extends State<BookmarksPage> {
  late List<String> _filteredBookmarks;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _filteredBookmarks = BookmarkManager().getBookmarks();
    BookmarkManager().addListener(_updateBookmarks);
  }

  @override
  void dispose() {
    BookmarkManager().removeListener(_updateBookmarks);
    super.dispose();
  }

  void _updateBookmarks() {
    setState(() {
      _filteredBookmarks = BookmarkManager()
          .getBookmarks()
          .where((bookmark) =>
              bookmark.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _filteredBookmarks = BookmarkManager()
          .getBookmarks()
          .where((bookmark) =>
              bookmark.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6E2E2),
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(12),
          child: Image.asset('assets/images/logo_image1.png'),
        ),
        title: const Text(
          'Bookmarks',
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
          // Modern search bar (like HomeScreen)
          Padding(
            padding: const EdgeInsets.only(top: 24, left: 23, right: 23, bottom: 12),
            child: Container(
              width: double.infinity,
              height: 59,
              decoration: BoxDecoration(
                color: const Color(0xFFD8EEFF),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: TextField(
                  onChanged: _onSearchChanged,
                  decoration: const InputDecoration(
                    hintText: 'Search bookmarks...',
                    border: InputBorder.none,
                    icon: Icon(Icons.search_outlined, size: 30),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.grey[300],
              child: _filteredBookmarks.isEmpty
                  ? const Center(child: Text('No bookmarks yet.'))
                  : ListView.builder(
                      itemCount: _filteredBookmarks.length,
                      itemBuilder: (context, index) {
                        final title = _filteredBookmarks[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 8),
                            title: Text(
                              title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontFamily: 'Josefin Sans',
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.star, color: Colors.black),
                              onPressed: () async {
                                await BookmarkManager().removeBookmark(context, title);
                              },
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TopicDetailScreen(topicLabel: title),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
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
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.bookmark, color: Colors.white),
              onPressed: () {}, // Already on bookmarks
            ),
            IconButton(
              icon: const Icon(Icons.message, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChatScreen()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.phone, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EmergencyContactsPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
