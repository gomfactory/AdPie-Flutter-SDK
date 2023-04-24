import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:adpie_sdk/adpie_sdk_method_channel.dart';

void main() {
  MethodChannelAdpieSdk platform = MethodChannelAdpieSdk();
  const MethodChannel channel = MethodChannel('adpie_sdk');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
