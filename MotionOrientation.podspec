
Pod::Spec.new do |s|

  s.name         = "MotionOrientation"
  s.version      = "0.0.1"
  s.summary      = "An observer to notify the orientation of iOS device changed, using CoreMotion for taking the orientation in 'Orientation Lock'."
  s.homepage     = "https://github.com/tastyone/MotionOrientation"
  
  s.license      = { :type => 'Apache License, Version 2.0', :text => <<-LICENSE
      Licensed under the Apache License, Version 2.0 (the "License");
      you may not use this file except in compliance with the License.
      You may obtain a copy of the License at
      
      http://www.apache.org/licenses/LICENSE-2.0
      
      Unless required by applicable law or agreed to in writing, software
      distributed under the License is distributed on an "AS IS" BASIS,
      WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
      See the License for the specific language governing permissions and
      limitations under the License.
      LICENSE
  }
  s.author       = { "Sangwon Park" => "" }
  
  s.platform     = :ios
  s.source       = { :git => "https://github.com/tastyone/MotionOrientation.git", :commit => "67ecd027dfd629380133806ad9ad98f50b40f0ba" }
  s.source_files  = 'MotionOrientation.{h,m}'
  s.preserve_paths = "README.md"
  s.frameworks = 'CoreMotion', 'CoreGraphics'

end
