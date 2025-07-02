import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:a_eye/database/app_database.dart';
import 'package:a_eye/widgets/result_card.dart';

class WelcomeScreenWithResult extends StatefulWidget {
  final VoidCallback onNext;
  final String userName;
  final AppDatabase database;

  const WelcomeScreenWithResult({
    super.key,
    required this.onNext,
    required this.userName,
    required this.database,
  });

  @override
  State<WelcomeScreenWithResult> createState() => _WelcomeScreenWithResultState();
}

class _WelcomeScreenWithResultState extends State<WelcomeScreenWithResult> {
  late Future<User?> _userFuture;
  late Future<List<ScanResult>> _resultsFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = widget.database.getAllUsers().then((users) => users.isNotEmpty ? users.first : null);
    _resultsFuture = widget.database.getAllScanResults();
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
            // Header
            _buildTopIcons(),

            // Main content
            Align(
              alignment: const Alignment(0.0, 0.5),
              child: FutureBuilder(
                future: Future.wait([_userFuture, _resultsFuture]),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator(color: Colors.white));
                  }

                  final user = snapshot.data![0] as User?;
                  final results = snapshot.data![1] as List<ScanResult>;
                  final displayName = user?.name.isNotEmpty == true ? user!.name : widget.userName;

                  return _buildMainContent(displayName, results);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopIcons() {
    return SafeArea(
      child: Stack(
        children: [
          Positioned(
            top: 20,
            left: 30,
            child: Image.asset(
              'assets/images/Profile btn.png',
              width: 48,
              height: 48,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.menu, color: Colors.white, size: 28),
            ),
          ),
          Positioned(
            top: -30,
            right: 0,
            child: SizedBox(
              width: 160,
              height: 160,
              child: Image.asset(
                'assets/images/A-Eye Icon.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.info_outline, color: Colors.white, size: 28),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(String displayName, List<ScanResult> results) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              style: GoogleFonts.urbanist(fontSize: 40, color: Colors.white),
              children: [
                const TextSpan(text: "Welcome Back, "),
                TextSpan(text: displayName, style: const TextStyle(fontWeight: FontWeight.bold)),
                const TextSpan(text: "!"),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildIntroBox(),
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
          _buildResultList(results),
          const SizedBox(height: 32),
          _buildStartScanButton(),
        ],
      ),
    );
  }

  Widget _buildIntroBox() {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 16),
      decoration: BoxDecoration(
        color: Colors.white12.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Thank you for choosing A-Eye!",
            style: GoogleFonts.urbanist(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              "Ready for your next scan? Tap below to get started.",
              style: GoogleFonts.urbanist(
                fontSize: 17,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultList(List<ScanResult> results) {
    return Container(
      height: 300,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: const Color(0xFF131A21),
        borderRadius: BorderRadius.circular(24),
      ),
      child: ListView.builder(
        itemCount: results.length,
        itemBuilder: (context, index) {
          final result = results[index];
          return ResultCard(
            date: _formatDate(result.timestamp),
            title: result.result, // Drift field
            imageFilePath: result.imagePath,
            showLabel: index == 0,
          );
        },
      ),
    );
  }
  //helper function
  String _formatDate(DateTime timestamp) {
    return "${timestamp.month}/${timestamp.day}/${timestamp.year}";
  }

  Widget _buildStartScanButton() {
    return SizedBox(
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
            Image.asset(
              'assets/images/eye_scan_sprite.png',
              height: 40,
              width: 40,
              fit: BoxFit.contain,
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
    );
  }
}
