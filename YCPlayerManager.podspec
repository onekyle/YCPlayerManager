#
# Be sure to run `pod lib lint YCPlayerManager.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'YCPlayerManager'
  s.version          = '0.1.1'
  s.summary          = 'Media player.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = 'A lightweight media player base on AVPlayer in iOS platform'

  s.homepage         = 'https://github.com/flappyFeline/YCPlayerManager'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Durand Wang' => 'ych.wang@outlook.com' }
  s.source           = { :git => 'https://github.com/flappyFeline/YCPlayerManager.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '7.0'

  s.source_files = 'YCPlayerManager/Classes/**/*'
  s.resource = "YCPlayerManager/YCPlayerManager.bundle"
#s.resource_bundles = 'YCPlayerManager/YCPlayerManager.bundle'


  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
