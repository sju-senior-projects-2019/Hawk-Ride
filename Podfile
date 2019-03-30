
# Uncomment the next line to define a global platform for your project
 platform :ios, '11.0'

target 'Hawk Ride' do

    use_frameworks!

    pod 'Firebase/Core'
    pod 'Firebase/Auth'
    pod 'Firebase/Database'
    pod 'Firebase/Storage'
    pod 'GeoFire'
    pod 'GoogleMaps'
    pod 'SVProgressHUD'
    pod 'GooglePlaces'
    pod 'RevealingSplashView'
    pod 'Alamofire'
    pod 'SwiftyJSON'



    if(ENV['TEST_BRANCH'])
      pod 'MaterialComponents', :git => 'https://github.com/material-components/material-components-ios', :branch => ENV['TEST_BRANCH']
    elsif(ENV['TEST_COMMIT'])
      pod 'MaterialComponents', :git => 'https://github.com/material-components/material-components-ios', :commit => ENV['TEST_COMMIT']
    elsif(ENV['TEST_TAG'])
      pod 'MaterialComponents', :git => 'https://github.com/material-components/material-components-ios', :tag => ENV['TEST_TAG']
    elsif(ENV['DEFAULT_BRANCH'])
      pod 'MaterialComponents', :git => 'https://github.com/material-components/material-components-ios', :branch => ENV['DEFAULT_BRANCH']
    else
      pod 'MaterialComponents', :git => 'https://github.com/material-components/material-components-ios', :branch => 'google-io-codelabs-2018'
    end

end
