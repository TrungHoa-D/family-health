import 'dart:async';

import 'package:family_health/domain/entities/medication_category.dart';
import 'package:family_health/domain/usecases/get_user_usecase.dart';
import 'package:family_health/domain/usecases/watch_categories_usecase.dart';
import 'package:family_health/domain/usecases/watch_medications_usecase.dart';
import 'package:family_health/presentation/base/page_status.dart';
import 'package:family_health/presentation/cubit_base/base_cubit.dart';
import 'package:family_health/presentation/cubit_base/base_cubit_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'category_list_cubit.freezed.dart';
part 'category_list_state.dart';

@injectable
class CategoryListCubit extends BaseCubit<CategoryListState> {
  CategoryListCubit(
    this._watchCategoriesUseCase,
    this._watchMedicationsUseCase,
    this._getUserUseCase, {
    FirebaseAuth? firebaseAuth,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        super(const CategoryListState());

  final WatchCategoriesUseCase _watchCategoriesUseCase;
  final WatchMedicationsUseCase _watchMedicationsUseCase;
  final GetUserUseCase _getUserUseCase;
  final FirebaseAuth _firebaseAuth;
  StreamSubscription? _categoriesSubscription;
  StreamSubscription? _medsSubscription;

  Future<void> loadData() async {
    emit(state.copyWith(pageStatus: PageStatus.Loading));

    final user = _firebaseAuth.currentUser;
    if (user == null) {
      emit(state.copyWith(
        pageStatus: PageStatus.Error,
        pageErrorMessage: 'User not logged in',
      ));
      return;
    }

    final userEntity = await _getUserUseCase.call(params: user.uid);
    final familyId = userEntity?.familyId;

    if (familyId == null) {
      emit(state.copyWith(
        pageStatus: PageStatus.Error,
        pageErrorMessage: 'No family group found',
      ));
      return;
    }

    // Watch categories
    _categoriesSubscription?.cancel();
    _categoriesSubscription = _watchCategoriesUseCase.call().listen(
      (categories) {
        emit(state.copyWith(
          pageStatus: PageStatus.Loaded,
          categories: categories,
        ));
      },
      onError: (e) {
        emit(state.copyWith(
          pageStatus: PageStatus.Loaded,
          categories: [],
        ));
      },
    );

    // Watch medications to count per category
    _medsSubscription?.cancel();
    _medsSubscription = _watchMedicationsUseCase.call(familyId).listen(
      (meds) {
        // Count medications per category
        final countMap = <String, int>{};
        for (final med in meds) {
          for (final cat in med.categories) {
            countMap[cat] = (countMap[cat] ?? 0) + 1;
          }
        }
        emit(state.copyWith(medicationCountMap: countMap));
      },
      onError: (_) {},
    );
  }

  void updateSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  @override
  Future<void> close() {
    _categoriesSubscription?.cancel();
    _medsSubscription?.cancel();
    return super.close();
  }
}
