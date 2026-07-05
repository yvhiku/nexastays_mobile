import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../app/di/injection.dart';
import '../../wishlist/presentation/bloc/wishlist_cubit.dart';

class MainShellPage extends StatelessWidget {
  const MainShellPage({
    super.key,
    required this.navigationShell,
  });

  /// The navigation shell and state for the branch to display.
  final StatefulNavigationShell navigationShell;

  void _onTap(BuildContext context, int index) {
    if (index == 2 && getIt.isRegistered<WishlistCubit>()) {
      getIt<WishlistCubit>().loadWishlist();
    }
    if (index == navigationShell.currentIndex) {
      // If the user taps the active tab again, perhaps pop back to the top of the stack
      // This is a common pattern for tab bars.
      // With GoRouter you can pass `initialLocation: index == navigationShell.currentIndex`
      // to pop to the top, but `goBranch` natively handles this as an option.
    }
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => _onTap(context, index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 8,
        selectedItemColor: const Color(0xFFE8507A),
        unselectedItemColor: const Color(0xFF9CA3AF),
        selectedLabelStyle: GoogleFonts.dmSans(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.dmSans(fontSize: 12),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Explore'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: 'Saved'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}
