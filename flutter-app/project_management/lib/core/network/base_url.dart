import 'package:flutter/foundation.dart';

const String _envBaseUrl = String.fromEnvironment('API_BASE_URL');

String resolveBaseUrl({String? overrideBaseUrl}) {
  final manualOverride = overrideBaseUrl?.trim();
  if (manualOverride != null && manualOverride.isNotEmpty) {
    return manualOverride;
  }

  if (_envBaseUrl.isNotEmpty) {
    return _envBaseUrl;
  }

  if (kIsWeb) {
    return 'http://localhost:8000';
  }

  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      return 'http://localhost:8000';
    case TargetPlatform.iOS:
    case TargetPlatform.macOS:
      return 'http://127.0.0.1:8000';
    case TargetPlatform.windows:
    case TargetPlatform.linux:
    case TargetPlatform.fuchsia:
      return 'http://localhost:8000';
  }
}
