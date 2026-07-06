import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../../core/utils/booking_lifecycle.dart';

class BookingFiltersSheet extends StatefulWidget {
  const BookingFiltersSheet({
    super.key,
    required this.initial,
    required this.cities,
    required this.onApply,
    required this.onClear,
  });

  final BookingFilters initial;
  final List<String> cities;
  final ValueChanged<BookingFilters> onApply;
  final VoidCallback onClear;

  static Future<void> show(
    BuildContext context, {
    required BookingFilters initial,
    required List<String> cities,
    required ValueChanged<BookingFilters> onApply,
    required VoidCallback onClear,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.82,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return BookingFiltersSheet(
            initial: initial,
            cities: cities,
            onApply: onApply,
            onClear: onClear,
          );
        },
      ),
    );
  }

  @override
  State<BookingFiltersSheet> createState() => _BookingFiltersSheetState();
}

class _BookingFiltersSheetState extends State<BookingFiltersSheet> {
  late BookingFilters _draft;
  final _priceMinController = TextEditingController();
  final _priceMaxController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _draft = widget.initial;
    if (_draft.priceMin != null) {
      _priceMinController.text = _draft.priceMin!.toInt().toString();
    }
    if (_draft.priceMax != null) {
      _priceMaxController.text = _draft.priceMax!.toInt().toString();
    }
  }

  @override
  void dispose() {
    _priceMinController.dispose();
    _priceMaxController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: (isFrom ? _draft.dateFrom : _draft.dateTo) ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked == null) return;
    setState(() {
      _draft = isFrom
          ? _draft.copyWith(dateFrom: picked)
          : _draft.copyWith(dateTo: picked);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                Text(
                  'Filter & Sort',
                  style: GoogleFonts.dmSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Color(0xFF6B7280)),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              children: [
                _sectionTitle('Filter by date'),
                Row(
                  children: [
                    Expanded(
                      child: _dateChip(
                        label: _draft.dateFrom != null
                            ? DateFormat.yMMMd().format(_draft.dateFrom!)
                            : 'Check-in',
                        onTap: () => _pickDate(isFrom: true),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _dateChip(
                        label: _draft.dateTo != null
                            ? DateFormat.yMMMd().format(_draft.dateTo!)
                            : 'Check-out',
                        onTap: () => _pickDate(isFrom: false),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _sectionTitle('Status'),
                _dropdown<BookingLifecycle?>(
                  value: _draft.status,
                  hint: 'All statuses',
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All statuses')),
                    ...BookingLifecycle.values.map(
                      (s) => DropdownMenuItem(
                        value: s,
                        child: Text(lifecycleLabel(s)),
                      ),
                    ),
                  ],
                  onChanged: (v) => setState(() => _draft = _draft.copyWith(
                        status: v,
                        clearStatus: v == null,
                      )),
                ),
                const SizedBox(height: 20),
                _sectionTitle('City'),
                _dropdown<String?>(
                  value: _draft.city,
                  hint: 'All cities',
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All cities')),
                    ...widget.cities.map(
                      (c) => DropdownMenuItem(value: c, child: Text(c)),
                    ),
                  ],
                  onChanged: (v) => setState(() => _draft = _draft.copyWith(
                        city: v,
                        clearCity: v == null,
                      )),
                ),
                const SizedBox(height: 20),
                _sectionTitle('Price range (MAD)'),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _priceMinController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration('Min'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _priceMaxController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration('Max'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _sectionTitle('Sort by'),
                _dropdown<BookingSort>(
                  value: _draft.sort,
                  hint: 'Most recent',
                  items: const [
                    DropdownMenuItem(
                      value: BookingSort.newest,
                      child: Text('Most recent'),
                    ),
                    DropdownMenuItem(
                      value: BookingSort.oldest,
                      child: Text('Oldest'),
                    ),
                    DropdownMenuItem(
                      value: BookingSort.checkin,
                      child: Text('Check-in date'),
                    ),
                    DropdownMenuItem(
                      value: BookingSort.price,
                      child: Text('Price'),
                    ),
                    DropdownMenuItem(
                      value: BookingSort.guests,
                      child: Text('Guest count'),
                    ),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => _draft = _draft.copyWith(sort: v));
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              8,
              20,
              20 + MediaQuery.of(context).padding.bottom,
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      widget.onClear();
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Color(0xFFE5E7EB)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    child: Text(
                      'Clear',
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFE8507A),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final min = double.tryParse(_priceMinController.text.trim());
                      final max = double.tryParse(_priceMaxController.text.trim());
                      widget.onApply(_draft.copyWith(
                        priceMin: min,
                        priceMax: max,
                        clearPriceMin: min == null,
                        clearPriceMax: max == null,
                      ));
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE8507A),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Apply filters',
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.dmSans(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF6B7280),
        ),
      ),
    );
  }

  Widget _dateChip({required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: GoogleFonts.dmSans(fontSize: 13, color: const Color(0xFF374151)),
        ),
      ),
    );
  }

  Widget _dropdown<T>({
    required T? value,
    required String hint,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          hint: Text(hint),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
    );
  }
}
