Pod::Spec.new do |s|
    s.name         = 'XBUserDefaults'
    s.version      = '1.0.0'
    s.summary      = 'Easy to use NSUserDefaults'
    s.homepage     = 'https://github.com/yanxiaobing/XBUserDefaults'
    s.license      = 'MIT'
    s.authors      = {'XBingo' => 'dove025@qq.com'}
    s.platform     = :ios, '8.0'
    s.source       = {:git => 'https://github.com/yanxiaobing/XBUserDefaults.git', :tag => s.version}
    s.requires_arc = true
    s.source_files     = 'XBUserDefaults/**/*.{h,m}'
end