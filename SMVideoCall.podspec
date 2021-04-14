Pod::Spec.new do |s|
s.name             = "SMVideoCall"
s.version          = "0.1"
s.summary          = "A videobank lib"
s.homepage         = "https://github.com/smpb05/SMVideoCall"
s.license          = "MIT"
s.author           = { 'Smartex' => 'nurgul.aisariyeva@smartex.kz' }
s.source           = { :git => 'https://github.com/smpb05/SMVideoCall.git', :branch => 'master' }
s.swift_versions = ['5.0']
s.ios.deployment_target = '11.0'
s.source_files = 'SMVideoCall/**/*.{swift}'
s.static_framework = true
s.dependency 'WKWebViewRTC', '~> 0.3.0
end