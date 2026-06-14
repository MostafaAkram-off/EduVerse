part of 'courses_cubit.dart';

abstract class CoursesState {}

class CoursesInitial extends CoursesState {}

class CoursesLoading extends CoursesState {}

class CoursesLoaded extends CoursesState {
  final List<CourseModel> allCourses;
  final List<CourseModel> filteredCourses;
  final String selectedCategory;
  final String selectedLevel;
  final String searchQuery;
  final List<String> categories;

  CoursesLoaded({
    required this.allCourses,
    required this.filteredCourses,
    required this.selectedCategory,
    this.selectedLevel = 'All',
    required this.searchQuery,
    required this.categories,
  });

  CoursesLoaded copyWith({
    List<CourseModel>? filteredCourses,
    String? selectedCategory,
    String? selectedLevel,
    String? searchQuery,
  }) {
    return CoursesLoaded(
      allCourses: allCourses,
      filteredCourses: filteredCourses ?? this.filteredCourses,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedLevel: selectedLevel ?? this.selectedLevel,
      searchQuery: searchQuery ?? this.searchQuery,
      categories: categories,
    );
  }
}

class CoursesError extends CoursesState {
  final String message;
  CoursesError(this.message);
}
