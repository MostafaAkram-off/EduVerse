import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/course_model.dart';
import 'package:edu_verse/student/features/mock_data.dart';

part 'courses_state.dart';

class CoursesCubit extends Cubit<CoursesState> {
  CoursesCubit() : super(CoursesInitial());

  Future<void> loadCourses() async {
    emit(CoursesLoading());

    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final courses = MockData.courses;
      emit(CoursesLoaded(
        allCourses: courses,
        filteredCourses: courses,
        selectedCategory: 'All',
        searchQuery: '',
      ));
    } catch (e) {
      emit(CoursesError('Failed to load courses. Please try again.'));
    }
  }

  void filterByCategory(String category) {
    final current = state as CoursesLoaded;
    final filtered = _applyFilters(
      current.allCourses,
      category,
      current.searchQuery,
    );
    emit(current.copyWith(
      filteredCourses: filtered,
      selectedCategory: category,
    ));
  }

  void search(String query) {
    final current = state as CoursesLoaded;
    final filtered = _applyFilters(
      current.allCourses,
      current.selectedCategory,
      query,
    );
    emit(current.copyWith(
      filteredCourses: filtered,
      searchQuery: query,
    ));
  }

  List<CourseModel> _applyFilters(
      List<CourseModel> all,
      String category,
      String query,
      ) {
    return all.where((c) {
      final matchesCategory =
          category == 'All' || c.category == category;
      final matchesSearch =
          query.isEmpty ||
              c.title.toLowerCase().contains(query.toLowerCase()) ||
              c.instructor.toLowerCase().contains(query.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }
}