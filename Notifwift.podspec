Pod::Spec.new do |s|
  s.name             = "Notifwift"
  s.version          = "0.2.2"
  s.summary          = "NSNotificationCenter wrapper for Swift"
  s.license          = 'MIT'
  s.homepage         = "https://github.com/takasek/Notifwift"
  s.author           = { "takasek" => "takassekiyoshi@gmail.com" }
  s.source           = { :git => "https://github.com/takasek/Notifwift.git",
                         :tag => s.version.to_s }
  s.source_files     = "Sources/*.swift"
  s.requires_arc     = true

  s.ios.deployment_target = "8.0"
  s.source_files = 'Notifwift/*.swift'
end
