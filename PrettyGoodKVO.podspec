Pod::Spec.new do |s|
    s.name             = "PrettyGoodKVO"
    s.version          = "0.1.0"
    s.summary          = "KVO without the hassle. strongly typed in Swift"
    s.description      = "A framework for KVO with automatic unobserving, strongly typed in Swift and only firing on changes."
    s.author           = "Jed Lewison"
    s.homepage         = "https://github.com/jedlewison/PrettyGoodKVO"
    s.license          = 'MIT'
    s.source           = { :git => "https://github.com/jedlewison/PrettyGoodKVO.git", :tag => s.version.to_s }
    s.platform         = :ios, '9.0'
    s.requires_arc     = true
    s.source_files     = "PrettyGoodKVO/*.{swift,h}"
end
