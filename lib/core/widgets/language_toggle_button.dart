import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:durgapuja_manager/core/providers/language_provider.dart';

class LanguageToggleButton extends ConsumerWidget {
  const LanguageToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLang = ref.watch(languageProvider);

    return PopupMenuButton<AppLanguage>(
      tooltip: 'Change Language / ଭାଷା / ভাষা',
      initialValue: currentLang,
      icon: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              currentLang.icon,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(width: 4),
            Text(
              currentLang.displayName,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const Icon(
              Icons.arrow_drop_down,
              color: Colors.white,
              size: 16,
            ),
          ],
        ),
      ),
      onSelected: (AppLanguage lang) {
        ref.read(languageProvider.notifier).setLanguage(lang);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Language set to ${lang.displayName}'),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      itemBuilder: (BuildContext context) {
        return AppLanguage.values.map((AppLanguage lang) {
          final isSelected = lang == currentLang;
          return PopupMenuItem<AppLanguage>(
            value: lang,
            child: Row(
              children: [
                Text(
                  lang.icon,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    lang.displayName,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Theme.of(context).primaryColor : null,
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle_rounded,
                    color: Theme.of(context).primaryColor,
                    size: 18,
                  ),
              ],
            ),
          );
        }).toList();
      },
    );
  }
}
