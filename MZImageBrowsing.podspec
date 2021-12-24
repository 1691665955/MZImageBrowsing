Pod::Spec.new do |spec|
  spec.name         = "MZImageBrowsing"
  spec.version      = "0.0.1"
  spec.summary      = "图片预览、缩放、分享、保存"
  spec.homepage     = "https://github.com/1691665955/MZImageBrowsing"
  spec.authors         = { 'MZ' => '1691665955@qq.com' }
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.source = { :git => "https://github.com/1691665955/MZImageBrowsing.git", :tag => spec.version}
  spec.platform     = :ios, "9.0"
  spec.swift_version = '5.0'
  spec.source_files  = "MZImageBrowsing/MZImageBrowsing/*"
end
