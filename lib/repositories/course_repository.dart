import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:flutter_app/local/course_local_service.dart';
import 'package:flutter_app/models/course_model.dart';
import 'package:flutter_app/services/course_api_service.dart';

class CourseRepository {
  final CourseApiService _apiService = CourseApiService();
  final CourseLocalService _localService = CourseLocalService();

  Future<bool> get isOnline async {
    final List<ConnectivityResult> results =
        await Connectivity().checkConnectivity();

    return !results.contains(ConnectivityResult.none);
  }

  Future<List<CourseModel>> getCourses() async {
    final bool online = await isOnline;

    if (online) {
      try {
        final courses = await _apiService.getCourses();

        await _localService.saveCourses(courses);

        return courses;
      } catch (_) {
        return _localService.getCourses();
      }
    }

    return _localService.getCourses();
  }

  Future<CourseModel> createCourse(CourseModel course) async {
    final bool online = await isOnline;

    if (online) {
      final createdCourse = await _apiService.createCourse(course);

      await _localService.addCourse(createdCourse);

      return createdCourse;
    }

    final offlineCourse = course.copyWith(
      id: course.id ?? DateTime.now().millisecondsSinceEpoch,
    );

    await _localService.addCourse(offlineCourse);

    return offlineCourse;
  }

  Future<CourseModel> updateCourse(CourseModel course) async {
    final bool online = await isOnline;

    if (online) {
      final updatedCourse = await _apiService.updateCourse(course);

      final courseWithOriginalId = updatedCourse.copyWith(
        id: course.id,
      );

      await _localService.updateCourse(courseWithOriginalId);

      return courseWithOriginalId;
    }

    await _localService.updateCourse(course);

    return course;
  }

  Future<void> deleteCourse(int id) async {
    final bool online = await isOnline;

    if (online) {
      await _apiService.deleteCourse(id);
    }

    await _localService.deleteCourse(id);
  }
}