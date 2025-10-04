import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:http/http.dart';

class ApiResult<T> {
  final T? data;
  final String? message;

  ApiResult._({this.data, this.message});

  factory ApiResult.success(T data) => ApiResult._(data: data);
  factory ApiResult.error(String message) => ApiResult._(message: message);
}

// handle any exception
Future<ApiResult<T>> safeApiCall<T>(Future<T> Function() apiCall) async {
  try {
    final result = await apiCall();
    return ApiResult.success(result);
  } on ClientException {
    return ApiResult.error("Network request failed. Please check your connection.");
  } on SocketException {
    return ApiResult.error("No internet connection. Please check your network.");
  } on TimeoutException {
    return ApiResult.error("The connection timed out. Please try again.");
  } on HttpException {
    return ApiResult.error("An HTTP error occurred. Please try again.");
  } on FormatException {
    return ApiResult.error("Invalid response format. Please contact support.");
  } on TypeError {
    return ApiResult.error("Unexpected data type encountered. Please try again.");
  } on PlatformException catch (e) {
    return ApiResult.error("A platform error occurred: ${e.message}");
  } on UnsupportedError {
    return ApiResult.error("Unsupported operation encountered. Please try again.");
  } on RangeError {
    return ApiResult.error("An out-of-bounds error occurred. Please try again.");
  } on StateError {
    return ApiResult.error("Invalid state encountered during operation. Please try again.");
  } on JsonUnsupportedObjectError {
    return ApiResult.error("Failed to encode data to JSON. Please try again.");
  } catch (e) {
    return ApiResult.error("An unexpected error occurred: ${e.toString()}. Please try again.");
  }
}
