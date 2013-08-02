Pod::Spec.new do |s|
  s.name     = 'UIKitCategoryAdditions'
  s.version  = '0.0.1'
  s.summary  = 'Block based Category additions for AlertView and ActionSheets.'
  s.homepage = 'https://github.com/aazhou/UIKitCategoryAdditions'
  s.license  = { :type => 'Custom', :file => 'README.mdown' }
  s.author   = { 'aazhou' =>  'aaron.l.zhou@gmail.com' }
  s.source   = { :git => 'https://github.com/aazhou/UIKitCategoryAdditions.git'}
  s.platform = :ios
  s.source_files = 'MKAdditions/*.{h,m}'
  s.requires_arc = true
end