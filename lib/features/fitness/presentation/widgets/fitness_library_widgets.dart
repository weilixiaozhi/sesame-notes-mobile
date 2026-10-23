import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/models/fitness.dart';
import 'package:sesame_notes/features/fitness/application/fitness_providers.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/widgets/widgets.dart';
import 'package:sesame_notes/theme/typography.dart';

/// 当前空间中来自同一官方条目的用户副本。
List<FitnessTemplate> fitnessCopiesOfOrigin(
  List<FitnessTemplate> templates,
  String officialId,
) => templates
    .where((template) => template.catalogOrigin?.itemId == officialId)
    .toList();

/// 同一官方来源最近修改的一份副本；没有副本时返回 null。
FitnessTemplate? fitnessLatestCopy(
  List<FitnessTemplate> templates,
  String officialId,
) {
  final copies = fitnessCopiesOfOrigin(templates, officialId)
    ..sort(
      (left, right) => (right.updatedAt ?? DateTime(0)).compareTo(
        left.updatedAt ?? DateTime(0),
      ),
    );
  return copies.firstOrNull;
}

/// 读取当前空间的用户模板；订阅未就绪时等待首个快照，读取失败返回空集合。
Future<List<FitnessTemplate>> loadUserTemplates(WidgetRef ref) async {
  try {
    return await ref.read(fitnessTemplatesProvider.future);
  } catch (error, stackTrace) {
    logger.warning('FitnessLibrary', '读取用户模板副本失败：$error\n$stackTrace');
    return const [];
  }
}

/// 逐条列出官方来源的全部副本，默认选择最近修改的一份，也可单独选择新建。
Future<Map<String, String>?> chooseTemplateCopies(
  BuildContext context, {
  required String title,
  required Map<String, String> labels,
  required Map<String, List<FitnessTemplate>> candidates,
}) async {
  final l = AppLocalizations.of(context);
  final selected = <String, String>{
    for (final entry in candidates.entries)
      if (fitnessLatestCopy(entry.value, entry.key) case final copy?)
        entry.key: copy.id,
  };
  return AppDialog.select<Map<String, String>>(
    context,
    title: title,
    content: StatefulBuilder(
      builder: (dialogContext, setState) => SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final entry in candidates.entries) ...[
              // 每个来源单独一行标题：一个计划可能引用多个官方模板。
              Text(
                l.fitnessReuseForTemplate(labels[entry.key] ?? ''),
                style: AppTextTokens.label(dialogContext),
              ),
              RadioGroup<String>(
                groupValue: selected[entry.key] ?? '',
                onChanged: (value) => setState(() {
                  if (value == null || value.isEmpty) {
                    selected.remove(entry.key);
                  } else {
                    selected[entry.key] = value;
                  }
                }),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final copy in entry.value)
                      AppRadioTile<String>.grouped(
                        value: copy.id,
                        title: copy.name,
                      ),
                    AppRadioTile<String>.grouped(
                      value: '',
                      title: l.fitnessCreateCopies,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    ),
    onConfirm: () => Map<String, String>.from(selected),
  );
}
