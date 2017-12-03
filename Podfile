use_frameworks!
target 'TheLuxuryShopper' do
    pod 'MessageKit'
    pod 'Alamofire', '~> 4.5'
    post_install do |installer|
        installer.pods_project.targets.each do |target|
            if target.name == 'MessageKit'
                target.build_configurations.each do |config|
                    config.build_settings['SWIFT_VERSION'] = '4.0'
                end
            end
        end
    end
end
