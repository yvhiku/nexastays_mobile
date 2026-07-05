import 'package:flutter/material.dart';

class CountrySearchSheet extends StatefulWidget {
  final Function(String country) onCountrySelected;
  final String? selectedCountry;

  const CountrySearchSheet({
    super.key,
    required this.onCountrySelected,
    this.selectedCountry,
  });

  static Future<String?> show(BuildContext context, {String? selected}) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CountrySearchSheet(
        onCountrySelected: (c) => Navigator.pop(context, c),
        selectedCountry: selected,
      ),
    );
  }

  @override
  State<CountrySearchSheet> createState() => _CountrySearchSheetState();
}

class _CountrySearchSheetState extends State<CountrySearchSheet> {
  static const List<String> _countries = [
    '🇩🇿 Algeria', '🇧🇭 Bahrain', '🇧🇪 Belgium',
    '🇨🇦 Canada', '🇨🇳 China', '🇪🇬 Egypt',
    '🇫🇷 France', '🇩🇪 Germany', '🇮🇳 India',
    '🇮🇷 Iran', '🇮🇶 Iraq', '🇮🇹 Italy',
    '🇯🇴 Jordan', '🇰🇼 Kuwait', '🇱🇧 Lebanon',
    '🇱🇾 Libya', '🇲🇾 Malaysia', '🇲🇦 Morocco',
    '🇳🇱 Netherlands', '🇴🇲 Oman', '🇵🇰 Pakistan',
    '🇵🇸 Palestine', '🇵🇹 Portugal', '🇶🇦 Qatar',
    '🇸🇦 Saudi Arabia', '🇸🇳 Senegal', '🇸🇴 Somalia',
    '🇪🇸 Spain', '🇸🇩 Sudan', '🇸🇾 Syria',
    '🇹🇳 Tunisia', '🇹🇷 Turkey', '🇦🇪 UAE',
    '🇬🇧 United Kingdom', '🇺🇸 United States',
    '🇾🇪 Yemen',
  ];

  String _searchQuery = '';

  List<String> get _filtered => _countries
      .where((c) => c.toLowerCase().contains(_searchQuery.toLowerCase()))
      .toList();

  Widget _buildCountryItem(String country, int index) {
    final bool isSelected = country == widget.selectedCountry;
    return GestureDetector(
      onTap: () => widget.onCountrySelected(country),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFDF0F3) : Colors.white,
          border: index != 0
              ? const Border(
                  top: BorderSide(color: Color(0xFFF8F2F5), width: 1),
                )
              : null,
        ),
        child: Row(
          children: [
            Text(
              country,
              style: TextStyle(
                fontSize: 10,
                color: isSelected
                    ? const Color(0xFFE8507A)
                    : const Color(0xFF1A1118),
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final filtered = _filtered;

    return Container(
      height: screenHeight * 0.70,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFEDE0E5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Search row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFEDE0E5), width: 1),
              ),
            ),
            child: Row(
              children: [
                const Text(
                  '🔍',
                  style: TextStyle(fontSize: 14, color: Color(0xFF9E8A93)),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: TextField(
                    onChanged: (value) =>
                        setState(() => _searchQuery = value),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF6B5460),
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Search Country...',
                      hintStyle: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF9E8A93),
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Country list
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) =>
                  _buildCountryItem(filtered[index], index),
            ),
          ),
        ],
      ),
    );
  }
}
