import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';

/// Image header with the captured image and close button
class ImageHeader extends StatelessWidget {
  final File? imageFile;
  final VoidCallback onClose;

  const ImageHeader({
    super.key,
    required this.imageFile,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final timeString =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    return Stack(
      children: [
        // Image
        AspectRatio(
          aspectRatio: 4 / 3,
          child: imageFile != null
              ? Image.file(
                  imageFile!,
                  fit: BoxFit.cover,
                )
              : Builder(
                  builder: (context) {
                    return Container(
                      color: context.surfaceLightColor,
                      child: Icon(
                        MingCuteIcons.mgc_pic_line,
                        size: 64,
                        color: context.textMutedColor,
                      ),
                    );
                  },
                ),
        ),

        // Gradient overlay at bottom
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Builder(
            builder: (context) {
              return Container(
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      context.backgroundColor,
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Close button
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          left: 16,
          child: _CloseButton(onPressed: onClose),
        ),

        // Timestamp
        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: Builder(
            builder: (context) {
              return Text(
                '${AppStrings.photoAnalyzedAt} $timeString',
                style: TextStyle(
                  color: context.textSecondaryColor,
                  fontSize: 12,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CloseButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _CloseButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.overlay,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: const Padding(
          padding: EdgeInsets.all(8),
          child: Icon(
            MingCuteIcons.mgc_close_line,
            color: AppColors.textPrimary,
            size: 24,
          ),
        ),
      ),
    );
  }
}
