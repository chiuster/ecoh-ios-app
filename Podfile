platform :ios, '10.0'
use_frameworks!

target 'ecoh' do
pod "Pulsator"
pod "Firebase"
pod "Firebase/Auth"
pod "Firebase/Core"
pod "Firebase/Database"
pod "Firebase/Storage"
pod "Firebase/Messaging"
pod 'GooglePlaces'
pod 'Mapbox-iOS-SDK'
pod 'SwiftyJSON'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    end
end
