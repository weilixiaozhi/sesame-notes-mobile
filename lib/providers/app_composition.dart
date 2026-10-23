import 'package:flutter_riverpod/misc.dart';
import 'package:sesame_notes/features/days/domain/day_date_rules.dart';
import 'package:sesame_notes/shared/providers/app_bootstrap_providers.dart';
import 'package:sesame_notes/shared/providers/day_repository_provider.dart';
import 'package:sesame_notes/shared/providers/default_book_actions_provider.dart';
import 'app_init_providers.dart';
import 'default_book_provisioner.dart';

/// 主程序与集成测试共用应用装配，底层端口只在此绑定业务实现。
List<Override> applicationOverrides() => [
  dayDefinitionValidatorProvider.overrideWithValue(
    const DayDateRules().validateAndProject,
  ),
  splashPreloadRunnerProvider.overrideWith(buildSplashPreloadRunner),
  defaultBookProvisionerProvider.overrideWith(DefaultBookProvisioner.new),
];
