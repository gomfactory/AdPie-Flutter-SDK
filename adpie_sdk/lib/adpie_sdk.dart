
import 'adpie_sdk_platform_interface.dart';

class AdpieSdk {
  Future<String?> getPlatformVersion() {
    return AdpieSdkPlatform.instance.getPlatformVersion();
  }
}
