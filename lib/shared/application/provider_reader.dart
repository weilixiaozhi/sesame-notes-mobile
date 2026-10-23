import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 用例所需的只读依赖解析能力，可由应用容器或测试容器注入。
typedef ProviderReader = T Function<T>(ProviderListenable<T> provider);

/// 依赖解析器属于应用容器，异步用例不会捕获页面的生命周期对象。
final applicationReaderProvider = Provider<ProviderReader>((ref) => ref.read);
