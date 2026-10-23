/// 人体图的固定解剖区域独立于后台可维护的动作分类标识。
const fitnessAnatomyParts = {
  'chest',
  'neck',
  'shoulders',
  'upper arms',
  'lower arms',
  'waist',
  'upper legs',
  'lower legs',
  'back',
};

/// 由实际主训练肌群映射人体区域，动作分类改名或迁移不改变生理解剖归属。
String fitnessMuscleBodyPart(String muscle) => switch (muscle) {
  'pectorals' || 'serratus anterior' => 'chest',
  'levator scapulae' => 'neck',
  'delts' => 'shoulders',
  'biceps' || 'triceps' => 'upper arms',
  'forearms' => 'lower arms',
  'abs' => 'waist',
  'glutes' ||
  'adductors' ||
  'abductors' ||
  'hamstrings' ||
  'quads' => 'upper legs',
  'calves' => 'lower legs',
  'traps' || 'upper back' || 'lats' || 'spine' => 'back',
  _ => muscle,
};
