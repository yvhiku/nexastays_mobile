import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/exceptions.dart';
import '../../../property/data/datasources/property_remote_datasource.dart';
import '../../data/models/host_reviews_payload.dart';
import 'host_reviews_state.dart';

class HostReviewsCubit extends Cubit<HostReviewsState> {
  HostReviewsCubit({required PropertyRemoteDataSource propertyRemote})
      : _propertyRemote = propertyRemote,
        super(const HostReviewsInitial());

  final PropertyRemoteDataSource _propertyRemote;

  Future<void> load({bool refresh = true}) async {
    if (!refresh && state is HostReviewsLoaded) return;

    emit(const HostReviewsLoading());
    await _fetchPage(page: 1, append: false);
  }

  Future<void> loadMore() async {
    final current = state;
    if (current is! HostReviewsLoaded ||
        current.isLoadingMore ||
        current.payload.reviews.length >= current.payload.total) {
      return;
    }

    emit(current.copyWith(isLoadingMore: true));
    await _fetchPage(page: current.payload.page + 1, append: true);
  }

  Future<void> _fetchPage({required int page, required bool append}) async {
    try {
      final data = await _propertyRemote.getHostReviews(page: page, limit: 20);

      if (append && state is HostReviewsLoaded) {
        final prev = (state as HostReviewsLoaded).payload;
        final merged = HostReviewsPayload(
          reviews: [...prev.reviews, ...data.reviews],
          summary: data.summary,
          page: data.page,
          limit: data.limit,
          total: data.total,
        );
        emit(HostReviewsLoaded(payload: merged));
        return;
      }

      emit(HostReviewsLoaded(payload: data));
    } on ServerException catch (e) {
      emit(HostReviewsError(e.message));
    } catch (e) {
      emit(HostReviewsError(e.toString()));
    }
  }

  Future<void> refresh() => load(refresh: true);
}
