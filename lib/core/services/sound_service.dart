import 'package:audioplayers/audioplayers.dart';

import 'logger_service.dart';

/// Service for playing sound effects in the app
class SoundService {
  SoundService._();

  static final SoundService _instance = SoundService._();
  static SoundService get instance => _instance;

  final AudioPlayer _audioPlayer = AudioPlayer();

  /// Play the camera shutter sound
  Future<void> playShutterSound() async {
    try {
      await _audioPlayer.play(
        AssetSource('sounds/camera_shutter.mp3'),
        volume: 0.7,
        mode: PlayerMode.lowLatency,
      );
    } catch (e) {
      // Log error but don't crash the app if sound fails
      // This is expected if the sound file hasn't been added yet
      LoggerService.d('Shutter sound not available: $e');
    }
  }

  /// Dispose the audio player
  void dispose() {
    _audioPlayer.dispose();
  }
}
