#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint adpie_sdk.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'adpie_sdk'
  s.version          = '1.0.0'
  s.summary          = 'AdPie Ads plugin for Flutter'
  s.description      = <<-DESC
AdPie Ads plugin for Flutter
                       DESC
  s.homepage         = 'https://github.com/gomfactory/AdPie-Flutter-SDK'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Neptune Company' => 'admin@adpies.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.dependency 'AdPieSDK','~> 1.5'
  s.platform = :ios, '9.0'
  s.static_framework = true

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
end
