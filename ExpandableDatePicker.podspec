#
#  Be sure to run `pod spec lint ExpandableDatePicker.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.platform = :ios
  s.ios.deployment_target = '10.0'
  s.name         = "ExpandableDatePicker"
  s.summary      = "Expandable UIDatePicker and TimeZone selection for UITableView"
  s.version      = "0.8.0"
  s.license      = 'MIT'
  s.author             = { "Scott Grosch" => "Scott.Grosch@icloud.com" }
  s.homepage     = "https://github.com/GargoyleSoft/ExpandableDatePicker"
  s.source       = { :git => "https://github.com/GargoyleSoft/ExpandableDatePicker.git", :tag => "#{s.version}" }

  s.framework  = "UIKit"
  s.source_files = "ExpandableDatePicker/**/*.{swift}"
end
