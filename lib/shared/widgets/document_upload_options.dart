import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:learning_coach/core/constants/app_strings.dart';
import 'package:learning_coach/shared/data/providers.dart';

void showDocumentUploadOptions({
  required BuildContext context,
  required WidgetRef ref,
  required String locale,
}) {
  final parentContext = context;
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (BuildContext sheetContext) {
      return Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            _UploadOptionTile(
              icon: Icons.upload_file_rounded,
              title: AppStrings.getUploadFile(locale),
              subtitle: AppStrings.getUploadFileSubtitle(locale),
              color: const Color(0xFF6366F1),
              onTap: () async {
                Navigator.pop(sheetContext);
                await Future<void>.delayed(const Duration(milliseconds: 150));
                try {
                  FilePickerResult? result = await FilePicker.platform
                      .pickFiles(
                        withData: true,
                        withReadStream: true,
                        type: FileType.any,
                      );
                  if (result != null) {
                    final file = result.files.single;
                    final extension = file.extension?.toLowerCase();
                    const allowedExtensions = {'pdf', 'docx', 'txt'};

                    if (extension != null &&
                        extension.isNotEmpty &&
                        !allowedExtensions.contains(extension)) {
                      if (parentContext.mounted) {
                        ScaffoldMessenger.of(parentContext).showSnackBar(
                          const SnackBar(
                            content: Text('Bu dosya türü desteklenmiyor.'),
                          ),
                        );
                      }
                      return;
                    }

                    final repo = ref.read(apiDocumentRepositoryProvider);

                    if (file.path != null) {
                      await repo.uploadDocument(File(file.path!));
                    } else if (file.bytes != null) {
                      await repo.uploadDocumentBytes(file.bytes!, file.name);
                    } else if (file.readStream != null) {
                      final builder = BytesBuilder();
                      await for (final chunk in file.readStream!) {
                        builder.add(chunk);
                      }
                      final bytes = builder.takeBytes();
                      if (bytes.isEmpty) {
                        throw Exception('Dosya okunamadı.');
                      }
                      await repo.uploadDocumentBytes(bytes, file.name);
                    } else {
                      throw Exception('Dosya okunamadı.');
                    }

                    ref.invalidate(documentsProvider);
                    if (parentContext.mounted) {
                      ScaffoldMessenger.of(parentContext).showSnackBar(
                        SnackBar(
                          content: Text(
                            AppStrings.getDocProcessingNotice(locale),
                          ),
                        ),
                      );
                    }
                  } else if (parentContext.mounted) {
                    ScaffoldMessenger.of(parentContext).showSnackBar(
                      const SnackBar(content: Text('Dosya seçilmedi.')),
                    );
                  }
                } catch (e) {
                  if (parentContext.mounted) {
                    ScaffoldMessenger.of(
                      parentContext,
                    ).showSnackBar(SnackBar(content: Text('Hata: $e')));
                  }
                }
              },
            ),
            const SizedBox(height: 16),
            _UploadOptionTile(
              icon: Icons.camera_alt_rounded,
              title: AppStrings.getTakePhoto(locale),
              subtitle: AppStrings.getTakePhotoSubtitle(locale),
              color: const Color(0xFFEC4899),
              onTap: () async {
                Navigator.pop(sheetContext);
                await Future<void>.delayed(const Duration(milliseconds: 150));
                try {
                  final picker = ImagePicker();
                  final XFile? photo = await picker.pickImage(
                    source: ImageSource.camera,
                  );
                  if (photo != null) {
                    File file = File(photo.path);
                    await ref
                        .read(apiDocumentRepositoryProvider)
                        .uploadDocument(file, title: 'Kamera Görüntüsü');
                    ref.invalidate(documentsProvider);
                    if (parentContext.mounted) {
                      ScaffoldMessenger.of(parentContext).showSnackBar(
                        SnackBar(
                          content: Text(
                            AppStrings.getDocProcessingNotice(locale),
                          ),
                        ),
                      );
                    }
                  } else if (parentContext.mounted) {
                    ScaffoldMessenger.of(parentContext).showSnackBar(
                      const SnackBar(content: Text('Fotoğraf çekilmedi.')),
                    );
                  }
                } catch (e) {
                  if (parentContext.mounted) {
                    ScaffoldMessenger.of(
                      parentContext,
                    ).showSnackBar(SnackBar(content: Text('Hata: $e')));
                  }
                }
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      );
    },
  );
}

class _UploadOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _UploadOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: color.withValues(alpha: 0.2)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, color: color, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
