import 'package:flutter/material.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sesame_notes/data/models.dart';
import 'package:sesame_notes/data/models/fitness_catalog_snapshot.dart';
import 'package:sesame_notes/shared/providers/fitness_builtin_catalog_provider.dart';
import 'package:sesame_notes/domain/fitness/fitness_rules.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/navigation/route_consts.dart';
import 'package:sesame_notes/features/fitness/application/fitness_catalog_provider.dart';
import 'package:sesame_notes/shared/widgets/app_radio_tile.dart';
import 'package:sesame_notes/shared/widgets/widgets.dart';
import 'package:sesame_notes/shared/widgets/app_status_banner.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';
import 'package:sesame_notes/theme/typography.dart';
import '../application/fitness_providers.dart';
import 'widgets/fitness_exercise_media.dart';
import 'widgets/fitness_widgets.dart';

class FitnessExercisesPage extends ConsumerStatefulWidget {
  const FitnessExercisesPage({super.key, this.mode = 'browse'});
  final String mode;
  @override
  ConsumerState<FitnessExercisesPage> createState() =>
      _FitnessExercisesPageState();
}

class _FitnessExercisesPageState extends ConsumerState<FitnessExercisesPage> {
  String _search = '', _part = '', _equipment = '', _shortcut = '';
  final _selected = <String>{};
  final _scroll = ScrollController();
  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final catalog = ref.watch(fitnessCatalogProvider);
    final taxonomies = ref.watch(fitnessTaxonomiesProvider);
    final preferences = ref.watch(fitnessPreferencesProvider);
    final workouts = ref.watch(fitnessRecentExerciseIdsProvider);
    final pinned = preferences.value?.pinnedExerciseIds ?? const <String>[];
    final recent = workouts.value ?? const <String>[];
    return Scaffold(
      bottomNavigationBar: widget.mode == 'browse'
          ? null
          : SafeArea(
              top: false,
              minimum: const EdgeInsets.all(AppDimens.p16),
              child: AppPrimaryButton(
                fullWidth: false,
                label: '${l.commonConfirm} (${_selected.length})',
                onPressed: _selected.isEmpty
                    ? null
                    : () => Navigator.pop(context, _selected.toList()),
              ),
            ),
      body: Column(
        children: [
          PrimaryHeader(
            title: l.fitnessExercises,
            showBack: true,
            actions: [
              Expanded(
                flex: 2,
                child: TextField(
                  style: AppTextTokens.label(context),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.p8,
                      vertical: AppDimens.p4,
                    ),
                    hintStyle: AppTextTokens.label(context),
                    prefixIconConstraints: BoxConstraints(
                      minWidth: AppDimens.p32,
                      minHeight: PrimaryHeader.titleRowMinHeight(context),
                    ),
                    prefixIcon: const Icon(
                      AppIcons.search,
                      size: AppDimens.icon16,
                    ),
                    hintText: l.fitnessSearch,
                  ),
                  onChanged: (value) => setState(() => _search = value),
                ),
              ),
            ],
          ),
          if (preferences.hasError || workouts.hasError)
            AppStatusBanner(
              icon: AppIcons.warning,
              message: l.fitnessLoadFailed,
              onTap: () {
                ref.invalidate(fitnessPreferencesProvider);
                ref.invalidate(fitnessRecentExerciseIdsProvider);
              },
            ),
          Expanded(
            child: catalog.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => AppLoadError(
                message: l.fitnessLoadFailed,
                onRetry: () => ref.invalidate(fitnessCatalogProvider),
              ),
              data: (all) {
                final parts = <String>{
                  'custom',
                  ...fitnessSelectableTaxonomyIds(taxonomies),
                  ...all
                      .map((e) => e.bodyPart)
                      .where(
                        (id) => taxonomies?.bodyParts[id]?.isDeleted != true,
                      ),
                };
                final equipment = <String>{
                  ...fitnessSelectableTaxonomyIds(
                    taxonomies,
                    isEquipment: true,
                  ),
                  ...all
                      .map((e) => e.equipment)
                      .where(
                        (id) => taxonomies?.equipment[id]?.isDeleted != true,
                      ),
                };
                // 后台删除当前筛选项时回到全部，避免菜单已移除但隐藏筛选仍生效。
                final selectedPart = parts.contains(_part) ? _part : '';
                final selectedEquipment = equipment.contains(_equipment)
                    ? _equipment
                    : '';
                // 置顶动作在所有筛选下都排最前，其余保持原有的排列口径。
                final found = fitnessSortExercises(
                  all.where(
                    (e) =>
                        e.isEnabled &&
                        e.custom?.deleted != true &&
                        e.matchesSearch(_search) &&
                        (selectedPart.isEmpty ||
                            (selectedPart == 'custom'
                                ? e.custom != null
                                : e.bodyPart == selectedPart)) &&
                        (selectedEquipment.isEmpty ||
                            e.equipment == selectedEquipment) &&
                        (_shortcut != 'custom' || e.custom != null) &&
                        (_shortcut != 'pinned' || pinned.contains(e.id)) &&
                        (_shortcut != 'recent' || recent.contains(e.id)),
                  ),
                  catalog: all,
                  pinnedIds: pinned,
                  recentOrder: _shortcut == 'recent' ? recent : null,
                );
                // 自定义筛选下内容区常驻新建入口，与筛选结果同时出现。
                final customActive =
                    _shortcut == 'custom' || selectedPart == 'custom';
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimens.p12,
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final shortcutLabels = {
                            '': l.fitnessAll,
                            'pinned': l.fitnessPinned,
                            'recent': l.fitnessRecent,
                            'custom': l.fitnessCustom,
                          };
                          final painter = TextPainter(
                            textDirection: Directionality.of(context),
                            textScaler: MediaQuery.textScalerOf(context),
                            maxLines: 1,
                          );
                          var labelWidth = 0.0;
                          for (final label in shortcutLabels.values) {
                            painter.text = TextSpan(
                              text: label,
                              style: AppTextTokens.caption(context),
                            );
                            painter.layout();
                            if (painter.width > labelWidth) {
                              labelWidth = painter.width;
                            }
                          }
                          painter.dispose();
                          final shortcuts = Row(
                            spacing: AppDimens.p4,
                            children: [
                              for (final entry in shortcutLabels.entries)
                                ChoiceChip(
                                  label: SizedBox(
                                    width: labelWidth.ceilToDouble(),
                                    child: Text(
                                      entry.value,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  labelStyle: AppTextTokens.chipLabel(
                                    context,
                                    compact: true,
                                  ),
                                  labelPadding: const EdgeInsets.symmetric(
                                    horizontal: AppDimens.p4,
                                  ),
                                  padding: EdgeInsets.zero,
                                  visualDensity: VisualDensity.compact,
                                  showCheckmark: false,
                                  selected: _shortcut == entry.key,
                                  onSelected: (_) =>
                                      setState(() => _shortcut = entry.key),
                                ),
                            ],
                          );
                          final filters = Wrap(
                            alignment: WrapAlignment.end,
                            spacing: AppDimens.p12,
                            children: [
                              _filter(l.fitnessEquipment, selectedEquipment, {
                                for (final id in equipment)
                                  id: fitnessCatalogLabel(
                                    l,
                                    id,
                                    taxonomies: taxonomies,
                                    isEquipment: true,
                                  ),
                              }, (value) => setState(() => _equipment = value)),
                            ],
                          );
                          // 同一工具栏保持左右分组；大字号或长筛选值可横向滚动。
                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minWidth: constraints.maxWidth,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  shortcuts,
                                  const SizedBox(width: AppDimens.p8),
                                  filters,
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final textScaler = MediaQuery.textScalerOf(context);
                          final sidebarWidth = textScaler.scale(
                            AppDimens.exerciseSidebarWidth,
                          );
                          final showSidebar =
                              constraints.maxWidth >=
                              sidebarWidth +
                                  textScaler.scale(
                                    AppDimens.exerciseCardMinWidth,
                                  ) +
                                  AppDimens.p8 * 3;
                          final contentWidth =
                              constraints.maxWidth -
                              (showSidebar ? sidebarWidth : 0);
                          return Column(
                            children: [
                              if (!showSidebar)
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: _filter(
                                    l.fitnessBodyPart,
                                    selectedPart,
                                    {
                                      for (final part in parts)
                                        part: part == 'custom'
                                            ? l.fitnessCustom
                                            : fitnessCatalogLabel(
                                                l,
                                                part,
                                                taxonomies: taxonomies,
                                              ),
                                    },
                                    (value) => setState(() => _part = value),
                                  ),
                                ),
                              Row(
                                children: [
                                  if (showSidebar)
                                    SizedBox(
                                      width: sidebarWidth,
                                      child: ListTile(
                                        dense: true,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: AppDimens.p12,
                                            ),
                                        selected: selectedPart.isEmpty,
                                        selectedTileColor:
                                            AppTokens.surfaceInput(context),
                                        title: Text(
                                          l.fitnessAll,
                                          style: AppTextTokens.label(context)
                                              .copyWith(
                                                color: selectedPart.isEmpty
                                                    ? AppTokens.primary(context)
                                                    : null,
                                                fontWeight: selectedPart.isEmpty
                                                    ? FontWeight.w600
                                                    : null,
                                              ),
                                        ),
                                        onTap: () => setState(() => _part = ''),
                                      ),
                                    ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppDimens.p12,
                                        vertical: AppDimens.p8,
                                      ),
                                      child: Text(
                                        l.fitnessExerciseCount(found.length),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTextTokens.label(context),
                                      ),
                                    ),
                                  ),
                                  if (customActive)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        right: AppDimens.p12,
                                      ),
                                      child: TextButton.icon(
                                        onPressed: _createCustom,
                                        icon: const Icon(
                                          AppIcons.add,
                                          size: AppDimens.icon16,
                                        ),
                                        label: Text(l.commonAdd),
                                        style: TextButton.styleFrom(
                                          textStyle: AppTextTokens.label(
                                            context,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: AppDimens.p8,
                                          ),
                                          visualDensity: VisualDensity.compact,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              Expanded(
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    if (showSidebar)
                                      SizedBox(
                                        width: sidebarWidth,
                                        child: ListView(
                                          padding: EdgeInsets.zero,
                                          children: [
                                            for (final part in parts)
                                              ListTile(
                                                dense: true,
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: AppDimens.p12,
                                                    ),
                                                selected: selectedPart == part,
                                                selectedTileColor:
                                                    AppTokens.surfaceInput(
                                                      context,
                                                    ),
                                                title: Text(
                                                  part == 'custom'
                                                      ? l.fitnessCustom
                                                      : fitnessCatalogLabel(
                                                          l,
                                                          part,
                                                          taxonomies:
                                                              taxonomies,
                                                        ),
                                                  style:
                                                      AppTextTokens.label(
                                                        context,
                                                      ).copyWith(
                                                        color:
                                                            selectedPart == part
                                                            ? AppTokens.primary(
                                                                context,
                                                              )
                                                            : null,
                                                        fontWeight:
                                                            selectedPart == part
                                                            ? FontWeight.w600
                                                            : null,
                                                      ),
                                                ),
                                                onTap: () => setState(
                                                  () => _part = part,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    Expanded(
                                      child: found.isEmpty
                                          ? AppEmpty(text: l.fitnessNoExercises)
                                          : GridView.builder(
                                              controller: _scroll,
                                              padding: const EdgeInsets.all(
                                                AppDimens.p8,
                                              ),
                                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount:
                                                    ((contentWidth -
                                                                AppDimens.p8) /
                                                            (textScaler.scale(
                                                                  AppDimens
                                                                      .exerciseCardMinWidth,
                                                                ) +
                                                                AppDimens.p8))
                                                        .floor()
                                                        .clamp(1, 3),
                                                mainAxisSpacing: AppDimens.p8,
                                                crossAxisSpacing: AppDimens.p8,
                                                mainAxisExtent:
                                                    AppDimens
                                                        .exerciseCardMinHeight +
                                                    textScaler.scale(
                                                      AppDimens
                                                          .exerciseCardTextHeight,
                                                    ),
                                              ),
                                              itemCount: found.length,
                                              itemBuilder: (context, index) =>
                                                  _card(
                                                    context,
                                                    found[index],
                                                    pinned.contains(
                                                      found[index].id,
                                                    ),
                                                  ),
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 打开自定义动作编辑页；目录与偏好由各自的流自动刷新。
  Future<void> _createCustom() =>
      context.pushNamed(Routes.fitnessCustomExerciseEdit);

  Widget _filter(
    String title,
    String selected,
    Map<String, String> options,
    ValueChanged<String> onSelected,
  ) {
    final l = AppLocalizations.of(context);
    return TextButton(
      style: TextButton.styleFrom(
        textStyle: AppTextTokens.caption(context),
        padding: const EdgeInsets.symmetric(horizontal: AppDimens.p4),
        visualDensity: VisualDensity.compact,
      ),
      onPressed: () async {
        final value = await showAppRadioSheet<String>(
          context,
          title: title,
          selected: selected,
          confirmSelection: false,
          height: MediaQuery.textScalerOf(
            context,
          ).scale(AppDimens.filterSheetHeight),
          options: {'': l.fitnessAll, ...options},
        );
        if (value != null && mounted) onSelected(value);
      },
      child: Text('$title: ${options[selected] ?? l.fitnessAll}'),
    );
  }

  Widget _card(
    BuildContext context,
    FitnessExerciseDefinition def,
    bool pinned,
  ) {
    final l = AppLocalizations.of(context);
    final name = fitnessExerciseName(context, def);
    final selected = _selected.contains(def.id);
    void activate() {
      if (widget.mode == 'browse') {
        context.pushNamed(Routes.fitnessExerciseDetail, extra: def.id);
        return;
      }
      setState(() {
        if (selected) {
          _selected.remove(def.id);
          return;
        }
        if (widget.mode == 'replace') _selected.clear();
        _selected.add(def.id);
      });
    }

    return Semantics(
      button: true,
      selected: widget.mode == 'browse' ? null : selected,
      child: SectionCard(
        margin: EdgeInsets.zero,
        padding: EdgeInsets.zero,
        selected: selected,
        onTap: activate,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppDimens.p8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Center(child: FitnessExerciseMedia(definition: def)),
                  ),
                  const SizedBox(height: AppDimens.p8),
                  Tooltip(
                    message: name,
                    child: SizedBox(
                      height: MediaQuery.textScalerOf(
                        context,
                      ).scale(AppDimens.exerciseCardTextHeight),
                      child: Center(
                        child: Text(
                          name,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextTokens.body(context),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (pinned)
              Positioned(
                top: AppDimens.p8,
                left: AppDimens.p8,
                child: Icon(
                  AppIcons.pin,
                  size: AppDimens.icon16,
                  semanticLabel: l.fitnessPinned,
                ),
              ),
            if (selected) const SelectableCardCheckBadge(),
          ],
        ),
      ),
    );
  }
}
