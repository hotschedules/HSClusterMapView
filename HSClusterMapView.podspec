Pod::Spec.new do |s|
  s.name             = "HSClusterMapView"
  s.version          = "1.0.4"
  s.summary          = "A GMSMapView subclass which clusters GMSMarkers within close proximity."
  s.description      = "A GMSMapView subclass which clusters groups of GMSMarkers and replaces them with single GMSMarkers, enabling the developer to generate custom UIImages for each cluster on the fly. It also includes a GMSMapView subclass, HSMapView, which does not cluster GMSMarkers, but instead keeps track of the GMSMarkers on the map internally, eliminating the need to store them elsewhere. HSMapView aims to provide a clean map interface to work with the Google Maps for iOS SDK."
  s.homepage         = "https://github.com/hotschedules/HSClusterMapView"
  s.license          = 'MIT'
  s.author           = { "abouzek" => "alan.bouzek@gmail.com" }
  s.source           = { :git => "https://github.com/hotschedules/HSClusterMapView.git", :tag => s.version.to_s }

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'

  s.frameworks = 'UIKit', 'MapKit', 'GoogleMaps'
  s.dependency 'GoogleMaps', '~> 1.13.0'

end
