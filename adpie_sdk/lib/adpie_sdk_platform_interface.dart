import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'adpie_sdk_method_channel.dart';

abstract class AdpieSdkPlatform extends PlatformInterface {
  /// Constructs a AdpieSdkPlatform.
  AdpieSdkPlatform() : super(token: _token);

  static final Object _token = Object();

  static AdpieSdkPlatform _instance = MethodChannelAdpieSdk();

  /// The default instance of [AdpieSdkPlatform] to use.
  ///
  /// Defaults to [MethodChannelAdpieSdk].
  static AdpieSdkPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [AdpieSdkPlatform] when
  /// they register themselves.
  static set instance(AdpieSdkPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
