Pod::Spec.new do |s|
  s.name             = "CDManager"
  s.version          = "0.1.0"
  s.summary          = "Core Data Manager."
  s.description      = <<-DESC
                        Easily add Core Data to your iOS/OS X project.
                       DESC
  s.homepage         = "https://github.com/fmscode/CDManager"
  s.license          = 'MIT'
  s.author           = { "Frank Michael Sanchez" => "orion1701@me.com" }
  s.source           = { :git => "https://github.com/fmscode/CDManager.git", :tag => s.version.to_s }

  s.ios.deployment_target = '7.0'
  s.osx.deployment_target = '10.9'
  s.requires_arc = true

  s.source_files = 'Classes'
  s.resources = 'Assets/*.png'

  s.ios.exclude_files = 'Classes/osx'
  s.osx.exclude_files = 'Classes/ios'
  s.frameworks = 'CoreData'
end
