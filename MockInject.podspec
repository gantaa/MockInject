Pod::Spec.new do |s|
  s.name         = "MockInject"
  s.version      = "1.0.2"
  s.summary      = "A library that allows developers to globally mock any ObjectiveC class' initialization method when testing with Kiwi."
  s.homepage     = "https://github.com/gantaa/MockInject"
  s.license 	 = { :type => 'MIT', :file => 'MIT-LICENSE.txt' }
  s.author       = { "Matt Ganski" => "gantasygames@gmail.com" }
  s.source       = { :git => "https://github.com/gantaa/MockInject.git", :tag => "#{s.version}" }
  s.platform     = :ios, '6.0'
  s.source_files = 'MockInject', 'MockInject/**/*.{h,m}'
  s.framework       = 'XCTest'
  s.public_header_files = 'MockInject/**/*.h'
  s.requires_arc = true
  s.dependency 'Kiwi'

  # TODO: clean this up once Apple gets their stuff together
  s.ios.xcconfig = {
    "FRAMEWORK_SEARCH_PATHS" => %w[
      $(SDKROOT)/Developer/Library/Frameworks
      $(inherited)
      $(DEVELOPER_FRAMEWORKS_DIR)
    ].join(' '),
    "FRAMEWORK_SEARCH_PATHS[sdk=iphoneos8.0]" => %w[
      $(inherited)
      $(DEVELOPER_DIR)/Platforms/iPhoneOS.platform/Developer/Library/Frameworks
    ].join(' '),
    "FRAMEWORK_SEARCH_PATHS[sdk=iphonesimulator8.0]" => %w[
      $(inherited)
      $(DEVELOPER_DIR)/Platforms/iPhoneSimulator.platform/Developer/Library/Frameworks
    ].join(' '),
  }
end
