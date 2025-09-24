import 'package:a_eye/database/app_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:a_eye/widgets/result_card.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class WelcomeScreen extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onProfile;
  final String userName;
  final VoidCallback onGuide;

  const WelcomeScreen({
    super.key,
    required this.onNext,
    required this.onProfile,
    required this.userName,
    required this.onGuide,
  });

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  User? _currentUser;

  // This function remains the same
  Future<List<Scan>> _fetchScanHistory(AppDatabase database) async {
    _currentUser = await database.getLatestUser();
    if (_currentUser != null) {
      return database.getScansForUser(_currentUser!.id);
    }
    return [];
  }

  // --- FIX: Implement a refresh function ---
  Future<void> _refreshHistory() async {
    setState(() {
      // This will cause the FutureBuilder to re-run the _fetchScanHistory method
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get the database instance here, inside the build method
    final database = Provider.of<AppDatabase>(context, listen: false);

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
            // Top icons (no changes here)
            SafeArea(
              child: Stack(
                children: [
                  Positioned(
                    top: 20,
                    left: 30,
                    child: GestureDetector(
                      onTap: widget.onProfile,
                      child: Image.asset(
                        'assets/images/Profile btn.png',
                        width: 48,
                        height: 48,
                      ),
                    ),
                  ),

                  Positioned(
                    top: -30,
                    right: 0,
                    child: GestureDetector(
                      onTap: widget.onGuide,
                      child: SizedBox(
                        width: 160,
                        height: 160,
                        child: Image.asset('assets/images/A-Eye Icon.png'),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Main content
            Align(
              alignment: const Alignment(0.0, 0.5),
              child: RefreshIndicator(
                onRefresh: _refreshHistory,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(), // Ensures scrolling is always enabled for refresh
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                  child: FutureBuilder<List<Scan>>(
                    future: _fetchScanHistory(database), // This now runs every time the widget builds
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
                      }

                      final hasHistory = snapshot.hasData && snapshot.data!.isNotEmpty;
                      final results = snapshot.data ?? [];

                      // This ensures the most recent scan is always first.
                      results.sort((a, b) => b.timestamp.compareTo(a.timestamp));

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Greeting
                          Row(
                            children: [
                              Flexible(
                                child: Text.rich(
                                  TextSpan(
                                    style: GoogleFonts.urbanist(fontSize: 40, color: Colors.white),
                                    children: [
                                      TextSpan(text: hasHistory ? "Welcome Back, " : "Hello, "),
                                      TextSpan(
                                        text: _currentUser?.name ?? widget.userName,
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      const TextSpan(text: "!"),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Message box
                          Container(
                            padding: const EdgeInsets.fromLTRB(22, 12, 22, 16),
                            decoration: BoxDecoration(
                              color: Colors.white12.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  hasHistory ? "Thanks for choosing A-Eye!" : "Welcome to A-Eye!",
                                  style: GoogleFonts.urbanist(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(12)),
                                  child: Text(
                                    hasHistory ? "Ready for your next scan? Tap below to get started." : "Let's begin your journey with your very first eye scan!",
                                    style: GoogleFonts.urbanist(fontSize: 17, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // HAS HISTORY SECTION
                          if (hasHistory) ...[
                            Text(
                              "Your Eye Health History",
                              style: GoogleFonts.urbanist(fontSize: 25, fontWeight: FontWeight.bold, color: const Color(0XFF5244F3)),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              width: double.infinity,
                              height: 300,
                              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                              decoration: BoxDecoration(color: const Color(0xFF131A21), borderRadius: BorderRadius.circular(24)),
                              child: ListView.builder(
                                itemCount: results.length,
                                padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
                                itemBuilder: (context, index) {
                                  final result = results[index];
                                  return ResultCard(
                                    date: DateFormat('MMMM d, y, h:mm a').format(result.timestamp),
                                    title: result.result,
                                    imageFilePath: result.imagePath,
                                    showLabel: index == 0,
                                  );
                                },
                              ),
                            ),
                          ]

                          // HAS NO HISTORY WELCOME PAGE
                          else ...[
                            Center(
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 380,
                                    width: double.infinity,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(32),
                                      child: Image.asset('assets/images/Welcome Card.png', fit: BoxFit.contain),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 32),

                          // Start Eye Scan button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: widget.onNext,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF5244F3),
                                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: 40,
                                    width: 40,
                                    child: Image.asset('assets/images/eye_scan_sprite.png', fit: BoxFit.contain),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    "Start Eye Scan",
                                    style: GoogleFonts.urbanist(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}