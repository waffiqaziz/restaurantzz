import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:restaurantzz/core/networking/utils/api_utils.dart';

void main() {
  group('safeApiCall', () {
    test('returnSuccess_ForValidApiCall', () async {
      final result = await safeApiCall(() async => 'success');
      expect(result.data, 'success');
      expect(result.message, isNull);
    });

    test('returnError_ForClientException', () async {
      final result = await safeApiCall(() => throw ClientException('Failed'));
      expect(result.data, isNull);
      expect(result.message,
          "Network request failed. Please check your connection.");
    });

    test('returnError_ForSocketException', () async {
      final result =
          await safeApiCall(() => throw SocketException('No connection'));
      expect(result.data, isNull);
      expect(
          result.message, "No internet connection. Please check your network.");
    });

    test('returnError_ForTimeoutException', () async {
      final result =
          await safeApiCall(() => throw TimeoutException('Timed out'));
      expect(result.data, isNull);
      expect(result.message, "The connection timed out. Please try again.");
    });

    test('returnError_ForHttpException', () async {
      final result = await safeApiCall(() => throw HttpException('HTTP error'));
      expect(result.data, isNull);
      expect(result.message, "An HTTP error occurred. Please try again.");
    });

    test('returnError_ForFormatException', () async {
      final result =
          await safeApiCall(() => throw FormatException('Invalid format'));
      expect(result.data, isNull);
      expect(
          result.message, "Invalid response format. Please contact support.");
    });

    test('returnError_ForTypeError', () async {
      final result = await safeApiCall(() => throw TypeError());
      expect(result.data, isNull);
      expect(result.message,
          "Unexpected data type encountered. Please try again.");
    });

    test('returnError_ForPlatformException', () async {
      final result = await safeApiCall(() =>
          throw PlatformException(code: '500', message: 'Platform error'));
      expect(result.data, isNull);
      expect(result.message, "A platform error occurred: Platform error");
    });

    test('returnError_ForUnsupportedError', () async {
      final result = await safeApiCall(
          () => throw UnsupportedError('Unsupported operation'));
      expect(result.data, isNull);
      expect(result.message,
          "Unsupported operation encountered. Please try again.");
    });

    test('returnError_ForRangeError', () async {
      final result = await safeApiCall(() => throw RangeError('Out of bounds'));
      expect(result.data, isNull);
      expect(
          result.message, "An out-of-bounds error occurred. Please try again.");
    });

    test('returnError_ForStateError', () async {
      final result = await safeApiCall(() => throw StateError('Invalid state'));
      expect(result.data, isNull);
      expect(result.message,
          "Invalid state encountered during operation. Please try again.");
    });

    test('returnError_ForJsonUnsupportedObjectError', () async {
      final result =
          await safeApiCall(() => throw JsonUnsupportedObjectError(Object()));
      expect(result.data, isNull);
      expect(
          result.message, "Failed to encode data to JSON. Please try again.");
    });

    test('returnError_ForUnexpectedException', () async {
      final result =
          await safeApiCall(() => throw Exception('Unexpected error'));
      expect(result.data, isNull);
      expect(result.message,
          "An unexpected error occurred: Exception: Unexpected error. Please try again.");
    });
  });
}
