import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:movie_app/models/movie.dart';
import 'package:movie_app/screens/auth/auth_screen.dart';
import 'package:movie_app/screens/movie/movie_detail_screen.dart';
import 'package:movie_app/screens/profile/widgets/animated_watchlist_item.dart';
import 'package:movie_app/services/watchlist_service.dart';
import 'package:movie_app/widgets/gradient_card.dart';
import 'package:movie_app/widgets/hover_animated_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final WatchlistService _watchlistService = WatchlistService();

  late TextEditingController _nameController;
  bool _isEditingName = false;

  List<Movie> _localWatchlist = [];

  @override
  void initState() {
    super.initState();
    final user = _auth.currentUser;
    if (user != null &&
        (user.displayName == null || user.displayName!.isEmpty)) {
      final randomName = _generateRandomName();
      user.updateDisplayName(randomName).then((_) => setState(() {}));
    }
    _nameController = TextEditingController(text: user?.displayName ?? '');
  }

  String _generateRandomName() {
    final random = Random();
    final randomNumber = random.nextInt(99999);
    return 'user_$randomNumber';
  }

  Future<void> _saveDisplayName() async {
    final user = _auth.currentUser;
    if (user == null) return;
    final newName = _nameController.text.trim();
    if (newName.isNotEmpty) {
      await user.updateDisplayName(newName);
      setState(() {
        _isEditingName = false;
      });
      showCustomSnackBar(context, 'Name updated successfully!');
    }
  }

  Future<void> _pickAndUploadAvatar() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    final user = _auth.currentUser;
    if (user == null) return;

    final file = File(pickedFile.path);
    final storageRef = firebase_storage.FirebaseStorage.instance
        .ref()
        .child('user_avatars')
        .child('${user.uid}.jpg');

    try {
      await storageRef.putFile(file);
      final downloadUrl = await storageRef.getDownloadURL();
      await user.updatePhotoURL(downloadUrl);
      setState(() {});
      showCustomSnackBar(context, 'Avatar updated!');
    } catch (e) {
      showCustomSnackBar(context, 'Upload failed: $e');
    }
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AuthScreen()),
      (route) => false,
    );
  }

  void _syncLocalList(List<Movie> freshList) {
    _localWatchlist = List.from(freshList);
  }

  void _removeMovieFromList(Movie movie) {
    setState(() {
      _localWatchlist.removeWhere((m) => m.id == movie.id);
    });
    _watchlistService.removeFromWatchlist(movie.id);
    showCustomSnackBar(context, '${movie.title} removed');
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: Text('No user signed in.')),
      );
    }
    final photoUrl = user.photoURL;
    final displayName = user.displayName ?? '';
    final email = user.email ?? 'No email';

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(
                width: 300,
                child: GradientCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            photoUrl != null
                                ? CircleAvatar(
                                  radius: 40,
                                  backgroundImage: NetworkImage(photoUrl),
                                )
                                : const CircleAvatar(
                                  backgroundColor: Colors.white70,
                                  radius: 40,
                                  child: Icon(Icons.person, size: 40),
                                ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: _pickAndUploadAvatar,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                      width: 1.5,
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(4),
                                  child: const Icon(
                                    Icons.edit,
                                    size: 16,
                                    color: Colors.teal,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(width: 50),
                            if (!_isEditingName)
                              Container(
                                constraints: const BoxConstraints(
                                  maxWidth: 150,
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    displayName,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              )
                            else
                              SizedBox(
                                width: 150,
                                child: TextField(
                                  controller: _nameController,
                                  textAlign: TextAlign.center,
                                  decoration: const InputDecoration(
                                    labelText: 'Your Name',
                                  ),
                                ),
                              ),
                            const SizedBox(width: 8),
                            animatedButton(
                              button: IconButton(
                                icon: Icon(
                                  _isEditingName
                                      ? Icons.check_circle
                                      : Icons.edit_note,
                                  color: Colors.teal,
                                  size: 28,
                                ),
                                onPressed: () {
                                  if (_isEditingName) {
                                    _saveDisplayName();
                                  } else {
                                    setState(() => _isEditingName = true);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),

                        Text(
                          email,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: 150,
                          child: animatedButton(
                            button: ElevatedButton.icon(
                              onPressed: _signOut,
                              icon: const Icon(Icons.logout),
                              label: const Text('Sign Out'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                minimumSize: const Size.fromHeight(40),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2C2F36), Color(0xFF3C3F47)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(color: Colors.teal, width: 1),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My Watchlist',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const Divider(height: 1),
                    const SizedBox(height: 8),
                    StreamBuilder<List<Movie>>(
                      stream: _watchlistService.watchlistStream(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'Error: ${snapshot.error}',
                              style: const TextStyle(color: Colors.white),
                            ),
                          );
                        }
                        if (!snapshot.hasData) {
                          return const SizedBox(
                            height: 400,
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        final watchlist = snapshot.data!;
                        _syncLocalList(watchlist);
                        if (_localWatchlist.isEmpty) {
                          return const SizedBox(
                            height: 400,
                            child: Center(
                              child: Text(
                                'No movies in watchlist.',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          );
                        }
                        return SizedBox(
                          height: 400,
                          child: ListView.builder(
                            itemCount: _localWatchlist.length,
                            itemBuilder: (context, index) {
                              final movie = _localWatchlist[index];
                              return AnimatedWatchlistItem(
                                key: ValueKey(movie.id),
                                movie: movie,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) => MovieDetailScreen(
                                            movie: movie,
                                            showWatchlistButton: false,
                                          ),
                                    ),
                                  );
                                },
                                onRemove: () {
                                  _removeMovieFromList(movie);
                                },
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showCustomSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Colors.deepPurple,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 3),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
