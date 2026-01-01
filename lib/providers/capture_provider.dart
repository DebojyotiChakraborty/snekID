import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for the currently selected/captured image
final selectedImageProvider = StateProvider<File?>((ref) => null);

/// Provider for camera initialization state
final cameraInitializedProvider = StateProvider<bool>((ref) => false);

/// Provider for the current camera index (front/back)
final currentCameraIndexProvider = StateProvider<int>((ref) => 0);
