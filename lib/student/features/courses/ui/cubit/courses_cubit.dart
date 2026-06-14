import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edu_verse/core/constants/api_endpoints.dart';
import '../../data/models/course_model.dart';

part 'courses_state.dart';

class CoursesCubit extends Cubit<CoursesState> {
  CoursesCubit(this._dio) : super(CoursesInitial());

  final Dio _dio;

  Future<void> loadCourses() async {
    emit(CoursesLoading());
    try {
      final response = await _dio.get<List<dynamic>>(ApiEndpoints.getAllCourses);
      final list = response.data ?? [];
      final courses = list
          .map((e) => CourseModel.fromJson(e as Map<String, dynamic>))
          .toList();

      // Derive category list from loaded courses
      final cats = <String>['All'];
      for (final c in courses) {
        if (c.category.isNotEmpty && !cats.contains(c.category)) {
          cats.add(c.category);
        }
      }

      emit(CoursesLoaded(
        allCourses: courses,
        filteredCourses: courses,
        selectedCategory: 'All',
        searchQuery: '',
        categories: cats,
      ));
    } catch (e) {
      emit(CoursesError('Failed to load courses. Please try again.'));
    }
  }

  void filterByCategory(String category) {
    final current = state as CoursesLoaded;
    final filtered = _applyFilters(current.allCourses, category, current.searchQuery, current.selectedLevel);
    emit(current.copyWith(filteredCourses: filtered, selectedCategory: category));
  }

  void filterByLevel(String level) {
    final current = state as CoursesLoaded;
    final filtered = _applyFilters(current.allCourses, current.selectedCategory, current.searchQuery, level);
    emit(current.copyWith(filteredCourses: filtered, selectedLevel: level));
  }

  void search(String query) {
    final current = state as CoursesLoaded;
    final filtered = _applyFilters(current.allCourses, current.selectedCategory, query, current.selectedLevel);
    emit(current.copyWith(filteredCourses: filtered, searchQuery: query));
  }

  List<CourseModel> _applyFilters(
    List<CourseModel> all,
    String category,
    String query,
    String level,
  ) {
    return all.where((c) {
      final matchesCategory = category == 'All' || c.category == category;
      final matchesSearch = query.isEmpty ||
          c.title.toLowerCase().contains(query.toLowerCase()) ||
          c.instructor.toLowerCase().contains(query.toLowerCase());
      final matchesLevel = level == 'All' || c.level.toLowerCase() == level.toLowerCase();
      return matchesCategory && matchesSearch && matchesLevel;
    }).toList();
  }
}
