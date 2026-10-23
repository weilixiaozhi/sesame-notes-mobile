/// 阅读文件使用固定打印规格；PDF 与 Word 共用，不随应用深色模式或系统字号变化。
abstract final class MemoDocumentStyle {
  static const fontFamily = 'Noto Sans SC';
  static const fontAsset = 'assets/memos/NotoSansSC.ttf';
  static const emojiAsset = 'assets/memos/NotoEmoji.ttf';
  // 打印尺寸单位为 point；Word 的字号为半 point，段落尺寸为 twip。
  static const bodySize = 11.0;
  static const headingSizes = [22.0, 18.0, 14.0];
  static const lineHeight = 1.5;
  static const paragraphSpacing = bodySize / 2;
  static const pageMargin = 48.0;
  static const indentEm = 2.0;
  static const indent = bodySize * indentEm;
  static const listHanging = 12.0;
  static const boldStroke = 0.2;
  static const textColor = '000000';
}
