import 'package:sesame_notes/features/fitness/application/fitness_actions.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/shared/providers/fitness_builtin_catalog_provider.dart';
import 'package:sesame_notes/data/models/fitness_catalog.dart';
import 'package:sesame_notes/data/models/fitness_catalog_snapshot.dart';
import 'package:sesame_notes/utils/text_validation.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/fitness_custom_exercise.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/app_form_section.dart';
import '../../../shared/widgets/app_icon_picker.dart';
import '../../../shared/widgets/app_radio_tile.dart';
import '../../../shared/widgets/overlay_keyboard_guard.dart';
import '../../../shared/widgets/widgets.dart';
import '../../../theme/dimens.dart';
import '../../../theme/icons/app_icons.dart';
import 'package:sesame_notes/domain/fitness/fitness_rules.dart';
import 'widgets/fitness_exercise_media.dart';
import 'widgets/fitness_widgets.dart';
import 'package:sesame_notes/theme/typography.dart';

class FitnessCustomExerciseEditPage extends ConsumerStatefulWidget {
  const FitnessCustomExerciseEditPage({super.key, this.exercise});
  final FitnessCustomExercise? exercise;
  @override
  ConsumerState<FitnessCustomExerciseEditPage> createState() => _EditState();
}

class _EditState extends ConsumerState<FitnessCustomExerciseEditPage> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.exercise?.name ?? '');
  late final _id = widget.exercise?.id ?? 'custom:${const Uuid().v4()}';
  late String _part = widget.exercise?.bodyPart ?? '';
  late String _equipment = widget.exercise?.equipment ?? '';
  late String _icon = widget.exercise?.icon ?? 'dumbbell';
  late String? _image = widget.exercise?.image;
  bool _saving = false;
  bool _picking = false;
  late final FitnessActions _repository;
  @override
  void initState() {
    super.initState();
    _repository = ref.read(fitnessActionsProvider);
  }

  FitnessCustomExercise get _value => FitnessCustomExercise(
    id: _id,
    name: _name.text,
    bodyPart: _part,
    equipment: _equipment,
    icon: _icon,
    image: _image,
  );
  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  /// 校验后保存自定义动作，同一操作完成前不重复写入。
  Future<void> _save() async {
    if (_saving || _picking) return;
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await _repository.saveCustomExercise(_value);
      if (mounted) Navigator.pop(context, _id);
    } catch (error, stackTrace) {
      logger.error('FitnessCustomExerciseEdit', '保存自定义动作失败', error, stackTrace);
      if (mounted) {
        final l = AppLocalizations.of(context);
        showToast(
          context,
          error is FitnessValidationException &&
                  error.code == 'FITNESS_CUSTOM_LIMIT'
              ? l.fitnessCustomLimit
              : l.commonOperationFailed,
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickImage() async {
    if (_picking) return;
    setState(() => _picking = true);
    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 256,
        maxHeight: 256,
        imageQuality: 60,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      if (bytes.length > 48 * 1024) {
        showToast(
          context,
          AppLocalizations.of(context).fitnessCustomImageTooLarge,
        );
        return;
      }
      final decoded = await decodeImageFromList(bytes);
      decoded.dispose();
      if (mounted) setState(() => _image = base64Encode(bytes));
    } catch (_) {
      if (mounted) {
        showToast(context, AppLocalizations.of(context).commonOperationFailed);
      }
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  /// 选择器仅列出当前有效分类，已有删除分类仍保留名称与原值用于历史编辑。
  Widget _selection(
    String title,
    String value,
    Map<String, String> options,
    ValueChanged<String> change,
    String currentLabel,
  ) {
    final l = AppLocalizations.of(context);
    return AppFormSection(
      title: title,
      child: FormField<String>(
        validator: (_) => value.isEmpty ? l.fitnessCustomRequired : null,
        builder: (field) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSelectionField(
              title: value.isEmpty ? title : currentLabel,
              isPlaceholder: value.isEmpty,
              enabled: !_saving && options.isNotEmpty,
              onTap: () async {
                try {
                  await prepareForOverlay();
                  if (!mounted) return;
                  final selected = await showAppRadioSheet<String>(
                    context,
                    title: title,
                    selected: value,
                    confirmSelection: false,
                    height: MediaQuery.textScalerOf(
                      context,
                    ).scale(AppDimens.filterSheetHeight),
                    options: options,
                  );
                  if (selected != null && mounted) {
                    setState(() => change(selected));
                  }
                } catch (error, stackTrace) {
                  logger.error(
                    'FitnessCustomExerciseEdit',
                    '打开动作分类选择失败',
                    error,
                    stackTrace,
                  );
                  if (mounted) showToast(context, l.commonOperationFailed);
                }
              },
            ),
            if (field.hasError)
              Text(
                field.errorText!,
                style: AppTextTokens.body(
                  context,
                ).copyWith(color: Theme.of(context).colorScheme.error),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final catalog = ref.watch(fitnessCatalogSnapshotProvider);
    final taxonomies = catalog.value?.taxonomies;
    return Scaffold(
      body: Column(
        children: [
          PrimaryHeader(
            title: widget.exercise == null
                ? l.fitnessCustomCreate
                : l.fitnessCustomEdit,
            showBack: true,
          ),
          Expanded(
            child: Form(
              key: _form,
              child: ListView(
                padding: const EdgeInsets.all(AppDimens.p16),
                children: [
                  AppFormSection(
                    title: l.fitnessCustomName,
                    child: TextFormField(
                      controller: _name,
                      enabled: !_saving,
                      maxLength: maxNameLength,
                      decoration: InputDecoration(
                        hintText: l.fitnessCustomName,
                      ),
                      validator: (value) => fitnessValidName(value ?? '')
                          ? null
                          : l.fitnessCustomRequired,
                    ),
                  ),
                  if (catalog.hasError)
                    AppLoadError(
                      message: l.fitnessLoadFailed,
                      onRetry: () =>
                          ref.invalidate(fitnessCatalogSnapshotProvider),
                    ),
                  _selection(
                    l.fitnessBodyPart,
                    _part,
                    {
                      for (final id in fitnessSelectableTaxonomyIds(taxonomies))
                        id: fitnessCatalogLabel(l, id, taxonomies: taxonomies),
                    },
                    (v) => _part = v,
                    fitnessCatalogLabel(l, _part, taxonomies: taxonomies),
                  ),
                  _selection(
                    l.fitnessEquipment,
                    _equipment,
                    {
                      for (final id in fitnessSelectableTaxonomyIds(
                        taxonomies,
                        isEquipment: true,
                      ))
                        id: fitnessCatalogLabel(
                          l,
                          id,
                          taxonomies: taxonomies,
                          isEquipment: true,
                        ),
                    },
                    (v) => _equipment = v,
                    fitnessCatalogLabel(
                      l,
                      _equipment,
                      taxonomies: taxonomies,
                      isEquipment: true,
                    ),
                  ),
                  IgnorePointer(
                    ignoring: _saving,
                    child: AppIconPicker(
                      selectedIcon: _image == null ? _icon : null,
                      onIconSelected: (icon) => setState(() {
                        _icon = icon;
                        _image = null;
                      }),
                      preview: _image == null
                          ? null
                          : Align(
                              alignment: Alignment.centerLeft,
                              child: SizedBox(
                                width: AppDimens.icon40,
                                height: AppDimens.icon40,
                                child: FitnessExerciseMedia(
                                  definition: _value.definition,
                                ),
                              ),
                            ),
                      trailing: IconButton(
                        icon: const Icon(AppIcons.upload),
                        tooltip: l.fitnessCustomUpload,
                        onPressed: _saving || _picking ? null : _pickImage,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          AppEditorFooter(
            label: l.commonSave,
            busy: _saving,
            onPressed: _picking || !catalog.hasValue ? null : _save,
          ),
        ],
      ),
    );
  }
}
