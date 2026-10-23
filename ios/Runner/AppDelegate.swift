import Flutter
import Darwin
import Network
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate, FlutterStreamHandler {
  private var networkMonitor: NWPathMonitor?
  private var networkChannel: FlutterEventChannel?
  private var clockChannel: FlutterEventChannel?
  private let clockHandler = ClockStreamHandler()
  private var deviceMetadataChannel: FlutterMethodChannel?
  private var memoNameOrderChannel: FlutterMethodChannel?

  /// 在隐式引擎就绪后注册系统网络接口通知。
  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    memoNameOrderChannel = FlutterMethodChannel(
      name: "com.sesame_notes.memo_name_order",
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
    memoNameOrderChannel?.setMethodCallHandler { call, result in
      guard call.method == "sortNames" else {
        result(FlutterMethodNotImplemented)
        return
      }
      do {
        result(try Self.sortMemoNames(call.arguments))
      } catch {
        NSLog("卡片名称排序失败：%@", String(describing: type(of: error)))
        result(FlutterError(code: "MEMO_NAME_ORDER_FAILED", message: "卡片名称排序失败，请重试", details: nil))
      }
    }
    deviceMetadataChannel = FlutterMethodChannel(
      name: "com.sesame_notes.device_metadata",
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
    deviceMetadataChannel?.setMethodCallHandler { [weak self] call, result in
      guard call.method == "readDeviceMetadata" else {
        result(FlutterMethodNotImplemented)
        return
      }
      guard let self else {
        result(FlutterError(code: "DEVICE_METADATA_FAILED", message: "设备资料暂时无法读取，登录仍可继续", details: nil))
        return
      }
      result(self.readDeviceMetadata())
    }
    networkChannel = FlutterEventChannel(
      name: "com.sesame_notes.network",
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
    networkChannel?.setStreamHandler(self)
    clockChannel = FlutterEventChannel(
      name: "com.sesame_notes.clock",
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
    clockChannel?.setStreamHandler(clockHandler)
  }

  /// 系统路径仅说明接口可用；目标服务端是否可达由 HTTP 响应确认。
  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    networkMonitor?.cancel()
    let monitor = NWPathMonitor()
    networkMonitor = monitor
    monitor.pathUpdateHandler = { [weak self, weak monitor] path in
      DispatchQueue.main.async {
        guard let self, let monitor, self.networkMonitor === monitor else { return }
        events(path.status == .satisfied)
      }
    }
    monitor.start(queue: DispatchQueue(label: "com.sesame_notes.network"))
    return nil
  }

  /// 取消订阅后使排队回调失效，并释放系统路径监听。
  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    networkMonitor?.cancel()
    networkMonitor = nil
    return nil
  }

  /// 应用代理释放时关闭仍存活的系统监听。
  deinit {
    networkMonitor?.cancel()
    deviceMetadataChannel?.setMethodCallHandler(nil)
    memoNameOrderChannel?.setMethodCallHandler(nil)
  }

  /// 使用固定中文和自然数字规则，等价名称按身份稳定排列。
  private static func sortMemoNames(_ arguments: Any?) throws -> [String] {
    guard let entries = arguments as? [[String: String]],
          entries.allSatisfy({ $0["id"] != nil && $0["title"] != nil }) else {
      throw NSError(domain: "MemoNameOrder", code: 1)
    }
    let options: String.CompareOptions = [.caseInsensitive, .diacriticInsensitive, .widthInsensitive, .numeric]
    return entries.sorted { left, right in
      let order = left["title"]!.compare(right["title"]!, options: options, locale: Locale(identifier: "zh_CN"))
      return order == .orderedSame ? left["id"]! < right["id"]! : order == .orderedAscending
    }.map { $0["id"]! }
  }

  /// 机型标识由系统 uname 返回，不猜测营销名称，不读取设备唯一标识或用户设备名。
  private func readDeviceMetadata() -> [String: Any] {
    var metadata: [String: Any] = [
      "platform": "ios",
      "os_version": "\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)"
    ]
    var info = utsname()
    guard uname(&info) == 0 else {
      NSLog("设备机型读取失败，系统错误码：%d", errno)
      return metadata
    }
    let model = Mirror(reflecting: info.machine).children.reduce(into: "") { value, element in
      guard let code = element.value as? Int8, code != 0 else { return }
      value.append(String(UnicodeScalar(UInt8(bitPattern: code))))
    }
    if !model.isEmpty { metadata["device_model"] = model }
    return metadata
  }
}

/// 日期与时区通知不携带业务信息，取消订阅后同步移除观察者。
private final class ClockStreamHandler: NSObject, FlutterStreamHandler {
  private var observers: [NSObjectProtocol] = []

  /// 同时覆盖显著时间变化与系统时区变化。
  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    removeObservers()
    for name in [UIApplication.significantTimeChangeNotification, NSNotification.Name.NSSystemTimeZoneDidChange] {
      observers.append(NotificationCenter.default.addObserver(forName: name, object: nil, queue: .main) { _ in
        events("clockChanged")
      })
    }
    return nil
  }

  /// Flutter 取消订阅后释放全部通知观察者。
  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    removeObservers()
    return nil
  }

  /// 清理重复订阅和应用退出时的系统监听。
  private func removeObservers() {
    observers.forEach(NotificationCenter.default.removeObserver)
    observers.removeAll()
  }

  deinit { removeObservers() }
}
