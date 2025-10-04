import 'package:a_eye/services/firestore_service.dart';
import 'package:a_eye/widgets/result_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class WelcomeScreen extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onProfile;
  final String? userName; // This is now optional
  final VoidCallback onGuide;

  const WelcomeScreen({
    super.key,
    required this.onNext,
    required this.onProfile,
    this.userName,
    required this.onGuide,
  });

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  // Future to get the user's profile data
  late Future<DocumentSnapshot> _userDataFuture;

  @override
  void initState() {
    super.initState();
    // Initialize the future in initState
    if (_currentUser != null) {
      _userDataFuture = _firestoreService.getUser(_currentUser!.uid);
    } else {
      // Create a completed future with null if no user is logged in
      _userDataFuture = Future.value(null);
    }
  }

  // A function to handle pull-to-refresh
  Future<void> _refreshHistory() async {
    setState(() {
      // Re-fetch user data and trigger a rebuild
      if (_currentUser != null) {
        _userDataFuture = _firestoreService.getUser(_currentUser!.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
            // Top icons
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
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- Greeting Section (uses FutureBuilder for name) ---
                      FutureBuilder<DocumentSnapshot>(
                        future: _userDataFuture,
                        builder: (context, userSnapshot) {
                          String displayName = widget.userName ?? 'Guest';
                          bool hasHistory = false; // Default to no history

                          if (userSnapshot.connectionState == ConnectionState.done && userSnapshot.hasData && userSnapshot.data!.exists) {
                            final userData = userSnapshot.data!.data() as Map<String, dynamic>;
                            displayName = userData['name'] ?? 'Guest';
                          }

                          // We determine 'hasHistory' from the scan history StreamBuilder below,
                          // but for the greeting, we can just display the name.
                          return Text.rich(
                            TextSpan(
                              style: GoogleFonts.urbanist(fontSize: 40, color: Colors.white),
                              children: [
                                TextSpan(text: "Welcome Back, "),
                                TextSpan(
                                  text: displayName,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const TextSpan(text: "!"),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),

                      // --- Scan History Section (uses StreamBuilder) ---
                      _buildScanHistorySection(),
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
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanHistorySection() {
    // If there's no user, show the "no history" welcome card.
    if (_currentUser == null) {
      return _buildNoHistoryWidgets();
    }
    // Otherwise, use a StreamBuilder to listen for scan history.
    return StreamBuilder<QuerySnapshot>(
      stream: _firestoreService.getScansForUser(_currentUser!.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
        }

        final bool hasHistory = snapshot.hasData && snapshot.data!.docs.isNotEmpty;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Message Box
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

            // Conditional UI: History List or Welcome Card
            if (hasHistory)
              _buildHistoryList(snapshot.data!.docs)
            else
              _buildNoHistoryWidgets(),
          ],
        );
      },
    );
  }

  Widget _buildHistoryList(List<QueryDocumentSnapshot> scans) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            itemCount: scans.length,
            padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
            itemBuilder: (context, index) {
              final scanData = scans[index].data() as Map<String, dynamic>;
              final timestamp = (scanData['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
              final result = scanData['result'] ?? 'No Result';

              // DEBUG: Print the exact result value
              print('DEBUG - Scan $index result: "$result"');
              print('DEBUG - Result type: ${result.runtimeType}');
              print('DEBUG - Contains "mature": ${result.toString().toLowerCase().contains('mature')}');
              print('DEBUG - Contains "immature": ${result.toString().toLowerCase().contains('immature')}');

              return ResultCard(
                date: DateFormat('MMMM d, y, h:mm a').format(timestamp),
                title: result,
                imageFilePath: scanData['imagePath'] as String? ?? '',
                showLabel: index == 0,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNoHistoryWidgets() {
    return Center(
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
    );
  }
}