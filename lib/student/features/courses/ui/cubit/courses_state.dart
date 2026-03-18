part of 'courses_cubit.dart';

abstract class CoursesState {}

class CoursesInitial extends CoursesState {}

class CoursesLoading extends CoursesState {}

class CoursesLoaded extends CoursesState {
  final List<CourseModel> allCourses;
  final List<CourseModel> filteredCourses;
  final String selectedCategory;
  final String searchQuery;

  CoursesLoaded({
    required this.allCourses,
    required this.filteredCourses,
    required this.selectedCategory,
    required this.searchQuery,
  });

  CoursesLoaded copyWith({
    List<CourseModel>? filteredCourses,
    String? selectedCategory,
    String? searchQuery,
  }) {
    return CoursesLoaded(
      allCourses: allCourses,
      filteredCourses: filteredCourses ?? this.filteredCourses,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class CoursesError extends CoursesState {
  final String message;
  CoursesError(this.message);
}