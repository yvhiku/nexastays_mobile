import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';

class EarningsSummary extends StatefulWidget {
  const EarningsSummary({
    super.key,
    required this.totalEarnings,
    required this.totalBookings,
    required this.averageNightlyRate,
    required this.weeklyBreakdown,
  });

  final double totalEarnings;
  final int totalBookings;
  final double averageNightlyRate;
  final Map<String, double> weeklyBreakdown;

  @override
  State<EarningsSummary> createState() => _EarningsSummaryState();
}

class _EarningsSummaryState extends State<EarningsSummary> {
  // Mocking month selector state
  DateTime _currentMonth = DateTime.now();

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── HEADER ROW ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Earnings breakdown',
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: _previousMonth,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        '<',
                        style: TextStyle(
                          color: Color(0xFFE8507A),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    '${_getMonthName(_currentMonth.month)} ${_currentMonth.year}',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),
                  GestureDetector(
                    onTap: _nextMonth,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        '>',
                        style: TextStyle(
                          color: Color(0xFFE8507A),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── BAR CHART ──
          SizedBox(
            height: 120,
            child: _buildSimpleBarChart(),
          ),
          const SizedBox(height: 24),
          const Divider(color: Color(0xFFE5E7EB), height: 1),
          const SizedBox(height: 16),

          // ── STATS ROW ──
          Row(
            children: [
              Expanded(
                child: _buildStatColumn(
                  '${widget.totalEarnings.toStringAsFixed(0)} MAD',
                  'Total',
                ),
              ),
              Expanded(
                child: _buildStatColumn(
                  '${widget.totalBookings}',
                  'Bookings',
                ),
              ),
              Expanded(
                child: _buildStatColumn(
                  '${widget.averageNightlyRate.toStringAsFixed(0)} MAD',
                  'Avg/night',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleBarChart() {
    if (widget.weeklyBreakdown.isEmpty) {
      return const Center(child: Text('No data for this month.'));
    }

    final maxVal = widget.weeklyBreakdown.values.reduce(max);
    // Determine a round upper bound for Y axis labels
    final yAxisMax = (maxVal > 0 ? (maxVal / 1000).ceil() * 1000 : 1000).toDouble();
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Y Axis Labels
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              yAxisMax >= 1000 ? '${(yAxisMax / 1000).toStringAsFixed(1)}k' : yAxisMax.toStringAsFixed(0),
              style: GoogleFonts.dmSans(fontSize: 10, color: const Color(0xFF9CA3AF)),
            ),
            Text(
              (yAxisMax / 2) >= 1000 ? '${(yAxisMax / 2000).toStringAsFixed(1)}k' : (yAxisMax / 2).toStringAsFixed(0),
              style: GoogleFonts.dmSans(fontSize: 10, color: const Color(0xFF9CA3AF)),
            ),
            Text(
              '0',
              style: GoogleFonts.dmSans(fontSize: 10, color: const Color(0xFF9CA3AF)),
            ),
            // alignment spacer for the bottom x-axis text height
            const SizedBox(height: 16), 
          ],
        ),
        const SizedBox(width: 8),
        
        // Bars
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: widget.weeklyBreakdown.entries.map((entry) {
                  final double percentage = yAxisMax > 0 ? (entry.value / yAxisMax) : 0;
                  // Max height available for the bar is constraints.maxHeight - space for bottom label
                  final double barMaxHeight = constraints.maxHeight - 24;
                  final double barHeight =  max(percentage * barMaxHeight, 4.0); // min 4px height if > 0

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: 30, // Fixed width for simple bars
                        height: entry.value == 0 ? 0 : barHeight,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE8507A),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        entry.key, // "W1", "W2", etc.
                        style: GoogleFonts.dmSans(fontSize: 11, color: const Color(0xFF6B7280)),
                      ),
                    ],
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatColumn(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: GoogleFonts.playfairDisplay(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A2E),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 11,
            color: const Color(0xFF9CA3AF),
          ),
        ),
      ],
    );
  }
}
