# vi: ft=ruby

Pod::Spec.new do |s|
  s.name = "TypedNotification"
  s.version = "1.0.0"
  s.summary = "TypedNotification Library"

  s.description = <<-DESC
  TypedNotification Library for iOS
  DESC

  s.homepage = "https://www.rocketinsights.com"

  s.author = "Paul Calnan"

  s.source = { :git => "https://github.com/rocketinsights/RITypedNotification.git", :tag => "#{s.version}" }
  s.license = { :type => "MIT" }

  s.platform = :ios, "11.0"
  s.swift_version = "5.0"

  s.source_files = "Sources/TypedNotification/**/*.swift"
end

