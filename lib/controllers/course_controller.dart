import 'package:flutter/foundation.dart';

import 'package:flutter_app/models/course_model.dart';
import 'package:flutter_app/repositories/course_repository.dart';

enum CourseState {
  initial,
  loading,
  success,
  empty,
  error,
}

/// Controller layer for managing course state.
///
/// UI interacts with this controller only.
/// Controller interacts with repository.
/// Repository decides whether to use API or local storage.
class CourseController extends ChangeNotifier {
  final CourseRepository _repository = CourseRepository();

  CourseState state = CourseState.initial;

  List<CourseModel> courses = [];
  List<CourseModel> filteredCourses = [];

  String errorMessage = '';

  bool isAdding = false;
  bool isUpdating = false;
  bool isDeleting = false;
  bool isOfflineMode = false;

  // ── READ ──────────────────────────────────────────────────────────────────

  Future<void> fetchCourses() async {
    state = CourseState.loading;
    errorMessage = '';
    isOfflineMode = false;
    notifyListeners();

    try {
      final bool online = await _repository.isOnline;

      courses = await _repository.getCourses();
      filteredCourses = List.from(courses);

      isOfflineMode = !online;

      state = courses.isEmpty ? CourseState.empty : CourseState.success;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      state = CourseState.error;
    }

    notifyListeners();
  }

  // ── SEARCH / FILTER ───────────────────────────────────────────────────────

  void searchCourses(String query) {
    final searchText = query.trim().toLowerCase();

    if (searchText.isEmpty) {
      filteredCourses = List.from(courses);
    } else {
      filteredCourses = courses.where((course) {
        final title = course.title.toLowerCase();
        final body = course.body.toLowerCase();

        return title.contains(searchText) || body.contains(searchText);
      }).toList();
    }

    state = filteredCourses.isEmpty ? CourseState.empty : CourseState.success;
    notifyListeners();
  }

  // ── CREATE ────────────────────────────────────────────────────────────────

  Future<bool> addCourse({
    required String title,
    required String description,
  }) async {
    errorMessage = '';
    isAdding = true;

    final optimisticCourse = CourseModel(
      id: DateTime.now().millisecondsSinceEpoch,
      title: title,
      body: description,
    );

    courses.insert(0, optimisticCourse);
    filteredCourses = List.from(courses);
    state = CourseState.success;
    notifyListeners();

    try {
      final createdCourse = await _repository.createCourse(optimisticCourse);

      final index = courses.indexWhere(
        (course) => course.id == optimisticCourse.id,
      );

      if (index != -1) {
        courses[index] = createdCourse.copyWith(
          id: createdCourse.id ?? optimisticCourse.id,
        );
      }

      filteredCourses = List.from(courses);
      isAdding = false;
      state = courses.isEmpty ? CourseState.empty : CourseState.success;
      notifyListeners();

      return true;
    } catch (e) {
      courses.removeWhere((course) => course.id == optimisticCourse.id);
      filteredCourses = List.from(courses);

      errorMessage = 'Unable to add course. Change rolled back.';
      isAdding = false;
      state = courses.isEmpty ? CourseState.empty : CourseState.error;
      notifyListeners();

      return false;
    }
  }

  // ── UPDATE ────────────────────────────────────────────────────────────────

  Future<bool> editCourse({
    required CourseModel course,
    required String title,
    required String description,
  }) async {
    errorMessage = '';
    isUpdating = true;

    final index = courses.indexWhere((item) => item.id == course.id);

    if (index == -1) {
      isUpdating = false;
      errorMessage = 'Course not found.';
      state = CourseState.error;
      notifyListeners();
      return false;
    }

    final oldCourse = courses[index];

    final updatedCourse = course.copyWith(
      title: title,
      body: description,
    );

    courses[index] = updatedCourse;
    filteredCourses = List.from(courses);
    state = CourseState.success;
    notifyListeners();

    try {
      final result = await _repository.updateCourse(updatedCourse);

      courses[index] = result.copyWith(id: course.id);
      filteredCourses = List.from(courses);

      isUpdating = false;
      state = courses.isEmpty ? CourseState.empty : CourseState.success;
      notifyListeners();

      return true;
    } catch (e) {
      courses[index] = oldCourse;
      filteredCourses = List.from(courses);

      errorMessage = 'Unable to update course. Change rolled back.';
      isUpdating = false;
      state = CourseState.error;
      notifyListeners();

      return false;
    }
  }

  // ── DELETE ────────────────────────────────────────────────────────────────

  Future<bool> removeCourse(int id) async {
    errorMessage = '';
    isDeleting = true;

    final index = courses.indexWhere((course) => course.id == id);

    if (index == -1) {
      isDeleting = false;
      errorMessage = 'Course not found.';
      state = CourseState.error;
      notifyListeners();
      return false;
    }

    final deletedCourse = courses[index];

    courses.removeAt(index);
    filteredCourses = List.from(courses);
    state = courses.isEmpty ? CourseState.empty : CourseState.success;
    notifyListeners();

    try {
      await _repository.deleteCourse(id);

      isDeleting = false;
      state = courses.isEmpty ? CourseState.empty : CourseState.success;
      notifyListeners();

      return true;
    } catch (e) {
      courses.insert(index, deletedCourse);
      filteredCourses = List.from(courses);

      errorMessage = 'Unable to delete course. Change rolled back.';
      isDeleting = false;
      state = CourseState.error;
      notifyListeners();

      return false;
    }
  }
}