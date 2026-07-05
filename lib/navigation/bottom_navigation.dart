import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NexaBottomNavigation extends StatelessWidget {
  const NexaBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTabChanged,
  });

  final int currentIndex;
  final ValueChanged<int> onTabChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Color(0xFFF3F4F6),
            width: 1,
          ),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTabChanged,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 12, // Native BottomNavigationBar elevation
        selectedItemColor: const Color(0xFFE8507A),
        unselectedItemColor: const Color(0xFF9CA3AF),
        showUnselectedLabels: true,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        selectedLabelStyle: GoogleFonts.dmSans(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: const Color(0xFFE8507A),
        ),
        unselectedLabelStyle: GoogleFonts.dmSans(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          color: const Color(0xFF9CA3AF),
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded, size: 22),
            activeIcon: Icon(Icons.home_rounded, size: 24),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_rounded, size: 22),
            activeIcon: Icon(Icons.search_rounded, size: 24),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_rounded, size: 22),
            activeIcon: Icon(Icons.favorite_rounded, size: 24),
            label: 'Saved',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded, size: 22),
            activeIcon: Icon(Icons.person_rounded, size: 24),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
