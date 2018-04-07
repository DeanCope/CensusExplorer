# Uncomment the next line to define a global platform for your project
platform :ios, '11.0'

target 'CensusAPI' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for CensusAPI

 pod 'Charts', '~> 3.1'
 pod 'RxSwift', '~> 4.0'
 pod 'RxCocoa', '~> 4.0'
 pod 'Action', '~> 3.4'
 pod 'NSObject+Rx', '~> 4.1'
 pod 'Alamofire', '~> 4.5'
 pod 'Instructions', '~> 1.1.0'
 
 target 'CensusAPITests' do
     inherit! :search_paths
     pod 'RxTest', '~> 4.0'
     pod 'RxBlocking', '~> 4.0'
 end

end

#post_install do |installer|
#  installer.pods_project.targets.each do |target|
#    target.build_configurations.each do |config|
#      config.build_settings['SWIFT_VERSION'] = '3.2'
#    end
#  end
#end

# enable tracing resources
#post_install do |installer|
#    installer.pods_project.targets.each do |target|
#        if target.name == 'RxSwift'
#            target.build_configurations.each do |config|
#                if config.name == 'Debug'
#                    config.build_settings['OTHER_SWIFT_FLAGS'] ||= ['-D', #'TRACE_RESOURCES']
#                end
#            end
#        end
#    end
#end
