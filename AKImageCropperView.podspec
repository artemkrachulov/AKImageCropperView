Pod::Spec.new do |s|

  s.name         = "AKImageCropperView"
  s.version      = "2.0.0"
  s.homepage     = "https://github.com/artemkrachulov/AKImageCropperView"
  s.summary      = "Responsive image cropper"
  s.description  = <<-DESC
                   Image cropping plugin which supported different devices orientation. Easy to set up and configure. Has many settings for flexible integration into your project. Behavior is similar to native iOS photo cropper.
                   DESC

  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Artem Krachulov" => "artem.krachulov@gmail.com"  }

  # Source Info

  s.ios.deployment_target = "8.0"

  s.source        = { 
    :git => "https://github.com/artemkrachulov/AKImageCropperView.git", 
    :tag => 'v'+s.version.to_s 
  }

  s.source_files  = "AKImageCropperView/*.{swift}"
  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '5.0' }
end