import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'track_screen.dart';
import 'journal_screen.dart';
import 'scan_screen.dart';
import 'settings_screen.dart';
import 'coming_soon_screen.dart';
import '../widgets/trip_summary_widget.dart';
import 'manual_trip_screen.dart';
import '../services/trip_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final TripService _tripService = TripService();

  @override
  void initState() {
    super.initState();
    _tripService.start();
  }

  @override
  void dispose() {
    _tripService.dispose();
    super.dispose();
  }

  void _onNavigate(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return HomePage(onNavigate: _onNavigate);
      case 1:
        return const TrackScreen();
      case 2:
        return const ScanScreen();
      case 3:
        return const JournalScreen();
      case 4:
        return const SettingsScreen();
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onNavigate,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF20B2AA),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.track_changes_outlined),
            activeIcon: Icon(Icons.track_changes),
            label: 'Track',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner_outlined),
            activeIcon: Icon(Icons.qr_code_scanner),
            label: 'Scan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_outlined),
            activeIcon: Icon(Icons.book),
            label: 'Journal',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final void Function(int) onNavigate;
  const HomePage({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF20B2AA), // Turquoise
            Color(0xFF40E0D0), // Light Turquoise
          ],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              const _Header(),
              // Trip Summary
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: TripSummaryWidget(),
              ),
              const SizedBox(height: 30),
              // Main Content Card
              _MainContentCard(onNavigate: onNavigate),
              const SizedBox(height: 100), // Space for bottom navigation
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              color: Colors.orange,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'യയ്യേതത്',
                style: GoogleFonts.notoSans(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                'Yatrica',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MainContentCard extends StatelessWidget {
  final void Function(int) onNavigate;
  const _MainContentCard({required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.explore, color: Colors.black87, size: 24),
              const SizedBox(width: 8),
              Text(
                'Your Travel Companion',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Yatrica is your all-in-one travel companion. Track your trips, get real-time updates, and stay safe with our SOS feature.',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 30),
          // Grid of Cards
          _StatusCardGrid(onNavigate: onNavigate),
        ],
      ),
    );
  }
}

class _StatusCardGrid extends StatelessWidget {
  final void Function(int) onNavigate;
  const _StatusCardGrid({required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1,
      children: [
        const _StatusCard(
          icon: Icons.sos,
          title: 'SOS',
          color: Color(0xFF20B2AA),
        ),
        const _StatusCard(
          icon: Icons.explore,
          title: 'Travel Itinerary',
          color: Color(0xFF20B2AA),
        ),
        _StatusCard(
          icon: Icons.track_changes,
          title: 'Trip Tracking',
          color: const Color(0xFF20B2AA),
          onTap: () => onNavigate(1),
        ),
        _StatusCard(
          icon: Icons.auto_awesome,
          title: 'AI Journal',
          color: const Color(0xFF20B2AA),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ComingSoonScreen()),
            );
          },
        ),
        _StatusCard(
          icon: Icons.add_road,
          title: 'Add Manual Trip',
          color: const Color(0xFF20B2AA),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ManualTripScreen()),
            );
          },
        ),
      ],
    );
  }
}

class _StatusCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback? onTap;

  const _StatusCard({
    required this.icon,
    required this.title,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 40,
            ),
            const SizedBox(height: 12),
            FittedBox(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
