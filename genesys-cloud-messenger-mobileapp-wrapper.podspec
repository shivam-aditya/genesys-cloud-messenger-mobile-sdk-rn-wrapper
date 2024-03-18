require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = 'genesys-cloud-messenger-mobileapp-wrapper'
  s.version      = package["version"]
  s.summary      = 'Genesys Cloud Messenger MobileApp SDK React Native wrapper'
  s.homepage     = 'https://genesys.com'
  s.license      = { :type => 'MIT' }
  s.authors      = 'Shivam Aditya'
  s.platforms    = { :ios => '13.0' }
  s.source       = { :git => 'https://github.com/shivam-aditya/genesys-cloud-messenger-mobile-sdk-rn-wrapper', :tag => '#{s.version}' }
  s.source_files = "ios/**/*.{h,m,mm}"
  s.dependency 'React-Core'
  # s.dependency 'GenesysCloud', '4.1.0'
  s.dependency 'GenesysCloud', '1.7.1'
  s.static_framework = true
end
