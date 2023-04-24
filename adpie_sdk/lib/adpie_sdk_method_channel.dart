import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'adpie_sdk_platform_interface.dart';

/// An implementation of [AdpieSdkPlatform] that uses method channels.
class MethodChannelAdpieSdk extends AdpieSdkPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('adpie_sdk');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
