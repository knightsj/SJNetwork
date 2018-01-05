
Pod::Spec.new do |s|


  s.name         = "SJNetwork"
  s.version      = "1.2.0"
  s.summary      = "SJNetwork is a high level network request tool based on AFNetworking."
  s.homepage     = "https://github.com/knightsj/SJNetwork"
  s.license      = "MIT"
  s.author       = { "Sun Shijie" => "ssjlife0111@163.com" }
  s.source       = { :git => "https://github.com/knightsj/SJNetwork.git", :tag => s.version.to_s }
  s.source_files = 'SJNetwork/**/*.{h,m}'
  s.requires_arc = true

  s.ios.deployment_target = "8.0"
  # s.osx.deployment_target = "10.11"
  # s.watchos.deployment_target = "2.0"
  # s.tvos.deployment_target = "9.0"

  s.framework   = "UIKit"
  s.dependency "AFNetworking", "~> 3.0"



end
