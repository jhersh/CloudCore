Pod::Spec.new do |s|
  s.name             = "CloudCore"
  s.version          = "0.1.0"
  s.summary          = "Utilities for CloudKit and Core Data."
  s.homepage         = "https://github.com/jhersh/CloudCore"
  s.license          = 'MIT'
  s.author           = { "Jonathan Hersh" => "jon@her.sh" }
  s.source           = { :git => "https://github.com/jhersh/CloudCore.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/jhersh'
  s.platform         = :ios, '8.0'
  s.requires_arc     = true
  s.frameworks       = 'Foundation', 'CloudKit', 'CoreData'
  s.source_files     = 'CloudCore/**/*'
end
