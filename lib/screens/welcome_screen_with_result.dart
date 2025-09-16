import 'package:a_eye/database/app_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:a_eye/widgets/result_card.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class WelcomeScreenWithResult extends StatefulWidget {
  final VoidCallback onNext;
  final String userName;

  const WelcomeScreenWithResult({
    super.key,
    required this.onNext,
    required this.userName,
  });

  @override
  State<WelcomeScreenWithResult> createState() =>
      _WelcomeScreenWithResultState();
}

class _WelcomeScreenWithResultState extends State<WelcomeScreenWithResult> {
  late Future<List<Scan>> _scanHistoryFuture;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    final database = Provider.of<AppDatabase>(context, listen: false);
    // Initialize the future that fetches the user and their scans
    _scanHistoryFuture = _fetchScanHistory(database);
  }

  // Helper method to fetch data
  Future<List<Scan>> _fetchScanHistory(AppDatabase database) async {
    // First, get the latest user
    _currentUser = await database.getLatestUser();
    if (_currentUser != null) {
      // Then, get the scans for that user
      return database.getScansForUser(_currentUser!.id);
    }
    // Return an empty list if no user is found
    return [];
  }

  @override
  Widget build(BuildContext context) {
    // No need to access the database here directly anymore
    // We will use the FutureBuilder to handle the data

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/Background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            // Top icons and other UI...
            SafeArea(
              child: Stack(
                children: [
                  // Profile button - top left
                  Positioned(
                    top: 20,
                    left: 30,
                    child: Image.asset(
                      'assets/images/Profile btn.png',
                      width: 48,
                      height: 48,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.menu,
                            color: Colors.white, size: 28);
                      },
                    ),
                  ),

                  // A-Eye icon - top right
                  Positioned(
                    top: -30,
                    right: 0,
                    child: SizedBox(
                      width: 160,
                      height: 160,
                      child: Image.asset(
                        'assets/images/A-Eye Icon.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.info_outline,
                              color: Colors.white, size: 28);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Main content
            Align(
              alignment: const Alignment(0.0, 0.5), // horizontal then vertical
              child: SingleChildScrollView(
                padding:
                const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text.rich(
                            TextSpan(
                              style: GoogleFonts.urbanist(
                                fontSize: 40,
                                color: Colors.white,
                              ),
                              children: [
                                const TextSpan(text: "Welcome Back, "),
                                TextSpan(
                                  // Use the fetched user name or the passed argument as a fallback
                                  text: _currentUser?.name ?? widget.userName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                const TextSpan(text: "!"),
                              ],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.visible,
                            textAlign: TextAlign.left,
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Outer box...
                    Container(
                      padding: const EdgeInsets.fromLTRB(
                          22, 12, 22, 16), // LEFT TOP RIGHT BOTTOM
                      decoration: BoxDecoration(
                        color: Colors.white12.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Thank you for choose A-Eye!",
                            style: GoogleFonts.urbanist(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Inner box
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white12,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              "Ready for your next scan? Tap below to get started.",
                              textAlign: TextAlign.left,
                              style: GoogleFonts.urbanist(
                                fontSize: 17,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text(
                      "Your Eye Health History",
                      style: GoogleFonts.urbanist(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: const Color(0XFF5244F3),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Results box container
                    Container(
                      width: double.infinity,
                      height: 300,
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF131A21),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: FutureBuilder<List<Scan>>(
                        future: _scanHistoryFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(
                                child:
                                Text('Error: ${snapshot.error}'));
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return const Center(
                                child: Text('No scan history found.', style: TextStyle(color: Colors.white),));
                          }

                          final results = snapshot.data!;
                          return ListView.builder(
                            itemCount: results.length,
                            padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
                            itemBuilder: (context, index) {
                              final result = results[index];
                              return ResultCard(
                                // Format the DateTime object
                                date: DateFormat('MMMM d, y, h:mm a').format(result.timestamp),
                                title: result.result,
                                imageFilePath: result.imagePath,
                                showLabel: index == 0,
                              );
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 32),

                    // start eye scan button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: widget.onNext,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5244F3),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 28, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            SizedBox(
                              height: 40,
                              width: 40,
                              child: Image.asset(
                                'assets/images/eye_scan_sprite.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              "Start Eye Scan",
                              style: GoogleFonts.urbanist(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}