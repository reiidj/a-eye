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
  final String? userName;
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
  late Future<DocumentSnapshot> _userDataFuture;

  @override
  void initState() {
    super.initState();
    if (_currentUser != null) {
      _userDataFuture = _firestoreService.getUser(_currentUser!.uid);
    } else {
      _userDataFuture = Future.value(null);
    }
  }

  Future<void> _refreshHistory() async {
    if (_currentUser != null) {
      setState(() {
        _userDataFuture = _firestoreService.getUser(_currentUser!.uid);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

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
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(screenWidth),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refreshHistory,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.08,
                      vertical: screenHeight * 0.001,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildGreeting(screenWidth),
                        SizedBox(height: screenHeight * 0.015),
                        _buildScanHistorySection(screenHeight),
                        SizedBox(height: screenHeight * 0.04),
                        _buildStartScanButton(screenWidth),
                        SizedBox(height: screenHeight * 0.02),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(double screenWidth) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        screenWidth * 0.05,
        10,
        screenWidth * 0.05,
        10,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: widget.onProfile,
            child: Image.asset(
              'assets/images/Profile btn.png',
              width: screenWidth * 0.12,
              height: screenWidth * 0.12,
            ),
          ),
          GestureDetector(
            onTap: widget.onGuide,
            child: Image.asset(
              'assets/images/Help button.png',
              width: screenWidth * 0.15,
              height: screenWidth * 0.25,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGreeting(double screenWidth) {
    return FutureBuilder<DocumentSnapshot>(
      future: _userDataFuture,
      builder: (context, userSnapshot) {
        String displayName = widget.userName ?? 'Guest';
        if (userSnapshot.connectionState == ConnectionState.done &&
            userSnapshot.hasData &&
            userSnapshot.data!.exists) {
          final userData = userSnapshot.data!.data() as Map<String, dynamic>;
          displayName = userData['name'] ?? 'Guest';
        }
        return Text.rich(
          TextSpan(
            style: GoogleFonts.urbanist(
              fontSize: screenWidth * 0.1,
              color: Colors.white,
            ),
            children: [
              const TextSpan(text: "Welcome Back, "),
              TextSpan(
                text: displayName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(text: "!"),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStartScanButton(double screenWidth) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: widget.onNext,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF5244F3),
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.07,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/eye_scan_sprite.png',
              height: screenWidth * 0.1,
              width: screenWidth * 0.1,
              fit: BoxFit.contain,
            ),
            SizedBox(width: screenWidth * 0.03),
            Flexible(
              child: Text(
                "Start Eye Scan",
                style: GoogleFonts.urbanist(
                  fontSize: screenWidth * 0.06,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanHistorySection(double screenHeight) {
    if (_currentUser == null) {
      return _buildNoHistoryWidgets(screenHeight);
    }
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
            Container(
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasHistory ? "Thanks for choosing A-Eye!" : "Welcome to A-Eye!",
                    style: GoogleFonts.urbanist(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12)),
                    child: Text(
                      hasHistory
                          ? "Ready for your next scan? Tap below to get started."
                          : "Let's begin your journey with your very first eye scan!",
                      style: GoogleFonts.urbanist(fontSize: 17, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (hasHistory)
              _buildHistoryList(snapshot.data!.docs, screenHeight)
            else
              _buildNoHistoryWidgets(screenHeight),
          ],
        );
      },
    );
  }

  Widget _buildHistoryList(List<QueryDocumentSnapshot> scans, double screenHeight) {
    final mostRecentScan = scans.first;
    final olderScans = scans.skip(1).toList();

    final recentScanData = mostRecentScan.data() as Map<String, dynamic>;
    final recentTimestamp = (recentScanData['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();

    // FIXED: Helper function to safely format classificationScore
    String _formatClassificationScore(dynamic score) {
      if (score == null) return 'N/A';
      if (score is String) return score;
      if (score is num) return '${(score * 100).toStringAsFixed(2)}%';
      return score.toString();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Most Recent Scan",
          style: GoogleFonts.urbanist(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: const Color(0XFF5244F3)),
        ),
        const SizedBox(height: 16),
        ResultCard(
          date: DateFormat('MMMM d, y, h:mm a').format(recentTimestamp),
          title: recentScanData['result'] ?? 'No Result',
          imageFilePath: recentScanData['imagePath'] as String? ?? '',
          userName: widget.userName,
          confidence: recentScanData['confidence'] as String? ?? 'N/A',
          classificationScore: _formatClassificationScore(recentScanData['classificationScore']), // FIXED: Added
          explanationText: recentScanData['explanation'] as String? ?? 'Explanation not available.',
        ),

        if (olderScans.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text(
            "Older History",
            style: GoogleFonts.urbanist(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.white),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
                color: const Color(0xFF131A21),
                borderRadius: BorderRadius.circular(24)
            ),
            height: screenHeight * 0.35,
            child: ListView.builder(
              itemCount: olderScans.length,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemBuilder: (context, index) {
                final scanData = olderScans[index].data() as Map<String, dynamic>;
                final timestamp = (scanData['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
                return ResultCard(
                  date: DateFormat('MMMM d, y, h:mm a').format(timestamp),
                  title: scanData['result'] ?? 'No Result',
                  imageFilePath: scanData['imagePath'] as String? ?? '',
                  userName: widget.userName,
                  confidence: scanData['confidence'] as String? ?? 'N/A',
                  classificationScore: _formatClassificationScore(scanData['classificationScore']), // FIXED: Added
                  explanationText: scanData['explanation'] as String? ?? 'Explanation not available.',
                );
              },
            ),
          ),
        ]
      ],
    );
  }

  Widget _buildNoHistoryWidgets(double screenHeight) {
    return Center(
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: Image.asset(
              'assets/images/Welcome Card.png',
              fit: BoxFit.contain,
              height: screenHeight * 0.45,
            ),
          ),
        ],
      ),
    );
  }
}