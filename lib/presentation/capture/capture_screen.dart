import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/router/app_router.dart';
import '../../core/services/logger_service.dart';
import '../../providers/capture_provider.dart';
import '../../providers/onboarding_provider.dart';
import 'widgets/camera_frame_overlay.dart';
import 'widgets/capture_controls.dart';
import 'widgets/capture_confirmation_dialog.dart';
import 'widgets/intro_prompt_alert.dart';
import '../common/widgets/drops.dart';

/// Capture screen with camera preview
class CaptureScreen extends ConsumerStatefulWidget {
  const CaptureScreen({super.key});

  @override
  ConsumerState<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends ConsumerState<CaptureScreen>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isTakingPicture = false;
  final int _currentCameraIndex = 0;
  String? _errorMessage;
  bool _isFlashOn = false;

  // State for captured image preview
  File? _capturedImage;
  bool _showConfirmation = false;

  // State for first-launch intro prompt
  bool _showIntroPrompt = false;
  bool _introPromptChecked = false;
  bool _isRetaking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Turn off flash before disposing
    _turnOffFlash();
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _turnOffFlash() async {
    if (_cameraController != null &&
        _cameraController!.value.isInitialized &&
        _isFlashOn) {
      try {
        await _cameraController!.setFlashMode(FlashMode.off);
      } catch (e) {
        // Ignore errors when turning off flash
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      // Turn off flash when app becomes inactive
      _turnOffFlash();
      _cameraController?.dispose();
      // Ensure we don't try to use the disposed controller
      if (mounted) {
        setState(() {
          _isInitialized = false;
        });
      }
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
      // Reset flash state when camera is reinitialized
      setState(() {
        _isFlashOn = false;
      });
    }
  }

  Future<void> _initializeCamera() async {
    // Check if intro prompt should be shown (first launch)
    if (!_introPromptChecked) {
      final introShown = await ref.read(introPromptShownProvider.future);
      if (!introShown) {
        setState(() {
          _showIntroPrompt = true;
          _introPromptChecked = true;
        });
        return; // Don't request camera permission yet
      }
      _introPromptChecked = true;
    }

    // Check camera permission
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      setState(() {
        _errorMessage = AppStrings.errorCamera;
      });
      return;
    }

    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        setState(() {
          _errorMessage = 'No cameras available';
        });
        return;
      }

      await _setupCamera(_currentCameraIndex);
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to initialize camera: $e';
      });
    }
  }

  Future<void> _setupCamera(int cameraIndex) async {
    if (_cameras == null || _cameras!.isEmpty) return;

    // Dispose existing controller
    await _cameraController?.dispose();

    _cameraController = CameraController(
      _cameras![cameraIndex],
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await _cameraController!.initialize();
      // Set initial flash mode (torch off by default)
      await _cameraController!.setFlashMode(FlashMode.off);
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _errorMessage = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to initialize camera: $e';
      });
    }
  }

  Future<void> _takePicture() async {
    if (_cameraController == null ||
        !_cameraController!.value.isInitialized ||
        _isTakingPicture) {
      return;
    }

    setState(() {
      _isTakingPicture = true;
    });

    try {
      final XFile photo = await _cameraController!.takePicture();
      _showCapturedImageConfirmation(File(photo.path));
    } catch (e) {
      _showError('Failed to capture photo: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isTakingPicture = false;
        });
      }
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        _showCapturedImageConfirmation(File(image.path));
      }
    } catch (e) {
      _showError('Failed to pick image: $e');
    }
  }

  void _showCapturedImageConfirmation(File imageFile) {
    setState(() {
      _capturedImage = imageFile;
      _showConfirmation = true;
    });
  }

  void _onRetake() async {
    setState(() {
      _showConfirmation = false;
      _isRetaking = true;
    });

    // Wait for animation to slide down (matches dialog animation duration)
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      setState(() {
        _capturedImage = null;
        _isRetaking = false;
      });
    }
  }

  void _onIntroContinue() async {
    // Hide intro prompt with animation
    setState(() {
      _showIntroPrompt = false;
    });

    // Wait for animation to complete
    await Future.delayed(const Duration(milliseconds: 500));

    // Mark as shown in preferences
    await ref.read(introPromptControllerProvider.notifier).markShown();

    // Now initialize camera (which will request permission)
    if (mounted) {
      _initializeCamera();
    }
  }

  void _onIdentify() async {
    if (_capturedImage != null) {
      // Turn off flash before navigating
      if (_isFlashOn) {
        await _turnOffFlash();
        setState(() {
          _isFlashOn = false;
        });
      }

      ref.read(selectedImageProvider.notifier).state = _capturedImage;
      if (mounted) {
        // Reset state before navigating to ensure it's clean if we come back
        final currentImage = _capturedImage;
        setState(() {
          _capturedImage = null;
          _showConfirmation = false;
        });

        await context.pushNamed('analysis', extra: {'imageFile': currentImage});
      }
    }
  }

  void _onHistory() async {
    // Turn off flash before navigating to history
    if (_isFlashOn) {
      await _turnOffFlash();
      setState(() {
        _isFlashOn = false;
      });
    }
    if (mounted) {
      context.push(AppRoutes.history);
    }
  }

  Future<void> _toggleFlash() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    final newFlashState = !_isFlashOn;

    try {
      // Use torch mode for continuous flash (light stays on)
      await _cameraController!.setFlashMode(
        newFlashState ? FlashMode.torch : FlashMode.off,
      );
      setState(() {
        _isFlashOn = newFlashState;
      });
    } catch (e) {
      LoggerService.w('Failed to set flash mode: $e');
    }
  }

  void _showError(String message) {
    if (mounted) {
      Drops.show(
        context,
        title: message,
        backgroundColor: AppColors.error,
        position: DropPosition.bottom,
        icon: MingCuteIcons.mgc_warning_line,
        iconColor: AppColors.white,
        titleTextStyle: const TextStyle(
          color: AppColors.white,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      );
    }
  }

  void _openSettings() async {
    // Turn off flash before navigating to settings
    if (_isFlashOn) {
      await _turnOffFlash();
      setState(() {
        _isFlashOn = false;
      });
    }
    if (mounted) {
      context.push(AppRoutes.settings);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Camera preview or captured image or error state
          if (_errorMessage != null)
            _buildErrorState()
          else if (_isInitialized && _cameraController != null)
            _buildCameraPreview()
          else
            _buildLoadingState(),

          // Captured Image Preview (Stacked on top)
          if (_capturedImage != null) _buildCapturedImagePreview(),

          // Frame overlay (show on camera preview or captured image)
          if (_isInitialized || _showConfirmation)
            CameraFrameOverlay(showCrosshair: !_showConfirmation),

          // Settings button at top right (only show when not in confirmation mode)
          if (!_showConfirmation)
            Positioned(
              top: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: GestureDetector(
                    onTap: _openSettings,
                    child: const Icon(
                      MingCuteIcons.mgc_settings_3_line,
                      color: AppColors.textPrimary,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),

          // Controls (only show when not in confirmation mode)
          if (!_showConfirmation)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: CaptureControls(
                onCapture: _takePicture,
                onGallery: _pickFromGallery,
                onHistory: _onHistory,
                onFlash: _toggleFlash,
                isFlashOn: _isFlashOn,
                isCapturing: _isTakingPicture,
              ),
            ),

          // Confirmation dialog (Animated)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: CaptureConfirmationDialog(
                onRetake: _onRetake,
                onIdentify: _onIdentify,
                isVisible: _showConfirmation,
              ),
            ),
          ),

          // First-launch intro prompt (Animated)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: IntroPromptAlert(
                onContinue: _onIntroContinue,
                isVisible: _showIntroPrompt,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCapturedImagePreview() {
    return SizedBox.expand(
      child: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedOpacity(
            opacity: _isRetaking ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            child: Hero(
              tag: 'snake_image',
              child: Image.file(_capturedImage!, fit: BoxFit.cover),
            ),
          ),
          // Gradient overlay for better text visibility if needed, or simply style
          if (_showConfirmation)
            Container(color: Colors.black.withValues(alpha: 0.12)),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: _cameraController!.value.previewSize?.height ?? 1,
          height: _cameraController!.value.previewSize?.width ?? 1,
          child: CameraPreview(_cameraController!),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: 16),
          Text(
            'Initializing camera...',
            style: TextStyle(
              fontFamily: 'Inter',
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              MingCuteIcons.mgc_camera_line,
              size: 64,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Inter',
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _initializeCamera,
              child: const Text(AppStrings.tryAgain),
            ),
          ],
        ),
      ),
    );
  }
}
