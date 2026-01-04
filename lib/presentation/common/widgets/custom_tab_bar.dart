import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class CustomTabBar extends StatelessWidget {
  final TabController controller;
  final List<String> tabs;

  const CustomTabBar({
    super.key,
    required this.controller,
    required this.tabs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: context.isDarkMode
            ? AppColors.surfaceLightDark
            : AppColors.surfaceLightLight,
        borderRadius: BorderRadius.circular(100),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tabWidth = constraints.maxWidth / tabs.length;
          
          return AnimatedBuilder(
            animation: controller.animation!,
            builder: (context, child) {
              final double offset = controller.animation!.value * tabWidth;

              return Stack(
                children: [
                  // Indicators (Sliding Background)
                  Positioned(
                    left: offset,
                    top: 0,
                    bottom: 0,
                    width: tabWidth,
                    child: Container(
                      decoration: BoxDecoration(
                        color: context.backgroundColor,
                        borderRadius: BorderRadius.circular(100),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Text Labels
                  Row(
                    children: List.generate(tabs.length, (index) {
                      final isSelected = controller.index == index;
                      // Determine if transition is happening around this index
                      // Simple approach: Using AnimatedBuilder to rebuild is enough?
                      // We can check controller.animation.value to animate text color seamlessly?
                      // But effectively standard text color transition is fine.
                      
                      return SizedBox(
                        width: tabWidth,
                        child: Center(
                          child: Text(
                            tabs[index],
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Inter',
                              color: _getTextColor(context, index),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  
                  // Invisible Tappable Area
                  Row(
                    children: List.generate(tabs.length, (index) {
                      return Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            controller.animateTo(index);
                          },
                          child: const SizedBox(height: 32),
                        ),
                      );
                    }),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Color _getTextColor(BuildContext context, int index) {
     // Identify animation value
     final double animValue = controller.animation!.value;
     // simple logic: if closer to index than 0.5, use primary, else tertiary
     final double diff = (animValue - index).abs();
     
     if (diff < 0.5) {
       return context.textPrimaryColor;
     } else {
       return context.textTertiaryColor;
     }
  }
}
