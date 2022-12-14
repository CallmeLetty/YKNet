Pod::Spec.new do |spec|
  spec.name         = "YKNet"
  spec.version      = "1.0.0"
  spec.summary      = "YKNet is a http/https request service based on URLSession."
  spec.homepage     = "https://github.com/CallmeLetty/YKNet"
  spec.license      = "MIT"
  spec.author             = { "CallmeLetty" => "1085798092@qq.com" }
  spec.ios.deployment_target = "10.0"
  spec.osx.deployment_target = "10.10"
  spec.source       = { :git => "https://github.com/CallmeLetty/YKNet.git", :tag => "#{spec.version}" }

  spec.source_files  = "sources/*.{h,m,swift}","sources/private/*.{h,m,swift}"
  
  #spec.static_framework = true
  
  spec.module_name   = 'YKNet'
  spec.swift_versions = ['5.0', '5.1', '5.2', '5.3', '5.4']
  spec.xcconfig = { 'BUILD_LIBRARY_FOR_DISTRIBUTION' => 'YES' }
  spec.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64', 'DEFINES_MODULE' => 'YES' }
  spec.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64', 'DEFINES_MODULE' => 'YES' }
  spec.pod_target_xcconfig = { 'VALID_ARCHS' => 'arm64 armv7 x86_64' }
  spec.user_target_xcconfig = { 'VALID_ARCHS' => 'arm64 armv7 x86_64' }
end
