part of 'home_cubit.dart';

abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<CourseModel> enrolledCourses;
  final List<Map<String, dynamic>> upcomingSessions;
  final List<CourseModel> recommendedCourses;
  final int completedCourses;
  final int totalHours;
  final int unreadNotifications;

  HomeLoaded({
    required this.enrolledCourses,
    required this.upcomingSessions,
    required this.recommendedCourses,
    required this.completedCourses,
    required this.totalHours,
    this.unreadNotifications = 0,
  });
}

class HomeError extends HomeState {
  final String message;
  HomeError(this.message);
}