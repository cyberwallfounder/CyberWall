import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const CyberWallApp());
}

class CyberWallApp extends StatelessWidget {
  const CyberWallApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CyberWall',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
        primaryColor: const Color(0xFF00FF66),
      ),
      home: const WallpaperHomeScreen(),
    );
  }
}

class WallpaperHomeScreen extends StatefulWidget {
  const WallpaperHomeScreen({super.key});

  @override
  State<WallpaperHomeScreen> createState() => _WallpaperHomeScreenState();
}

class _WallpaperHomeScreenState extends State<WallpaperHomeScreen> {
  List wallpapers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchWallpapers();
  }

  Future<void> fetchWallpapers() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.pexels.com/v1/curated?per_page=15'),
        headers: {
          'Authorization': '563492ad6f91700001000101d297a7e8b8354cbfa88b698cfb3cd2b7'
        },
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          wallpapers = data['photos'];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'C Y B E R W A L L',
          style: TextStyle(
            color: Color(0xFF00FF66),
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
          ),
        ),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF00FF66),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.65,
              ),
              itemCount: wallpapers.length,
              itemBuilder: (context, index) {
                var photo = wallpapers[index];
                var imageUrl = photo['src']['medium'];

                return ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        color: Colors.grey[900],
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF00FF66),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}