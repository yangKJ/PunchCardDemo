#
# Be sure to run 'pod lib lint PunchCard.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'PunchCard'
  s.version          = '0.0.1'
  s.summary          = 'Punch card record manager.'
  
  # This description is used to generate tags and improve search results.
  #   * Think: What does it do? Why did you write it? What is the focus?
  #   * Try to keep it short, snappy and to the point.
  #   * Write the description between the DESC delimiters below.
  #   * Finally, don't worry about the indent, CocoaPods strips it!
  
  s.homepage         = 'https://github.com/yangKJ/PunchCardDemo'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Condy' => 'ykj310@126.com' }
  s.source           = { :git => 'https://github.com/yangKJ/PunchCard.git', :tag => s.version }
  s.module_name      = s.name
  
  s.swift_version    = '5.0'
  s.requires_arc     = true
  s.static_framework = true
  s.ios.deployment_target = '10.0'
  
  ## 数据库工具模块, 由于时间精力有限这个就先不做成私有库。
  ## 正常项目当中这个会作为私有库模块引入
  s.subspec 'Manager' do |xx|
    xx.source_files = 'Sources/Manager/*.swift'
    xx.dependency 'WCDB.swift'
  end
  
  s.subspec 'PunchCard' do |xx|
    xx.source_files = 'Sources/PunchCard/*.swift'
    xx.dependency 'PunchCard/Manager'
  end
  
end
