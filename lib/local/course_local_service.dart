import 'package:hive/hive.dart';

import '../models/course_model.dart';

class CourseLocalService {
  final Box _box = Hive.box('coursesBox');

  Future<void> saveCourses(List<CourseModel> courses) async {
    final data = courses.map((course) => course.toJson()).toList();
    await _box.put('courses', data);
  }

  List<CourseModel> getCourses() {
    final data = _box.get('courses');

    if (data == null) {
      return [];
    }

    final List courseList = data as List;

    return courseList
        .map(
          (item) => CourseModel.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
  }

  Future<void> addCourse(CourseModel course) async {
    final courses = getCourses();
    courses.insert(0, course);
    await saveCourses(courses);
  }

  Future<void> updateCourse(CourseModel updatedCourse) async {
    final courses = getCourses();

    final index = courses.indexWhere(
      (course) => course.id == updatedCourse.id,
    );

    if (index != -1) {
      courses[index] = updatedCourse;
      await saveCourses(courses);
    }
  }

  Future<void> deleteCourse(int id) async {
    final courses = getCourses();
    courses.removeWhere((course) => course.id == id);
    await saveCourses(courses);
  }
}