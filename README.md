# XBUserDefaults

-  `XBUserDefaults`是利用`Objective-C RunTime `机制对```NSUserDefaults```进行一层封装。
-  大大增加了易用性和可维护性。

>  几乎每个iOS项目中都会使用到`NSUserDefaults`，作为iOS开发常用的五种数据存储方式之一（`NSUserDefaults`、`plist`、`NSKeyedArchiver`、`FMDB`、`CoreData`），```NSUserDefaults```算是最易用的了。

>  但是项目中用的多了之后key管理起来就很麻烦了，而且用每次用到都要写一大坨代码。相信用过的朋友都有同感吧！

## 实现思路
- 数据存取

  将`@property`属性设置为`@dynamic`，然后利用消息机制在``` +(BOOL)resolveInstanceMethod:(SEL)sel```方法中根据@property类型动态添加相关（setter/getter）方法。相关内容则依然存储在`NSUserDefaults`中。
- 数据迁移

  为了更好的方便项目中已经大量使用`NSUserDefaults`的用户能相对轻松的迁移数据，内置了数据迁移方法``` transferToXBWithNewOldKeysDic:(NSDictionary *)newOldKeysDic```，通过newOldKeysDic映射表将旧数据迁移到新方式中去。newKey为属性名，通过newKey可以获取到属性类型，在根据类型和oldKey获取到旧数据并赋值给新方式。

## 安装方式
目前可以通过两种方式将XBUserDefaults集成到您的项目中。
- [下载 XBUserDefaults](https://github.com/yanxiaobing/XBUserDefaults/archive/master.zip) 然后将[XBUserDefaults]()文件夹拖入您的工程即可。
- [CocoaPods](http://cocoapods.org)集成

### 通过 CocoaPods 安装

[CocoaPods](http://cocoapods.org) is a dependency manager for Objective-C, which automates and simplifies the process of using 3rd-party libraries like XBUserDefaults in your projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

#### Podfile

To integrate XBUserDefaults into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'

target 'TargetName' do
pod 'XBUserDefaults'
end
```

Then, run the following command:

```bash
$ pod install
```


## Usage

创建一个`XBUserDefaults`子类，并将子类单例化。eg：

XBTestUserDefaults.h
```objective-c
#import "XBUserDefaults.h"

@interface XBTestUserDefaults : XBUserDefaults

@property (nonatomic ,copy) NSString *name; // 名字
@property (nonatomic ,assign) NSInteger age;// 年龄

+(instancetype)sharedInstance; // 单例方法
@end
```
XBTestUserDefaults.m
```objective-c

#import "XBTestUserDefaults.h"

@implementation XBTestUserDefaults

@dynamic name,age;  //一定要记得将属性名设置@dynamic，不然不会动态绑定setter/getter方法，保存不了值

static XBTestUserDefaults* _instance = nil;
+(instancetype) sharedInstance
{
static dispatch_once_t onceToken ;
dispatch_once(&onceToken, ^{
_instance = [[self alloc] init] ;
}) ;
return _instance ;
}
@end
```
如果需要数据迁移只需在旧数据使用前调用
```objective-c
// @"name"、@"age"对应新方式的属性名。
// @"test_name"、@"test_age"对应旧方式保存值得key。
// 旧数据类型需要与新方式的属性类型匹配。
NSDictionary *dic = @{@"name":@"test_name",
                    @"age":@"test_age"
                    };
[[XBTestUserDefaults sharedInstance] transferToXBWithNewOldKeysDic:dic]; 
```

添加新字段只需要在`@interface`中添加对应类型的`@property`并在`@implementation`文件中`@dynamic propertyName`，然后像普通`@property`使用了。如：
```objective-c 
[XBTestUserDefaults sharedInstance].name = @"我不是小冰冰";
NSLog(@"name:%@",[XBTestUserDefaults sharedInstance].name);
```

## Notices
- 最好用子类单例的形式。
- 添加新的属性的时候一定要记得在.m文件中`@dynamic propertyName`
- 数据迁移一定要注意映射表的构建，key-value 对应propertyName-oldKey。
- 数据迁移最好放在app升级的逻辑中做。
- 数据迁移不需要自己写逻辑控制只执行一次。作者已经帮你做好了。


## License

XBUserDefaults is released under the MIT license. See LICENSE for details.
