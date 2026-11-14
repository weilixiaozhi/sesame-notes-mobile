import 'package:sesame_notes/providers/product_analytics_providers.dart';
import 'package:sesame_notes/domain/analytics/product_analytics_actions.dart';
import 'package:sesame_notes/domain/analytics/product_analytics_context.dart';
import 'package:sesame_notes/shared/presentation/analytics/product_analytics_page_state.dart';
import 'package:sesame_notes/features/memos/application/memo_actions.dart';
import 'package:sesame_notes/shared/providers/memo_editor_session_provider.dart';
import 'package:sesame_notes/data/models/private_book.dart';
import 'package:sesame_notes/utils/text_validation.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../data/models/memo.dart';
import '../../../data/models/memo_delta.dart';
import '../../../data/models/memo_fields.dart';
import '../../../data/repositories/local/memo_media_repository.dart';
import '../../../data/services/memo_media_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/providers/account_state_provider.dart';
import '../../../shared/providers/memo_media_providers.dart';
import '../../../shared/widgets/app_sheet.dart';
import '../../../shared/widgets/app_primary_button.dart';
import '../../../shared/widgets/app_form_section.dart';
import '../../../shared/widgets/app_empty.dart';
import '../../../shared/widgets/primary_header.dart';
import '../../../shared/widgets/toast.dart';
import '../../../theme/dimens.dart';
import '../../../theme/colors.dart';
import '../../../theme/icons/app_icons.dart';
import '../../../theme/typography.dart';
import '../application/memo_draft.dart';
import '../application/memo_providers.dart';
import 'memo_editor_document.dart';
import 'memo_editor_styles.dart';
import 'memo_editor_surface.dart';
import 'memo_image_embed.dart';
import 'widgets/memo_history_buttons.dart';

/// 页面固定一个本子与 UUID；路由返回与后台保存共用同一个 flush。
class MemoEditorPage extends ConsumerStatefulWidget {
  final ProductAnalyticsContext? analyticsContext;
  final MemoBook book;
  final PrivateBookTarget target;
  final String entryId;
  final MemoEntry? entry;
  const MemoEditorPage({
    super.key,
    this.analyticsContext,
    required this.book,
    required this.target,
    required this.entryId,
    this.entry,
  });
  @override
  ConsumerState<MemoEditorPage> createState() => _MemoEditorPageState();
}

/// 卡片编辑器里的一行可增删字段；名称与取值各占一个输入框。
class _CardFieldRow {
  final label = TextEditingController();
  final value = TextEditingController();
  _CardFieldRow({String label = '', String value = ''}) {
    this.label.text = label;
    this.value.text = value;
  }
  void dispose() {
    label.dispose();
    value.dispose();
  }
}

/// 图片弹层的操作类型；比例值只在 resize 时携带。
enum _MemoImageAction { resize, save, cut, delete }

class _MemoEditorPageState extends ConsumerState<MemoEditorPage>
    with WidgetsBindingObserver {
  final _title = TextEditingController();
  final _fields = <_CardFieldRow>[];
  bool _fieldsReady = false;
  final _editorScrollState = MemoEditorScrollState();
  final _editorViewport = GlobalKey();
  late final QuillController _quill;
  late final MemoDraft _draft;
  late final MemoMediaService _media;

  /// 被剪切、等待移动到新光标位置的图片引用。
  String? _pendingImageValue;
  late final Set<Future<bool> Function()> _leaveGuards;
  StreamSubscription<DocChange>? _changes;
  bool _busy = false;
  bool _leave = false;
  bool _newCard = false;
  bool _creationRecorded = false;
  bool _explicitSaving = false;
  String _displayedNoteTitle = '';
  bool _saveFailed = false;
  late final ProductAnalyticsContext _analyticsContext;
  late final ProductAnalyticsPageState _analyticsPages;
  String? _analyticsRouteKey;
  final _analyticsPageOwner = Object();
  late ProductAnalyticsContext _lastEditContext;
  ProductAnalyticsContext? _explicitSaveContext;
  late bool _readOnly;
  late final DateTime _createdAt;
  bool get _card => widget.book.type == 'credentials';
  bool get _identityValid =>
      ref.read(currentAccountIdProvider) == widget.target.accountId &&
      ref.read(authSessionProvider.notifier).identityGeneration ==
          widget.target.generation;
  String get _draftKey => memoDraftKey(widget.target.accountId, widget.entryId);

  /// 编辑器实际可操作模式决定页面名称，保存后的正文属于详情访问。
  String get _analyticsPageId => _card
      ? 'credentials.editor'
      : _readOnly
      ? 'memos.detail'
      : 'memos.editor';

  @override
  void initState() {
    super.initState();
    _analyticsPages = ref.read(productAnalyticsPageStateProvider);
    _analyticsContext =
        widget.analyticsContext ??
        ref.read(productAnalyticsControllerProvider).captureContext();
    _lastEditContext = _analyticsContext;
    WidgetsBinding.instance.addObserver(this);
    final protected = ref.read(memoProtectedDraftsProvider)[_draftKey];
    final entry = protected ?? widget.entry;
    _readOnly = !_card && entry != null && protected == null;
    _createdAt = entry?.createdAt ?? DateTime.now().toUtc();
    _newCard = entry == null;
    _title.text = entry?.title ?? '';
    _title.addListener(_changed);
    for (final field in entry?.fields ?? const <MemoField>[]) {
      _addRow(_CardFieldRow(label: field.label, value: field.value));
    }
    _quill = MemoEditorController(
      readOnly: _readOnly,
      document: MemoEditorDocument.fromJson(
        _card || entry?.bodyJson == null
            ? [
                {
                  'insert': '\n',
                  'attributes': {'header': 1},
                },
              ]
            : (entry!.body as Map)['ops'] as List,
      ),
      onEditError: _showEditError,
      selection: const TextSelection.collapsed(offset: 0),
      // 固定依赖版本已验证此开关，外部粘贴只保留文字，避免引入未支持嵌入；
      // 空白笔记的一次性粘贴改按粘贴内容自身的格式铺开。
      config: QuillControllerConfig(
        // ignore: experimental_member_use
        clipboardConfig: QuillClipboardConfig(
          // ignore: experimental_member_use
          enableExternalRichPaste: false,
          // ignore: experimental_member_use
          onClipboardPaste: _pasteIntoBlankNote,
        ),
      ),
    );
    _displayedNoteTitle = _readNoteTitle();
    _media = ref.read(memoMediaServiceProvider);
    unawaited(_media.prepareEntry(widget.entryId, entry?.bodyJson));
    final repository = ref.read(memoActionsProvider);
    _draft = MemoDraft(
      automatic: !_card,
      save: (entry) async {
        final analyticsContext = _explicitSaveContext ?? _lastEditContext;
        final explicitSave = _explicitSaving;
        final completed = ref
            .read(productAnalyticsControllerProvider)
            .captureCompletion(
              pageId: _card ? 'credentials.editor' : 'memos.editor',
              context: analyticsContext,
            );
        await repository.saveEntry(entry, widget.target);
        // 正文已经持久化，随后回收不再被引用的图片，失败不影响保存结果。
        unawaited(
          _media.cleanupAfterSave(widget.entryId, entry.bodyJson ?? ''),
        );
        // 自动保存与显式保存共用持久化边界，新建只统计首个成功写入。
        final created = widget.entry == null && !_creationRecorded;
        if (!created && !explicitSave) return;
        if (created) {
          _creationRecorded = true;
        }
        completed(
          _card
              ? created
                    ? ProductAction.credentialsCreated
                    : ProductAction.credentialsSaved
              : created
              ? ProductAction.memosNoteCreated
              : ProductAction.memosNoteSaved,
        );
      },
      onSnapshot: (value) => ref.read(memoProtectedDraftsProvider.notifier).set(
        {...ref.read(memoProtectedDraftsProvider), _draftKey: value},
      ),
    );
    _draft.addListener(_saveChanged);
    _leaveGuards = ref.read(memoEditorLeaveGuardsProvider)..add(_prepareLeave);
    _changes = _quill.document.changes.listen((_) {
      _restoreBlankTitle();
      _changed();
    });
    if (protected != null) _draft.edit(protected);
    ref.listenManual(authSessionProvider, (_, _) {
      if (!_identityValid && _draft.dirty) _draft.value;
    });
  }

  /// 将路由实例与实际页面模式绑定，保护草稿也按真实可编辑状态采集。
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    try {
      _analyticsRouteKey ??= GoRouterState.of(context).pageKey.value;
      _publishAnalyticsPage();
    } catch (error, stackTrace) {
      logger.error(
        'ProductAnalytics',
        '页面统计暂不可用，备忘录功能不受影响',
        error.runtimeType,
        stackTrace,
      );
    }
    // 新建卡片默认给出常用字段；已保存的卡片与草稿按自身字段还原。
    if (_fieldsReady || !_card || !_newCard) return;
    _fieldsReady = true;
    final l = AppLocalizations.of(context);
    for (final label in [
      l.memoAccount,
      l.memoPassword,
      l.memoPhone,
      l.memoEmail,
    ]) {
      _addRow(_CardFieldRow(label: label));
    }
  }

  /// 查看与编辑切换通过同一监听链路计数，动作来源与页面访问保持一致。
  void _publishAnalyticsPage() {
    final routeKey = _analyticsRouteKey;
    if (routeKey != null) {
      _analyticsPages.show(
        routeKey,
        _analyticsPageId,
        owner: _analyticsPageOwner,
      );
    }
  }

  /// 字段行的监听与插入集中一处，新增与还原共用同一份注册顺序。
  void _addRow(_CardFieldRow row) {
    _fields.add(row);
    row.label.addListener(_changed);
    row.value.addListener(_changed);
  }

  void _addField() {
    if (_fields.length >= memoFieldLimit) return;
    setState(() {
      _addRow(_CardFieldRow(label: AppLocalizations.of(context).memoNewField));
    });
    _changed();
  }

  void _removeField(int index) {
    if (index < 0 || index >= _fields.length) return;
    final row = _fields[index];
    setState(() => _fields.removeAt(index));
    _changed();
    // 等本帧重建卸载输入框后再释放控制器，避免使用已释放的控制器。
    WidgetsBinding.instance.addPostFrameCallback((_) => row.dispose());
  }

  /// 正文由编辑器自行监听，只在页头标题或失败提示变化时刷新页面外壳。
  void _saveChanged() {
    try {
      final title = _readNoteTitle();
      final failed = _draft.state == MemoSaveState.failed;
      if (mounted && (title != _displayedNoteTitle || failed != _saveFailed)) {
        setState(() {
          _displayedNoteTitle = title;
          _saveFailed = failed;
        });
      }
      if (!_draft.dirty) {
        final drafts = {...ref.read(memoProtectedDraftsProvider)}
          ..remove(_draftKey);
        ref.read(memoProtectedDraftsProvider.notifier).set(drafts);
      }
    } catch (error, stackTrace) {
      logger.error(
        'MemoEditor',
        '更新备忘保存状态失败',
        safeErrorSummary(error),
        stackTrace,
      );
      _showEditError();
    }
  }

  /// 页头只需要首段摘要，卡片使用固定页面名称而不读取正文。
  String _readNoteTitle() => _card
      ? ''
      : _quill.document
            .getPlainText(0, _quill.document.length.clamp(0, 256))
            // 图片占位符不进入标题，避免页头出现无意义符号。
            .replaceAll('\uFFFC', '')
            .trimLeft()
            .split('\n')
            .first
            .trim();

  void _changed() {
    if (!_identityValid || _readOnly) return;
    _lastEditContext = ref
        .read(productAnalyticsControllerProvider)
        .captureContext(parent: _analyticsContext);
    _draft.editLazy(_captureSnapshot);
  }

  /// 新建笔记留下的空白正文：整篇只有一行，且除默认标题外没有其它行格式。
  bool get _blankNote {
    if (_card || _quill.document.length != 1) return false;
    final attributes = _quill.document.toDelta().first.attributes;
    return attributes == null ||
        (attributes.length == 1 &&
            attributes.containsKey(Attribute.header.key));
  }

  /// 编辑异常时保留页面并提示重试，技术诊断由文档层记录。
  void _showEditError() {
    if (mounted && _identityValid) {
      showToast(context, AppLocalizations.of(context).commonOperationFailed);
    }
  }

  /// 空笔记一次性粘贴：正文按粘贴内容自身的格式铺开。
  Future<bool> _pasteIntoBlankNote() async {
    if (!mounted || _readOnly || !_identityValid) return true;
    if (!_blankNote) return false;
    try {
      final text = (await Clipboard.getData(Clipboard.kTextPlain))?.text;
      // 剪贴板返回时页面、会话或编辑状态可能已变化；消费此次操作，
      // 防止编辑器继续执行缺少身份检查的默认粘贴。
      if (!mounted || _readOnly || !_identityValid) return true;
      if (text == null || text.isEmpty) return true;
      final blank = _blankNote;
      final selection = _quill.selection;
      if (!selection.isValid) return true;
      // 等待期间已有输入时按当前选区插入，只有仍为空白的正文才整段铺开。
      final start = blank ? 0 : selection.start;
      final length = blank ? 0 : selection.end - selection.start;
      final rich =
          text == _quill.pastePlainText &&
          _quill.pastePlainText.isNotEmpty &&
          _quill.pasteDelta.isNotEmpty;
      // 空白模板中的整段粘贴有明确的正文格式，不作为手写标题拆分。
      final Object content = rich
          ? _quill.pasteDelta
          : blank
          ? (Delta()..insert(text))
          : text;
      _quill.replaceText(
        start,
        length,
        content,
        TextSelection.collapsed(offset: start + text.length),
      );
      if (blank) {
        // 仅清除空白模板末行的默认标题，保留已有正文及粘贴内容自身的格式。
        _quill.formatText(
          _quill.document.length - 1,
          1,
          Attribute.clone(Attribute.header, null),
        );
      }
      return true;
    } catch (error, stackTrace) {
      logger.error(
        'MemoEditor',
        '读取或粘贴剪贴板失败',
        safeErrorSummary(error),
        stackTrace,
      );
      if (mounted && _identityValid) {
        showToast(context, AppLocalizations.of(context).commonOperationFailed);
      }
      return true;
    }
  }

  /// 正文已引用的图片数量，与服务端一致的单篇上限。
  int get _imageCount => _quill.document
      .toDelta()
      .toJson()
      .where((op) => memoImageIdOf(op) != null)
      .length;

  /// 从相册选择图片：压缩后落库并插入正文，云端本由媒体服务异步上传。
  Future<void> _insertImage() async {
    if (_readOnly || _busy || !_identityValid) return;
    final l = AppLocalizations.of(context);
    if (_imageCount >= memoImageLimit) {
      showToast(context, l.memoImageLimitReached);
      return;
    }
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 85,
      );
      if (picked == null || !mounted) return;
      final bytes = await picked.readAsBytes();
      if (bytes.length > 8 * 1024 * 1024) {
        if (mounted) showToast(context, l.memoImageTooLarge);
        return;
      }
      final normalized = await _normalizeImage(bytes);
      final item = await _media.add(
        entryId: widget.entryId,
        bytes: normalized,
        cloud: widget.book.isCloud,
      );
      if (!mounted || !_identityValid) return;
      _insertImageValue(memoImageValue(item.id, 100));
    } catch (error, stackTrace) {
      logger.error(
        'MemoEditor',
        '插入备忘录图片失败',
        safeErrorSummary(error),
        stackTrace,
      );
      if (mounted && _identityValid) {
        showToast(context, l.memoImageInsertFailed);
      }
    }
  }

  /// 正文只保存可被 PDF/Word 承载的格式：WebP 首次插入时转为 PNG。
  Future<Uint8List> _normalizeImage(Uint8List bytes) async {
    final mime = memoMediaMimeOf(bytes);
    if (mime == null) throw const FormatException('MEMO_MEDIA_FORMAT');
    if (mime != 'image/webp') return bytes;
    final codec = await ui.instantiateImageCodec(bytes);
    try {
      final frame = await codec.getNextFrame();
      try {
        final data = await frame.image.toByteData(
          format: ui.ImageByteFormat.png,
        );
        if (data == null) throw StateError('MEMO_IMAGE_ENCODE_FAILED');
        return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      } finally {
        frame.image.dispose();
      }
    } finally {
      codec.dispose();
    }
  }

  /// 图片独占一段：两侧补换行，保证段落模型与三种文件导出都能稳定排版。
  void _insertImageValue(String value) {
    try {
      final document = _quill.document;
      final text = document.toPlainText();
      final selection = _quill.selection;
      final index = selection.isValid
          ? selection.start.clamp(0, document.length - 1)
          : document.length - 1;
      final length = selection.isValid ? selection.end - selection.start : 0;
      final before = index > 0 ? text.substring(index - 1, index) : '\n';
      final after = index < text.length
          ? text.substring(index, index + 1)
          : '\n';
      final change = Delta();
      if (before != '\n') change.insert('\n');
      change.insert({'memo_image': value});
      if (after != '\n') change.insert('\n');
      _quill.replaceText(
        index,
        length,
        change,
        TextSelection.collapsed(offset: index + change.length),
      );
    } catch (error, stackTrace) {
      logger.error(
        'MemoEditor',
        '写入备忘录图片引用失败',
        safeErrorSummary(error),
        stackTrace,
      );
      _showEditError();
    }
  }

  /// 点击图片后的操作：调整显示比例、保存、剪切到新位置或删除。
  Future<void> _handleImageTap(
    MemoImageRef image,
    Embed node,
    QuillController controller,
  ) async {
    final index = memoImageEmbedIndex(controller.document, node);
    if (index == null) return;
    final l = AppLocalizations.of(context);
    final action = await showAppSheet<({_MemoImageAction kind, int? percent})>(
      context: context,
      heightFactor: 0.6,
      child: AppSheet(
        title: l.memoImageActionsTitle,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimens.p16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l.memoImageSize,
                  style: AppTextTokens.label(context),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.p16,
                vertical: AppDimens.p8,
              ),
              child: Wrap(
                spacing: AppDimens.p8,
                children: [
                  for (final percent in const [25, 50, 75, 100])
                    ChoiceChip(
                      label: Text('$percent%'),
                      selected: image.percent == percent,
                      onSelected: (_) => Navigator.pop(context, (
                        kind: _MemoImageAction.resize,
                        percent: percent,
                      )),
                    ),
                ],
              ),
            ),
            const Divider(height: AppDimens.p16),
            ListTile(
              leading: const Icon(AppIcons.download),
              title: Text(l.memoImageSave),
              onTap: () => Navigator.pop(context, (
                kind: _MemoImageAction.save,
                percent: null,
              )),
            ),
            if (!_readOnly)
              ListTile(
                leading: const Icon(AppIcons.copy),
                title: Text(l.memoImageCut),
                onTap: () => Navigator.pop(context, (
                  kind: _MemoImageAction.cut,
                  percent: null,
                )),
              ),
            if (!_readOnly)
              ListTile(
                leading: const Icon(AppIcons.delete),
                title: Text(l.memoImageDelete),
                onTap: () => Navigator.pop(context, (
                  kind: _MemoImageAction.delete,
                  percent: null,
                )),
              ),
            const SizedBox(height: AppDimens.p8),
          ],
        ),
      ),
    );
    if (action == null || !mounted) return;
    switch (action.kind) {
      case _MemoImageAction.resize:
        _replaceImageValue(
          controller,
          index,
          memoImageValue(image.id, action.percent!),
        );
      case _MemoImageAction.save:
        await _saveMemoImage(image.id);
      case _MemoImageAction.cut:
        setState(() => _pendingImageValue = image.value);
        _deleteImageAt(controller, index);
        showToast(context, l.memoImageCutHint);
      case _MemoImageAction.delete:
        _deleteImageAt(controller, index);
    }
  }

  /// 只替换嵌入节点的数据，保留图片在正文中的位置与撤销历史。
  void _replaceImageValue(QuillController controller, int index, String value) {
    controller.replaceText(index, 1, {
      'memo_image': value,
    }, TextSelection.collapsed(offset: index + 1));
  }

  void _deleteImageAt(QuillController controller, int index) {
    controller.replaceText(
      index,
      1,
      '',
      TextSelection.collapsed(offset: index),
    );
  }

  /// 把图片字节写入临时文件后交由系统分享面板保存或发送。
  Future<void> _saveMemoImage(String mediaId) async {
    final l = AppLocalizations.of(context);
    try {
      final bytes = await _media.bytesOf(mediaId);
      if (bytes == null) {
        if (mounted) showToast(context, l.memoImageUnavailable);
        return;
      }
      final mime = memoMediaMimeOf(bytes);
      if (mime == null) {
        if (mounted) showToast(context, l.memoImageUnavailable);
        return;
      }
      final extension = mime == 'image/png'
          ? 'png'
          : mime == 'image/jpeg'
          ? 'jpg'
          : 'webp';
      final directory = await getTemporaryDirectory();
      final file = File(p.join(directory.path, 'memo_$mediaId.$extension'));
      await file.writeAsBytes(bytes, flush: true);
      if (!mounted) return;
      final box = context.findRenderObject() as RenderBox?;
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: mime)],
          sharePositionOrigin: box == null
              ? null
              : box.localToGlobal(Offset.zero) & box.size,
        ),
      );
      try {
        await file.delete();
      } catch (_) {
        // 分享面板可能仍在读取该文件，删除失败留给临时目录自行回收。
      }
    } catch (error, stackTrace) {
      logger.error(
        'MemoEditor',
        '保存备忘录图片失败',
        safeErrorSummary(error),
        stackTrace,
      );
      if (mounted) showToast(context, l.memoImageSaveFailed);
    }
  }

  /// 把剪切暂存的图片插入到当前光标位置。
  void _pastePendingImage() {
    final value = _pendingImageValue;
    if (value == null) return;
    _insertImageValue(value);
    setState(() => _pendingImageValue = null);
  }

  /// 清空正文后恢复新建笔记的默认首行标题，手写首行与新建笔记保持一致。
  void _restoreBlankTitle() {
    if (_readOnly || !_blankNote) return;
    if (_quill.document.toDelta().first.attributes != null) return;
    _quill.formatText(0, 1, Attribute.h1);
  }

  MemoEntry _captureSnapshot() {
    final now = DateTime.now().toUtc();
    return MemoEntry(
      id: widget.entryId,
      memoBookId: widget.book.id,
      bookType: widget.book.type,
      // 普通笔记标题来自正文首行，按字符簇截取避免截断表情。
      title: _card
          ? _title.text
          : _quill.document
                .toPlainText()
                .replaceAll('\uFFFC', '')
                .trimLeft()
                .split('\n')
                .first
                .trim()
                .characters
                .take(20)
                .join(),
      createdAt: _createdAt,
      updatedAt: now,
      bodyJson: _card
          ? encodeMemoFields(_cardFields())
          : jsonEncode({'ops': _quill.document.toDelta().toJson()}),
      orderKey: widget.entry?.orderKey,
    );
  }

  /// 保存时丢弃名称与取值都为空的字段，其余按当前顺序写出。
  List<MemoField> _cardFields() => [
    for (final row in _fields)
      if (row.label.text.trim().isNotEmpty || row.value.text.isNotEmpty)
        MemoField(label: row.label.text.trim(), value: row.value.text),
  ];

  /// 名称可以留空，但只要填了取值就必须有字段名；整张卡片不能完全为空。
  bool _cardValid() {
    final l = AppLocalizations.of(context);
    if (_fields.any(
      (row) => row.label.text.trim().isEmpty && row.value.text.isNotEmpty,
    )) {
      showToast(context, l.memoFieldNameRequired);
      return false;
    }
    if (!hasVisibleText(_title.text) && _cardFields().isEmpty) {
      showToast(context, l.memoCardEmpty);
      return false;
    }
    return true;
  }

  /// 显式保存记录点击与完成，自动保存不会制造重复的保存按钮行为。
  Future<bool> _save({bool explicit = false}) async {
    if (_busy || !_identityValid) return false;
    final analyticsContext = ref
        .read(productAnalyticsControllerProvider)
        .captureContext(parent: _analyticsContext);
    if (explicit) {
      ref
          .read(productAnalyticsControllerProvider)
          .trackAction(
            pageId: _card ? 'credentials.editor' : 'memos.editor',
            action: _card
                ? ProductAction.credentialsSaveClick
                : ProductAction.memosNoteSaveClick,
            context: analyticsContext,
          );
    }
    if (_card && !_cardValid()) return false;
    if (explicit && (!_card || (!_draft.dirty && widget.entry == null))) {
      _changed();
    }
    setState(() => _busy = true);
    _explicitSaving = explicit;
    _explicitSaveContext = explicit ? analyticsContext : null;
    try {
      await _draft.flush();
      return mounted && _identityValid;
    } catch (error, stackTrace) {
      logger.error('MemoEditor', '保存内容失败，草稿已保留', error.runtimeType, stackTrace);
      if (mounted) {
        final l = AppLocalizations.of(context);
        showToast(
          context,
          error is StateError && error.message == 'MEMO_ORDER_CAPACITY'
              ? l.memoOrderCapacity
              : l.memoSaveFailed,
        );
      }
      return false;
    } finally {
      _explicitSaving = false;
      _explicitSaveContext = null;
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<bool> _prepareLeave() async {
    if (_busy) return false;
    if (_identityValid && _draft.dirty) {
      if (_card) {
        _discardCardDraft();
      } else if (!await _save()) {
        return false;
      }
    }
    return true;
  }

  /// 保存成功后停留在正文只读态；失败时保留编辑入口与草稿。
  Future<void> _finishEditing() async {
    if (!await _save(explicit: true) || !mounted) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _readOnly = true;
      _quill.readOnly = true;
    });
    _publishAnalyticsPage();
  }

  /// 查看态的点击只负责定位和切换模式，键盘由编辑实例完成布局后唤起。
  bool _beginEditing(
    TapUpDetails details,
    TextPosition Function(Offset) positionForOffset,
  ) {
    if (!_readOnly) return false;
    if (!_identityValid || _busy) return true;
    try {
      final position = positionForOffset(details.globalPosition);
      final ignoreFocus = _quill.ignoreFocusOnTextChange;
      try {
        // 命中位置来自切换前的正文布局，更新选区时不向只读实例请求键盘。
        _quill.ignoreFocusOnTextChange = true;
        _quill.updateSelection(
          TextSelection.fromPosition(position),
          ChangeSource.local,
        );
      } finally {
        _quill.ignoreFocusOnTextChange = ignoreFocus;
      }
      setState(() {
        _readOnly = false;
        _quill.readOnly = false;
      });
      _publishAnalyticsPage();
    } catch (error, stackTrace) {
      logger.error(
        'MemoEditor',
        '进入备忘录编辑失败',
        safeErrorSummary(error),
        stackTrace,
      );
      _showEditError();
    }
    // 此次点击已消费，避免默认点击链再次选择文字或请求键盘。
    return true;
  }

  void _discardCardDraft() {
    final drafts = {...ref.read(memoProtectedDraftsProvider)}
      ..remove(_draftKey);
    ref.read(memoProtectedDraftsProvider.notifier).set(drafts);
  }

  Future<void> _back() async {
    if (!await _prepareLeave()) return;
    if (mounted) {
      setState(() => _leave = true);
      Navigator.of(context).pop();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_card &&
        _identityValid &&
        (state == AppLifecycleState.inactive ||
            state == AppLifecycleState.paused)) {
      unawaited(_draft.flush().catchError((Object _) {}));
    }
  }

  @override
  void dispose() {
    final routeKey = _analyticsRouteKey;
    if (routeKey != null) {
      _analyticsPages.remove(routeKey, owner: _analyticsPageOwner);
    }
    _leaveGuards.remove(_prepareLeave);
    WidgetsBinding.instance.removeObserver(this);
    _changes?.cancel();
    _draft.removeListener(_saveChanged);
    _draft.dispose();
    _title.dispose();
    for (final field in _fields) {
      field.dispose();
    }
    _quill.dispose();
    super.dispose();
  }

  /// 固定目标失效时隔离编辑界面，卡片和普通正文分别呈现各自保存入口。
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    ref.watch(currentAccountIdProvider);
    ref.watch(authIdentityGenerationProvider);
    final valid = _identityValid;
    final status = _saveFailed ? l.memoSaveFailed : '';
    final saveButton = AppPrimaryButton(
      busy: _busy,
      onPressed: () async {
        if (await _save(explicit: true)) await _back();
      },
      label: l.commonSave,
    );
    if (_card) {
      return PopScope(
        canPop: !_busy,
        onPopInvokedWithResult: (didPop, _) {
          if (didPop) _discardCardDraft();
        },
        child: SafeArea(
          top: false,
          child: AppSheet(
            header: AppEditorHeader(
              title: widget.entry == null ? l.memoNewCard : l.memoEditCard,
              onBack: _busy ? null : _back,
            ),
            footer: valid ? saveButton : null,
            child: valid
                ? _cardForm(l, status)
                : AppEmpty(text: l.memoUnavailable),
          ),
        ),
      );
    }
    return PopScope(
      canPop: _leave,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) unawaited(_back());
      },
      child: Scaffold(
        body: Column(
          children: [
            PrimaryHeader(
              showBack: true,
              actions: valid && !_readOnly
                  ? [
                      HeaderTextAction(
                        label: l.commonSave,
                        onPressed: _busy ? null : _finishEditing,
                      ),
                    ]
                  : null,
              title: _displayedNoteTitle.isNotEmpty
                  ? _displayedNoteTitle
                  : (_readOnly || widget.entry != null
                        ? l.memoUntitled
                        : l.memoNewNote),
            ),
            Expanded(
              child: !valid
                  ? AppEmpty(text: l.memoUnavailable)
                  : SizedBox.expand(
                      key: _editorViewport,
                      child: MemoEditorSurface(
                        key: ValueKey(_readOnly),
                        controller: _quill,
                        scrollState: _editorScrollState,
                        readOnly: _readOnly,
                        contextMenuBuilder: _selectionMenu,
                        onTapUp: _beginEditing,
                        onEditError: _showEditError,
                        embedBuilders: [
                          MemoImageEmbedBuilder(onTap: _handleImageTap),
                        ],
                      ),
                    ),
            ),
            if (valid && !_readOnly)
              SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_saveFailed)
                      Semantics(liveRegion: true, child: Text(status)),
                    Padding(
                      padding: const EdgeInsets.all(AppDimens.p8),
                      child: Material(
                        color: AppTokens.surface(context),
                        borderRadius: BorderRadius.circular(AppDimens.radius28),
                        clipBehavior: Clip.antiAlias,
                        child: TextFieldTapRegion(child: _toolbar(l)),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 文本菜单只在正文视口内定位，全选长文时也不覆盖头部或键盘上方的功能栏。
  Widget _selectionMenu(BuildContext context, QuillRawEditorState state) {
    final viewport =
        _editorViewport.currentContext!.findRenderObject() as RenderBox;
    final origin = viewport.localToGlobal(Offset.zero);
    final anchor = state.contextMenuAnchors.primaryAnchor - origin;
    final visibleAnchor = Offset(
      anchor.dx.clamp(0, viewport.size.width),
      anchor.dy.clamp(0, viewport.size.height),
    );
    return Positioned.fromRect(
      rect: origin & viewport.size,
      child: ClipRect(
        child: MediaQuery.removePadding(
          context: context,
          removeTop: true,
          removeBottom: true,
          child: TextFieldTapRegion(
            child: AdaptiveTextSelectionToolbar.buttonItems(
              buttonItems: state.contextMenuButtonItems,
              anchors: TextSelectionToolbarAnchors(
                primaryAnchor: visibleAnchor,
                secondaryAnchor:
                    visibleAnchor +
                    Offset(
                      0,
                      state.renderEditor.preferredLineHeight(
                        _quill.selection.base,
                      ),
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _cardForm(AppLocalizations l, String status) => ListView(
    padding: EdgeInsets.zero,
    shrinkWrap: true,
    children: [
      AppFormSection(
        compact: true,
        title: l.memoName,
        child: TextFormField(
          style: AppTextTokens.input(context),
          controller: _title,
          minLines: 1,
          maxLines: null,
          decoration: InputDecoration(hintText: l.memoEnterName),
        ),
      ),
      for (var index = 0; index < _fields.length; index++)
        AppFormSection(
          compact: true,
          title: l.memoFieldIndex(index + 1),
          trailing: IconButton(
            tooltip: l.memoRemoveField,
            onPressed: () => _removeField(index),
            icon: const Icon(AppIcons.delete, size: AppDimens.icon16),
            color: AppTokens.iconSecondary(context),
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          child: Column(
            children: [
              TextFormField(
                style: AppTextTokens.input(context),
                controller: _fields[index].label,
                minLines: 1,
                maxLines: null,
                decoration: InputDecoration(hintText: l.memoFieldName),
              ),
              const SizedBox(height: AppDimens.p8),
              // 字段取值可能承载密码，统一关闭联想与自动更正。
              TextFormField(
                style: AppTextTokens.input(context),
                controller: _fields[index].value,
                minLines: 1,
                maxLines: null,
                keyboardType: TextInputType.visiblePassword,
                autocorrect: false,
                enableSuggestions: false,
                enableIMEPersonalizedLearning: false,
                decoration: InputDecoration(hintText: l.memoFieldValue),
              ),
            ],
          ),
        ),
      Padding(
        padding: const EdgeInsets.only(bottom: AppDimens.p12),
        child: TextButton.icon(
          onPressed: _fields.length >= memoFieldLimit ? null : _addField,
          icon: const Icon(AppIcons.add, size: AppDimens.icon20),
          label: Text(l.memoAddField),
        ),
      ),
      if (_saveFailed)
        Semantics(
          liveRegion: true,
          child: Text(status, style: AppTextTokens.label(context)),
        ),
    ],
  );

  Widget _toolbar(AppLocalizations l) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: [
        MemoHistoryButtons(controller: _quill),
        QuillToolbarToggleStyleButton(
          controller: _quill,
          attribute: Attribute.bold,
          baseOptions: memoToolbarButtonOptions,
          options: const QuillToolbarToggleStyleButtonOptions(
            iconData: AppIcons.bold,
          ),
        ),
        for (final attribute in [Attribute.h1, Attribute.h2, Attribute.h3])
          TextButton(
            onPressed: () {
              final active =
                  _quill
                      .getSelectionStyle()
                      .attributes[Attribute.header.key]
                      ?.value ==
                  attribute.value;
              _quill.formatSelection(Attribute.clone(Attribute.list, null));
              _quill.formatSelection(
                Attribute.clone(attribute, active ? null : attribute.value),
              );
            },
            child: Text('H${attribute.value}'),
          ),
        QuillToolbarToggleStyleButton(
          controller: _quill,
          attribute: Attribute.ol,
          baseOptions: memoToolbarButtonOptions,
          options: const QuillToolbarToggleStyleButtonOptions(
            iconData: AppIcons.orderedList,
          ),
        ),
        QuillToolbarToggleStyleButton(
          controller: _quill,
          attribute: Attribute.ul,
          baseOptions: memoToolbarButtonOptions,
          options: const QuillToolbarToggleStyleButtonOptions(
            iconData: AppIcons.bulletList,
          ),
        ),
        QuillToolbarToggleCheckListButton(
          controller: _quill,
          baseOptions: memoToolbarButtonOptions,
          options: const QuillToolbarToggleCheckListButtonOptions(
            iconData: AppIcons.checklist,
          ),
        ),
        IconButton(
          tooltip: l.memoInsertImage,
          icon: const Icon(AppIcons.image, size: AppDimens.icon20),
          onPressed: _busy ? null : _insertImage,
        ),
        if (_pendingImageValue != null)
          IconButton(
            tooltip: l.memoImagePaste,
            icon: const Icon(AppIcons.paste, size: AppDimens.icon20),
            onPressed: _busy ? null : _pastePendingImage,
          ),
        IconButton(
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          icon: const Icon(AppIcons.indentDecrease, size: AppDimens.icon20),
          onPressed: () => _indent(-1),
        ),
        IconButton(
          tooltip: MaterialLocalizations.of(context).nextPageTooltip,
          icon: const Icon(AppIcons.indentIncrease, size: AppDimens.icon20),
          onPressed: () => _indent(1),
        ),
      ],
    ),
  );
  void _indent(int delta) {
    final level =
        (_quill.getSelectionStyle().attributes[Attribute.indent.key]?.value
            as int? ??
        0);
    final next = (level + delta).clamp(0, 5);
    _quill.formatSelection(
      Attribute.clone(Attribute.indent, next == 0 ? null : next),
    );
  }
}
