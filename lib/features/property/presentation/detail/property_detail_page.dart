import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'bloc/property_detail_cubit.dart';
import 'bloc/property_detail_state.dart';
import 'listing/listing_colors.dart';
import 'widgets/listing_amenities_section.dart';
import 'widgets/listing_booking_bar.dart';
import 'widgets/listing_glass_app_bar.dart';
import 'widgets/listing_host_section.dart';
import 'widgets/listing_image_carousel.dart';
import 'widgets/listing_location_section.dart';
import 'widgets/listing_similar_stays.dart';
import 'widgets/listing_trust_card.dart';
import 'widgets/reviews_list.dart';

class PropertyDetailPage extends StatefulWidget {
  const PropertyDetailPage({super.key, required this.propertyId});

  final String propertyId;

  @override
  State<PropertyDetailPage> createState() => _PropertyDetailPageState();
}

class _PropertyDetailPageState extends State<PropertyDetailPage> {
  late PropertyDetailCubit _cubit;
  bool _isDescriptionExpanded = false;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<PropertyDetailCubit>();
    _cubit.loadProperty(widget.propertyId);
  }

  Future<void> _pickDates(BuildContext context, PropertyDetailLoaded state) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final initialRange = state.selectedCheckIn != null && state.selectedCheckOut != null
        ? DateTimeRange(start: state.selectedCheckIn!, end: state.selectedCheckOut!)
        : null;

    final picked = await showDateRangePicker(
      context: context,
      firstDate: today,
      lastDate: today.add(const Duration(days: 365)),
      initialDateRange: initialRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: ListingColors.primary,
              onPrimary: ListingColors.onPrimary,
              surface: ListingColors.surfaceBright,
              onSurface: ListingColors.onSurface,
              primaryContainer: ListingColors.primaryContainer,
              onPrimaryContainer: ListingColors.onPrimaryContainer,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      _cubit.selectDates(picked.start, picked.end);
    }
  }

  String _specsLine(PropertyDetailLoaded state) {
    final property = state.property;
    final bedroomLabel =
        property.beds == 1 ? '1 Bedroom' : '${property.beds} Bedrooms';
    final bathroomLabel = property.bathrooms == 1
        ? '1 Bathroom'
        : '${property.bathrooms} Bathrooms';
    return '${property.propertyType} • ${property.maxGuests} Guests • $bedroomLabel • $bathroomLabel';
  }

  bool _isGuestFavorite(PropertyDetailLoaded state) {
    return state.property.isTrending || state.property.rating >= 4.9;
  }

  List<_HighlightItem> _aboutHighlights(PropertyDetailLoaded state) {
    final amenities = state.property.amenities.map((a) => a.toLowerCase()).toList();
    final highlights = <_HighlightItem>[];

    if (amenities.any((a) => a.contains('wifi') || a.contains('wi-fi'))) {
      highlights.add(const _HighlightItem(
        icon: Icons.wifi,
        title: 'High-speed WiFi',
        subtitle: 'Perfect for remote work with fast connectivity.',
      ));
    }
    if (amenities.any((a) =>
        a.contains('workspace') || a.contains('desk') || a.contains('office'))) {
      highlights.add(const _HighlightItem(
        icon: Icons.laptop_mac_outlined,
        title: 'Dedicated Workspace',
        subtitle: 'Comfortable desk and ergonomic chair.',
      ));
    }

    return highlights.take(2).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ListingColors.background,
      body: BlocConsumer<PropertyDetailCubit, PropertyDetailState>(
        listener: (context, state) {
          if (state is PropertyDetailError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is PropertyDetailLoading || state is PropertyDetailInitial) {
            return const _ListingLoadingView();
          }

          if (state is PropertyDetailError) {
            return _ListingErrorView(message: state.message);
          }

          if (state is PropertyDetailLoaded) {
            return _buildLoaded(context, state);
          }

          return const SizedBox.shrink();
        },
      ),
      bottomNavigationBar: BlocBuilder<PropertyDetailCubit, PropertyDetailState>(
        builder: (context, state) {
          if (state is PropertyDetailLoaded) {
            return ListingBookingBar(
              state: state,
              onSelectDates: () => _pickDates(context, state),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildLoaded(BuildContext context, PropertyDetailLoaded state) {
    final property = state.property;
    final reviewCount = state.reviewsApiTotal ?? property.reviewCount;
    final rating = state.reviewsSummaryAvgRating ?? property.rating;
    final hostName = property.checkInContact.isNotEmpty
        ? property.checkInContact.split(' ').first
        : 'Your Host';

    return Column(
      children: [
        ListingGlassAppBar(onBack: () => context.pop()),
        Expanded(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: ListingImageCarousel(
                  photoUrls: property.photoUrls,
                  isVerified: property.isVerified,
                  isGuestFavorite: _isGuestFavorite(state),
                  isSaved: state.isSaved,
                  onFavoriteTap: _cubit.toggleSave,
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.only(bottom: 24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                  _sectionPadding(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            property.name,
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 32,
                              fontWeight: FontWeight.w600,
                              height: 1.25,
                              color: ListingColors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                size: 18,
                                color: ListingColors.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                rating.toStringAsFixed(2),
                                style: GoogleFonts.dmSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: ListingColors.onSurface,
                                ),
                              ),
                              _dot(),
                              GestureDetector(
                                onTap: () {},
                                child: Text(
                                  '$reviewCount reviews',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: ListingColors.onSurfaceVariant,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                              _dot(),
                              Expanded(
                                child: Text(
                                  property.exactAddress.isNotEmpty
                                      ? property.shortLocationLabel
                                      : property.displayAddress,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.dmSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: ListingColors.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _specsLine(state),
                            style: GoogleFonts.dmSans(
                              fontSize: 16,
                              color: ListingColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  _divider(),
                  _sectionPadding(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'About this sanctuary',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: ListingColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          property.description,
                          maxLines: _isDescriptionExpanded ? null : 3,
                          overflow: _isDescriptionExpanded
                              ? TextOverflow.visible
                              : TextOverflow.ellipsis,
                          style: GoogleFonts.dmSans(
                            fontSize: 16,
                            height: 1.5,
                            color: ListingColors.onSurfaceVariant,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(
                            () => _isDescriptionExpanded = !_isDescriptionExpanded,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              _isDescriptionExpanded ? 'Show less' : 'Show more',
                              style: GoogleFonts.dmSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: ListingColors.primary,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                        if (_aboutHighlights(state).isNotEmpty) ...[
                          const SizedBox(height: 16),
                          ..._aboutHighlights(state).map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    item.icon,
                                    color: ListingColors.primary,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.title,
                                          style: GoogleFonts.dmSans(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: ListingColors.onSurface,
                                          ),
                                        ),
                                        Text(
                                          item.subtitle,
                                          style: GoogleFonts.dmSans(
                                            fontSize: 14,
                                            color: ListingColors.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: ListingColors.stackMd),
                  _sectionPadding(child: const ListingTrustCard()),
                  const SizedBox(height: ListingColors.stackMd),
                  _sectionPadding(
                    child: ListingAmenitiesSection(amenities: property.amenities),
                  ),
                  const SizedBox(height: ListingColors.stackLg),
                  _sectionPadding(
                    child: ListingLocationSection(property: property),
                  ),
                  const SizedBox(height: ListingColors.stackLg),
                  _sectionPadding(
                    child: ListingHostSection(
                      hostName: hostName,
                      isVerifiedHost: property.isVerified,
                      isSuperhost: property.hostType.toLowerCase() != 'standard',
                      hostQuote: property.checkInInstructions.isNotEmpty
                          ? property.checkInInstructions
                          : 'I love sharing the hidden gems of ${property.city} with my guests. My goal is to make your stay as comfortable and authentic as possible.',
                      onContactHost: () {},
                    ),
                  ),
                  const SizedBox(height: ListingColors.stackLg),
                  ListingSimilarStays(properties: state.similarProperties),
                  const SizedBox(height: 120),
                  if (state.reviews.isNotEmpty) ...[
                    _sectionPadding(
                      child: ReviewsList(
                        reviews: state.reviews,
                        overallRating: rating,
                        totalCount: reviewCount,
                        distributionPct: state.reviewsDistributionPct,
                        hasMore: state.hasMoreReviews,
                        isLoading: state.isLoadingReviews,
                        onLoadMore: _cubit.loadMoreReviews,
                      ),
                    ),
                    const SizedBox(height: 120),
                  ],
                ]),
              ),
            ),
          ],
        ),
        ),
      ],
    );
  }

  Widget _sectionPadding({required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: ListingColors.marginMobile),
      child: child,
    );
  }

  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: ListingColors.marginMobile,
        vertical: 24,
      ),
      child: Divider(
        height: 1,
        color: ListingColors.outlineVariant.withValues(alpha: 0.3),
      ),
    );
  }

  Widget _dot() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        '·',
        style: GoogleFonts.dmSans(color: ListingColors.outline),
      ),
    );
  }
}

class _HighlightItem {
  const _HighlightItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;
}

class _ListingLoadingView extends StatelessWidget {
  const _ListingLoadingView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: ListingColors.background,
      body: Center(
        child: CircularProgressIndicator(color: ListingColors.primary),
      ),
    );
  }
}

class _ListingErrorView extends StatelessWidget {
  const _ListingErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ListingColors.background,
      appBar: AppBar(
        backgroundColor: ListingColors.surfaceBright,
        foregroundColor: ListingColors.primary,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(color: ListingColors.onSurfaceVariant),
          ),
        ),
      ),
    );
  }
}
