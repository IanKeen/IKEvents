Pod::Spec.new do |spec|
  spec.name         = 'IKEvents'
  spec.version      = '1.0'
  spec.license      = { :type => 'MIT' }
  spec.homepage     = 'https://github.com/iankeen/'
  spec.authors      = { 'Ian Keen' => 'iankeen82@gmail.com' }
  spec.summary      = 'Simple pub/sub events with built-in resource lifecycle management.'
  spec.source       = { :git => 'https://github.com/iankeen/ikevents.git', :tag => spec.version.to_s }

  spec.source_files = 'IKEvents/**/**.{h,m}'
  
  spec.requires_arc = true
  spec.platform     = :ios
  spec.ios.deployment_target = "7.0"
end
