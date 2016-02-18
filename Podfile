workspace 'PrettyGoodKVO'

use_frameworks!
inhibit_all_warnings!

source 'https://github.com/CocoaPods/Specs.git'

project 'PrettyGoodKVO'

target "TestApp" do
   project 'PrettyGoodKVO'
   platform :ios, "9.0"
   pod 'PrettyGoodKVO', :path => '.'
end

target "PrettyGoodKVOTests" do
   project 'PrettyGoodKVO'
   platform :ios, "9.0"
   pod 'Quick'
   pod 'Nimble'
end


post_install do |installer|

   workspace_name = 'PrettyGoodKVO'
   installer.pods_project.targets.each do |target|
       target.build_configurations.each do |config|
           if config.name == "Debug"
               config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-Onone'
               else
               config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-Owholemodule'
           end
       end
   end

end
