import 'package:flutter_test/flutter_test.dart';
import 'package:adpie_sdk/adpie_sdk.dart';
import 'package:adpie_sdk/adpie_sdk_platform_interface.dart';
import 'package:adpie_sdk/adpie_sdk_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockAdpieSdkPlatform
    with MockPlatformInterfaceMixin
    implements AdpieSdkPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final AdpieSdkPlatform initialPlatform = AdpieSdkPlatform.instance;

  test('$MethodChannelAdpieSdk is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelAdpieSdk>());
  });

  test('getPlatformVersion', () async {
    AdpieSdk adpieSdkPlugin = AdpieSdk();
    MockAdpieSdkPlatform fakePlatform = MockAdpieSdkPlatform();
    AdpieSdkPlatform.instance = fakePlatform;

    expect(await adpieSdkPlugin.getPlatformVersion(), '42');
  });
}
