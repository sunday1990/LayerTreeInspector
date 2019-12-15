#
# Be sure to run `pod lib lint LayerTreeInspector.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'LayerTreeInspector'
  s.version          = '0.1.0'
  s.summary          = 'LayerTreeInspector For Your App'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
This is a tool to inspect your view hierarchys on your iphone at realtime,Provide two ways to view hierarchys：one is the general flat tree structure and anothe is three-dimensional form，So you can get out of Xcode and reach the result you want
                       DESC

  s.homepage         = 'https://github.com/sunday1990/LayerTreeInspector'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Eychos' => '935143023@qq.com' }
  s.source           = { :git => 'https://github.com/sunday1990/LayerTreeInspector.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'LayerTreeInspector/Classes/**/*'

  s.resource_bundles = {
   'LayerTreeInspector' => ['LayerTreeInspector/Assets/Assets.xcassets']
  }
end
