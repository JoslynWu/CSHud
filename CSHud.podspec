Pod::Spec.new do |s|
  s.name         = "CSHud"
  s.version      = "0.9.6"
  s.summary      = "基于MBProgressHUD的封装。绘制常用图形并配以动画。"
  s.license      = { :type => 'MIT License', :file => 'LICENSE' }
  s.authors      = { 'Joslyn' => 'cs_joslyn@foxmail.com' }
  s.homepage     = 'https://github.com/JoslynWu/CSHud'
  s.social_media_url   = "http://www.jianshu.com/u/fb676e32e2e9"
  s.ios.deployment_target = '9.0'
  s.source       = { :git => 'https://github.com/JoslynWu/CSHud.git', :tag => s.version.to_s }
  s.requires_arc = true
  s.source_files = 'CSHud/*.{h,m}'
  s.public_header_files = 'CSHud/*.{h}'
  s.dependency 'MBProgressHUD'
end
