import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'bloc/host_onboarding_bloc.dart';
import 'bloc/host_onboarding_event.dart';
import 'bloc/host_onboarding_state.dart';
import 'steps/booking_model_step.dart';
import 'steps/account_step.dart';
import 'steps/amenities_step.dart';
import 'steps/checkin_step.dart';
import 'steps/contact_step.dart';
import 'steps/listing_details_step.dart';
import 'steps/location_step.dart';
import 'steps/photos_step.dart';
import 'steps/pricing_step.dart';
import 'steps/property_type_step.dart';
import 'steps/review_submit_step.dart';
import 'steps/unit_types_step.dart';
import 'steps/walkthrough_video_step.dart';

/// 10-step host onboarding shell. [HostOnboardingBloc] is provided by GoRouter; do not nest another provider.
class HostRegisterPage extends StatelessWidget {
  const HostRegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _HostRegisterView();
  }
}

class _HostRegisterView extends StatelessWidget {
  const _HostRegisterView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A0A0F),
      body: BlocListener<HostOnboardingBloc, HostOnboardingState>(
        listenWhen: (previous, current) =>
            previous.isSubmitted != current.isSubmitted ||
            previous.errorMessage != current.errorMessage,
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.errorMessage!,
                  style: GoogleFonts.dmSans(color: Colors.white),
                ),
                backgroundColor: const Color(0xFFE8507A),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          if (state.isSubmitted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.isListingFlow
                      ? 'Listing submitted for review.'
                      : 'Host application submitted. We\'ll notify you when approved.',
                  style: GoogleFonts.dmSans(color: Colors.white),
                ),
                backgroundColor: const Color(0xFF1A1A2E),
                behavior: SnackBarBehavior.floating,
              ),
            );
            context.go('/profile');
          }
        },
        child: SafeArea(
          child: Row(
            children: [
              // ── LEFT SIDEBAR ───────────────────────────────────────────
              _buildSidebar(),

              // ── RIGHT CONTENT ──────────────────────────────────────────
              Expanded(
                child: Theme(
                  data: Theme.of(context).copyWith(
                    inputDecorationTheme: InputDecorationTheme(
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: Color(0xFFE8507A), width: 1.5),
                      ),
                    ),
                    switchTheme: SwitchThemeData(
                      thumbColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) {
                          return const Color(0xFFE8507A);
                        }
                        return Colors.grey;
                      }),
                      trackColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) {
                          return const Color(0xFFE8507A).withValues(alpha: 0.3);
                        }
                        return const Color(0xFFE5E7EB);
                      }),
                    ),
                  ),
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(0, 12, 12, 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        Expanded(
                          child: BlocBuilder<HostOnboardingBloc,
                              HostOnboardingState>(
                            builder: (context, state) {
                              return Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'STEP ${state.displayStepIndex} OF ${state.totalSteps}',
                                      style: GoogleFonts.dmSans(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFFE8507A),
                                        letterSpacing: 1,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      state.isListingFlow
                                          ? 'List Property (${state.totalSteps} steps)'
                                          : 'Become a Host (${state.totalSteps} steps)',
                                      style: GoogleFonts.dmSans(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF6B7280),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Expanded(
                                      // Render current step widget
                                      child: _buildCurrentStepWidget(
                                          state.currentStep),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),

                        // ── BOTTOM NAVIGATION ────────────────────────────────
                        _buildBottomNavigation(),
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

  Widget _buildSidebar() {
    return Container(
      width: 72,
      color: const Color(0xFF1A0A0F), // Dark bg with rose tint
      child: BlocBuilder<HostOnboardingBloc, HostOnboardingState>(
        buildWhen: (previous, current) =>
            previous.currentStep != current.currentStep ||
            previous.propertyType != current.propertyType ||
            previous.bookingModel != current.bookingModel ||
            previous.flow != current.flow,
        builder: (context, state) {
          final visibleSteps = state.visibleSteps;
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 24),
            itemCount: visibleSteps.length,
            itemBuilder: (context, index) {
              final stepId = visibleSteps[index];
              final displayNumber = index + 1;
              final currentIdx = visibleSteps.indexOf(state.currentStep);
              final isDone = index < currentIdx;
              final isActive = index == currentIdx;
              final isLast = index == visibleSteps.length - 1;

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Circular Bubble
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDone
                          ? const Color(0xFFE8507A)
                          : isActive
                              ? Colors.transparent
                              : const Color(0xFF3D1520),
                      border: isActive
                          ? Border.all(color: const Color(0xFFE8507A), width: 2)
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: isDone
                        ? const Icon(Icons.check, color: Colors.white, size: 14)
                        : Text(
                            '$displayNumber',
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isActive
                                  ? const Color(0xFFE8507A)
                                  : const Color(0xFF9CA3AF),
                            ),
                          ),
                  ),
                  const SizedBox(height: 4),

                  // Tiny Label
                  Text(
                    state.stepLabel(stepId),
                    style: GoogleFonts.dmSans(
                      fontSize: 7,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                      color: isActive
                          ? const Color(0xFFE8507A)
                          : const Color(0xFF6B7280),
                    ),
                  ),

                  // Connecting Vertical Line
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 24,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      color: isDone || isActive
                          ? const Color(0xFFE8507A)
                          : const Color(0xFF3D1520),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return BlocBuilder<HostOnboardingBloc, HostOnboardingState>(
      builder: (context, state) {
        final isFirst = state.currentStep == state.firstVisibleStep;
        final isLast = state.isLastStep;

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Row(
            children: [
              if (!isFirst) ...[
                TextButton(
                  onPressed: () {
                    final prev = state.previousStep;
                    if (prev != null) {
                      context.read<HostOnboardingBloc>().add(
                            HostStepChanged(step: prev),
                          );
                    }
                  },
                  child: Text(
                    '← Back',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
              ],
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    final bloc = context.read<HostOnboardingBloc>();
                    if (state.isSubmitting) return;

                    if (isLast) {
                      bloc.add(const HostSubmitRequested());
                    } else {
                      final next = state.nextStep;
                      if (next != null) {
                        bloc.add(HostStepChanged(step: next));
                      }
                    }
                  },
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE8507A), Color(0xFFED4B82)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: state.isSubmitting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            isLast ? 'Submit for Review' : 'Continue →',
                            style: GoogleFonts.dmSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCurrentStepWidget(int step) {
    return BlocBuilder<HostOnboardingBloc, HostOnboardingState>(
      builder: (context, state) {
        switch (step) {
          case 1:
            return PropertyTypeStep(
              listingFlow: state.isListingFlow,
              selectedType:
                  state.isListingFlow ? state.propertyType : state.hostType,
              onTypeSelected: (type) {
                final bloc = context.read<HostOnboardingBloc>();
                if (state.isListingFlow) {
                  bloc.add(HostPropertyTypeSaved(propertyType: type));
                } else {
                  bloc.add(HostTypeSelected(hostType: type));
                }
              },
            );
          case 12:
            return BookingModelStep(
              propertyType: state.propertyType!,
              selectedModel: state.bookingModel,
              onSelected: (model) => context
                  .read<HostOnboardingBloc>()
                  .add(HostBookingModelSaved(bookingModel: model)),
            );
          case 2:
            return AccountStep(
              state: state,
              bloc: context.read<HostOnboardingBloc>(),
            );
          case 3:
            return ContactStep(
              state: state,
              bloc: context.read<HostOnboardingBloc>(),
            );
          case 5:
            return LocationStep(
              state: state,
              bloc: context.read<HostOnboardingBloc>(),
              showPhysicalBasics: !state.isListingFlow,
            );
          case 13:
            return ListingDetailsStep(
              state: state,
              bloc: context.read<HostOnboardingBloc>(),
            );
          case 14:
            return UnitTypesStep(
              state: state,
              bloc: context.read<HostOnboardingBloc>(),
            );
          case 6:
            return AmenitiesStep(
              selectedAmenities: state.amenities,
              onChanged: (amenities) {
                context
                    .read<HostOnboardingBloc>()
                    .add(HostAmenitiesSaved(amenities: amenities));
              },
            );
          case 7:
            return PricingStep(
              state: state,
              bloc: context.read<HostOnboardingBloc>(),
            );
          case 8:
            return CheckinStep(
              state: state,
              bloc: context.read<HostOnboardingBloc>(),
            );
          case 9:
            return PhotosStep(
              photoPaths: state.photoPaths,
              onPhotosChanged: (paths) {
                context
                    .read<HostOnboardingBloc>()
                    .add(HostPhotosSaved(photoPaths: paths));
              },
            );
          case 10:
            return WalkthroughVideoStep(
              videoPath: state.videoPath,
              isSubmitting: state.isSubmitting,
              onVideoSelected: (path) {
                context
                    .read<HostOnboardingBloc>()
                    .add(HostVideoSaved(videoPath: path));
              },
              onSubmit: () {
                context
                    .read<HostOnboardingBloc>()
                    .add(const HostSubmitRequested());
              },
            );
          case 11:
            return ReviewSubmitStep(
              state: state,
              isSubmitting: state.isSubmitting,
              onEditStep: (stepIndex) {
                context
                    .read<HostOnboardingBloc>()
                    .add(HostStepChanged(step: stepIndex));
              },
              onSubmit: () {
                context
                    .read<HostOnboardingBloc>()
                    .add(const HostSubmitRequested());
              },
            );
          default:
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.construction,
                      size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'Step $step Component',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 18,
                      color: const Color(0xFF1A1A2E),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Will render the specific form fields here.',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            );
        }
      },
    );
  }
}
