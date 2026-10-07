import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const CyberWallApp());
}

class CyberWallApp extends StatelessWidget {
  const CyberWallApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CyberWall',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        primaryColor: Colors.greenAccent,
      ),
      home: const WallpaperHomePage(),
    );
  }
}

class WallpaperHomePage extends StatefulWidget {
  const WallpaperHomePage({Key? key}) : super(key: key);

  @override
  _WallpaperHomePageState createState() => _WallpaperHomePageState();
}

class _WallpaperHomePageState extends State<WallpaperHomePage> {
  List wallpapers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchWallpapers();
  }

  Future<void> fetchWallpapers() async {
    // Using Picsum API which requires no API key and provides high quality images
    final url = Uri.parse('https://picsum.photos/v2/list?page=1&limit=30');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          wallpapers = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
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
          style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, letterSpacing: 2),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.greenAccent))
          : wallpapers.isEmpty
              ? const Center(child: Text('No wallpapers found!', style: TextStyle(color: Colors.white)))
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
                    final photo = wallpapers[index];
                    // Constructing a high-res image URL from Picsum ID
                    final imageUrl = 'https://picsum.photos/id/${photo['id']}/600/900';
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: Colors.grey[900],
                            child: const Center(
                              child: CircularProgressIndicator(color: Colors.greenAccent, strokeWidth: 2),
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
