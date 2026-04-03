

Pod::Spec.new do |spec|
  spec.name         = 'NinePatch'
  spec.module_name  = 'NinePatch'
  spec.summary      = 'NinePatch'
  spec.version      = '0.0.1'
  
  spec.ios.deployment_target  = '11.0'
  spec.license      = { :type => 'MIT' }
  spec.homepage     = 'https://github.com/568071718'
  spec.authors      = { 'o.o.c.' => '568071718@qq.com' }
  spec.source       = { :git => 'https://', :tag => "v#{spec.version}" }
  
  spec.source_files = 'Sources/**/*.{h,m,swift}'

end


