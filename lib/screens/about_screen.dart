import 'package:flutter/material.dart';

import '../app_info.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/trishul.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 12),
        const Center(child: Trishul(height: 140)),
        const SizedBox(height: 20),
        const Center(
          child: Text(
            AppInfo.name,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.accentLight,
            ),
          ),
        ),
        const SizedBox(height: 20),
        const GlowCard(
          child: Column(
            children: [
              Text(
                AppInfo.developer,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accent,
                  letterSpacing: 1.5,
                ),
              ),
              SizedBox(height: 10),
              Text(
                '${AppInfo.dedication} 💙',
                style: TextStyle(
                  fontSize: 20,
                  color: AppColors.accentLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 14),
              Text(
                AppInfo.tagline,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  height: 1.6,
                  color: AppColors.textSoft,
                ),
              ),
              SizedBox(height: 14),
              Text(
                'संस्करण ${AppInfo.version}',
                style: TextStyle(color: AppColors.accentDark, fontSize: 14),
              ),
            ],
          ),
        ),
        const Center(
          child: Text(
            'हर हर महादेव! 🔱',
            style: TextStyle(fontSize: 18, color: AppColors.accentLight),
          ),
        ),
      ],
    );
  }
}
