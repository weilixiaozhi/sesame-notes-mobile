import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../infrastructure/api/api_client_provider.dart';

/// 确认界面只读取身份代次；令牌轮换不撤销决定，同账号重新登录会撤销。
/// 复用会话层的权威代次，不在界面维护另一份账号状态。
final syncCenterSessionGenerationProvider = Provider<int>(
  (ref) => ref.watch(authIdentityGenerationProvider),
);
