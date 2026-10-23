import 'package:sesame_notes/providers/product_analytics_providers.dart';
import 'package:sesame_notes/domain/analytics/product_analytics_actions.dart';
import 'package:sesame_notes/features/fitness/application/fitness_actions.dart';
import 'package:sesame_notes/utils/text_validation.dart';
import '../../../data/models/private_book.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sesame_notes/data/models.dart';
import 'package:sesame_notes/domain/fitness/fitness_rules.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/features/fitness/application/fitness_catalog_provider.dart';
import 'package:sesame_notes/shared/widgets/app_form_section.dart';
import 'package:sesame_notes/shared/widgets/widgets.dart';
import 'package:sesame_notes/theme/dimens.dart';
import '../application/fitness_providers.dart';
import 'fitness_exercise_editing.dart';
import 'widgets/fitness_exercise_editor.dart';
import 'widgets/fitness_widgets.dart';
import 'widgets/fitness_rest_settings.dart';
import 'widgets/fitness_session_summary.dart';
import 'widgets/fitness_editor_footer.dart';
import 'widgets/fitness_set_keyboard.dart';

class FitnessTemplateEditPage extends ConsumerStatefulWidget {
  const FitnessTemplateEditPage({super.key});
  @override
  ConsumerState<FitnessTemplateEditPage> createState() =>
      _FitnessTemplateEditPageState();
}

class _FitnessTemplateEditPageState
    extends ConsumerState<FitnessTemplateEditPage> {
  final _keyboard = FitnessKeyboardController();
  @override
  void initState() {
    super.initState();
    _keyboard.addListener(_keyboardChanged);
  }

  void _keyboardChanged() {
    if (mounted) setState(() {});
  }

  FitnessTemplate _draft = const FitnessTemplate(name: '');
  late final _name = TextEditingController(text: _draft.name);
  final _form = GlobalKey<FormState>();
  bool _saving = false;
  bool _editingExercises = false;
  final _editingPreferences = FitnessEditingPreferences();
  PrivateBookTarget? _owner;

  @override
  void dispose() {
    _keyboard.dispose();
    _name.dispose();
    super.dispose();
  }

  /// 新建模板由父页面持有草稿，目录重载期间仍保留原编辑会话。
  Future<bool> _editExercises(FitnessExerciseEditIntent intent) async {
    if (_editingExercises || _saving || _owner == null) return false;
    final target = _owner!;
    final draftId = _draft.id;
    _keyboard.close();
    setState(() => _editingExercises = true);
    var changed = false;
    try {
      await editFitnessExercises(
        context,
        ref,
        target: target,
        intent: intent,
        readCurrentExercises: () =>
            _draft.id == draftId ? _draft.exercises : null,
        onChanged: (result) => setState(() {
          _editingPreferences.accept(target, result.confirmedPreferences);
          _draft = _draft.copyWith(exercises: result.exercises);
          changed = true;
        }),
      );
    } finally {
      if (mounted) setState(() => _editingExercises = false);
    }
    return changed;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final repo = ref.watch(fitnessActionsProvider);
    _owner ??= repo.target;
    if (matchesPrivateBookTarget(_owner!, repo.target)) _owner = repo.target;
    if (!matchesPrivateBookTarget(_owner!, repo.target)) {
      _editingPreferences.clear();
      return Scaffold(
        body: Column(
          children: [
            PrimaryHeader(title: l.fitnessTemplates, showBack: true),
            Expanded(child: AppEmpty(text: l.fitnessLoadFailed)),
          ],
        ),
      );
    }
    final catalog = ref.watch(fitnessCatalogProvider);
    final preferences = ref.watch(fitnessPreferencesProvider);
    return PopScope(
      canPop: !_keyboard.isOpen && !_saving && !_editingExercises,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _keyboard.isOpen) _keyboard.close();
      },
      child: Scaffold(
        body: AbsorbPointer(
          absorbing: _saving || _editingExercises,
          child: Column(
            children: [
              PrimaryHeader(
                title: l.fitnessNewTemplate,
                showBack: true,
                actions: [
                  HeaderTextAction(
                    label: l.commonSave,
                    onPressed: () async {
                      if (_saving) return;
                      final analyticsContext = ref
                          .read(productAnalyticsControllerProvider)
                          .beginFlow();
                      final completed = ref
                          .read(productAnalyticsControllerProvider)
                          .captureCompletion(
                            pageId: 'fitness.templates.edit',
                            context: analyticsContext,
                          );
                      ref
                          .read(productAnalyticsControllerProvider)
                          .trackAction(
                            pageId: 'fitness.templates.edit',
                            action: ProductAction.fitnessTemplateSaveClick,
                            context: analyticsContext,
                          );
                      if (_form.currentState?.validate() != true ||
                          _draft.exercises.isEmpty) {
                        showToast(context, l.fitnessInvalidForm);
                        return;
                      }
                      setState(() => _saving = true);
                      final ok = await fitnessRun(context, () async {
                        await repo.saveTemplate(
                          _draft.copyWith(name: normalizeName(_name.text)),
                        );
                      });
                      if (ok) completed(ProductAction.fitnessTemplateSaved);
                      if (!mounted || !context.mounted) return;
                      setState(() => _saving = false);
                      if (ok) {
                        Navigator.pop(context);
                      }
                    },
                  ),
                ],
              ),
              Expanded(
                child: catalog.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, _) => AppLoadError(
                    message: l.fitnessLoadFailed,
                    onRetry: () => ref.invalidate(fitnessCatalogProvider),
                  ),
                  data: (definitions) => preferences.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (_, _) => AppLoadError(
                      message: l.fitnessLoadFailed,
                      onRetry: () => ref.invalidate(fitnessPreferencesProvider),
                    ),
                    data: (prefs) {
                      final editor = FitnessExerciseEditor(
                        keyboard: _keyboard,
                        onRest: (e) =>
                            showFitnessRestSettings(context, ref, [e]),
                        onReplaceRequested: (id) =>
                            _editExercises(ReplaceFitnessExercise(id)),
                        onDeleteRequested: (id) =>
                            _editExercises(DeleteFitnessExercise(id)),
                        onWeightModeRequested: (id, enabled) => _editExercises(
                          SetFitnessExerciseWeightMode(id, enabled),
                        ),
                        exercises: _draft.exercises,
                        catalog: definitions,
                        preferences: _editingPreferences.resolve(
                          repo.target,
                          prefs,
                        ),
                        onChanged: (values) => setState(
                          () => _draft = _draft.copyWith(exercises: values),
                        ),
                      );
                      return Column(
                        children: [
                          Expanded(
                            child: Form(
                              key: _form,
                              child: CustomScrollView(
                                slivers: [
                                  SliverPadding(
                                    padding: const EdgeInsets.all(
                                      AppDimens.p16,
                                    ),
                                    sliver: SliverMainAxisGroup(
                                      slivers: [
                                        SliverToBoxAdapter(
                                          child: Column(
                                            children: [
                                              AppFormSection(
                                                title: l.fitnessName,
                                                child: TextFormField(
                                                  controller: _name,
                                                  decoration: InputDecoration(
                                                    labelText: l.fitnessName,
                                                  ),
                                                  validator: (value) =>
                                                      !fitnessValidName(
                                                        (value ?? '').trim(),
                                                      )
                                                      ? l.fitnessInvalidForm
                                                      : null,
                                                ),
                                              ),
                                              FitnessSessionSummary(
                                                exercises: _draft.exercises,
                                              ),
                                            ],
                                          ),
                                        ),
                                        editor,
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          FitnessEditorFooter(
                            keyboard: _keyboard,
                            showStart: false,
                            onRest: _draft.exercises.isEmpty
                                ? null
                                : () => showFitnessRestSettings(
                                    context,
                                    ref,
                                    _draft.exercises,
                                  ),
                            onAdd: _editingExercises
                                ? null
                                : () => _editExercises(
                                    const AddFitnessExercises(),
                                  ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
