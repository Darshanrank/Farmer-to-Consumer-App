import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kisanbazaar/theme/app_colors.dart';

class PromoBannerData {
  final String title;
  final String subtitle;
  final String badgeText;
  final IconData icon;
  final Color backgroundColor;
  final Color borderColor;

  PromoBannerData({
    required this.title,
    required this.subtitle,
    required this.badgeText,
    required this.icon,
    required this.backgroundColor,
    required this.borderColor,
  });
}

class PromoBannerCarousel extends StatefulWidget {
  const PromoBannerCarousel({super.key});

  @override
  State<PromoBannerCarousel> createState() => _PromoBannerCarouselState();
}

class _PromoBannerCarouselState extends State<PromoBannerCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  final List<PromoBannerData> _banners = [
    PromoBannerData(
      title: "Organic Veggies",
      subtitle: "Delivered in 24 hours",
      badgeText: "DIRECT FROM FARM",
      icon: Icons.local_shipping_rounded,
      backgroundColor: const Color(0xFFF0FDF4),
      borderColor: const Color(0xFFDCFCE7),
    ),
    PromoBannerData(
      title: "Premium Seeds",
      subtitle: "Upto 30% Off on Hybrids",
      badgeText: "SEEDS FESTIVAL",
      icon: Icons.eco_rounded,
      backgroundColor: const Color(0xFFFFF7ED),
      borderColor: const Color(0xFFFFEDD5),
    ),
    PromoBannerData(
      title: "Agro Tools",
      subtitle: "Rentals starting at ₹500",
      badgeText: "EQUIPMENT DEALS",
      icon: Icons.build_circle_rounded,
      backgroundColor: const Color(0xFFEFF6FF),
      borderColor: const Color(0xFFDBEAFE),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (_pageController.hasClients) {
        int nextPage = (_currentPage + 1) % _banners.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 140,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemCount: _banners.length,
            itemBuilder: (context, index) {
              final banner = _banners[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: banner.backgroundColor,
                    border: Border.all(color: banner.borderColor, width: 1.5),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -10,
                        bottom: -10,
                        child: Icon(
                          banner.icon,
                          size: 120,
                          color: AppColors.primary.withValues(alpha: 0.15),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                banner.badgeText,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              banner.title,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              banner.subtitle,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_banners.length, (index) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 6,
              width: _currentPage == index ? 16 : 6,
              decoration: BoxDecoration(
                color: _currentPage == index ? AppColors.primary : AppColors.divider,
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }
}
