Pod::Spec.new do |s|
  s.name             = 'MotionOrientation'
  s.version          = '1.0.0'
  s.summary          = 'Lightweight library for detecting device orientation changes via CoreMotion.'

  s.description      = <<-DESC
    MotionOrientation notifies device orientation changes using CoreMotion, even when UI orientation is locked.
  DESC

  s.homepage         = 'https://github.com/tastyone/MotionOrientation'
  s.license          = { :type => 'Apache License, Version 2.0', :file => 'LICENSE' }
  s.author           = { 'Sangwon Park' => 'tastyone@gmail.com' }
  s.source           = { :git => 'https://github.com/tastyone/MotionOrientation.git', :tag => s.version }

  s.platform         = :ios, '11.0'
  s.source_files     = 'MotionOrientation.{h,m}'

  s.public_header_files = 'MotionOrientation.h'

  s.frameworks       = 'CoreMotion'
  s.requires_arc     = true
end