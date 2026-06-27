import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter_app/models/course_model.dart';

/// Service layer for all API calls.
/// Works on BOTH Mobile + Web
class CourseApiService {
  static const String _baseUrl = 'https://jsonplaceholder.typicode.com';
  static const String _endpoint = '/posts';

  // ── READ ────────────────────────────────────────────────────────────────
  Future<List<CourseModel>> getCourses() async {
    try {
      final uri = Uri.parse('$_baseUrl$_endpoint?_limit=10');

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);

        return jsonList
            .map((json) => CourseModel.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load courses (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // ── CREATE ────────────────────────────────────────────────────────────────
  Future<CourseModel> createCourse(CourseModel course) async {
    try {
      final uri = Uri.parse('$_baseUrl$_endpoint');

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode(course.toJson()),
      );

      if (response.statusCode == 201) {
        return CourseModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create course (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // ── UPDATE ────────────────────────────────────────────────────────────────
  Future<CourseModel> updateCourse(CourseModel course) async {
    try {
      final uri = Uri.parse('$_baseUrl$_endpoint/${course.id}');

      final response = await http.put(
        uri,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode(course.toJson()),
      );

      if (response.statusCode == 200) {
        return CourseModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update course (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // ── DELETE ────────────────────────────────────────────────────────────────
  Future<void> deleteCourse(int id) async {
    try {
      final uri = Uri.parse('$_baseUrl$_endpoint/$id');

      final response = await http.delete(uri);

      if (response.statusCode != 200) {
        throw Exception('Failed to delete course (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}