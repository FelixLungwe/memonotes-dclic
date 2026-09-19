import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

Future<bool> showDeleteNoteDialog(
  BuildContext context,
) async {
  final bool? confirmed =
      await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (
      BuildContext dialogContext,
    ) {
      return AlertDialog(
        backgroundColor:
            AppColors.white,
        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(
            16,
          ),
        ),
        title: const Text(
          'Supprimer la note ?',
          style: TextStyle(
            fontSize: 20,
            fontWeight:
                FontWeight.w700,
            color:
                AppColors.textPrimary,
          ),
        ),
        content: const Text(
          'Cette action supprimera définitivement '
          'cette note. Elle ne pourra pas être annulée.',
          style: TextStyle(
            fontSize: 14,
            color:
                AppColors.textSecondary,
          ),
        ),
        actionsPadding:
            const EdgeInsets.fromLTRB(
          24,
          0,
          24,
          24,
        ),
        actions: [
          OutlinedButton(
            onPressed: () {
              Navigator.pop(
                dialogContext,
                false,
              );
            },
            style:
                OutlinedButton
                    .styleFrom(
              foregroundColor:
                  AppColors
                      .textPrimary,
              side:
                  const BorderSide(
                color:
                    AppColors.border,
              ),
            ),
            child: const Text(
              'Annuler',
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(
                dialogContext,
                true,
              );
            },
            style:
                ElevatedButton
                    .styleFrom(
              backgroundColor:
                  AppColors.error,
              foregroundColor:
                  AppColors.white,
              minimumSize:
                  const Size(
                120,
                48,
              ),
            ),
            child: const Text(
              'Supprimer',
            ),
          ),
        ],
      );
    },
  );

  return confirmed ?? false;
}
