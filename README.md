# XLNavigationBar

## Example：

| Weibo | Douyin | 
| ---- | ---- | 
|![image](https://github.com/mengxianliang/ImageRepository/blob/master/XLNavigationBar/weibo.gif)|![image](https://github.com/mengxianliang/ImageRepository/blob/master/XLNavigationBar/douyin.gif)|

## Usage:

### Global Config

```objc
//enable XLNavigationBar at first
[XLNavigationBar shareInstance].enabled = YES;
//bar title color
[XLNavigationBar shareInstance].xl_navBarTitleColor = [UIColor blackColor];
//bar title font
[XLNavigationBar shareInstance].xl_navBarTitleFont = [UIFont systemFontOfSize:20];
//bar background color
[XLNavigationBar shareInstance].xl_navBarBackgroundColor = [UIColor whiteColor];
//bar background alpha
[XLNavigationBar shareInstance].xl_navBarBackgroundAlpha= 1;
//bar button color
[XLNavigationBar shareInstance].xl_navBarButtonColor = [UIColor blackColor];
//bar shadow image hidden
[XLNavigationBar shareInstance].xl_navBarShadowImageHidden = NO;
//status bar style
[XLNavigationBar shareInstance].xl_statusBarStyle = UIStatusBarStyleLightContent;
//status bar hidden
[XLNavigationBar shareInstance].xl_statusBarHidden = NO;
```

### ViewController Config

```objc
//bar title color
self.xl_navBarTitleColor = [UIColor blackColor];
//bar title font
self.xl_navBarTitleFont = [UIFont systemFontOfSize:20];
//bar background color
self.xl_navBarBackgroundColor = [UIColor whiteColor];
//bar background alpha
self.xl_navBarBackgroundAlpha= 1;
//bar button color
self.xl_navBarButtonColor = [UIColor blackColor];
//bar shadow image hidden
self.xl_navBarShadowImageHidden = NO;
//status bar style
self.xl_statusBarStyle = UIStatusBarStyleLightContent;
//status bar hidden
self.xl_statusBarHidden = NO;
```

### Other

ZoomHeader [XLChannelControl](https://github.com/mengxianliang/XLChannelControl)

XLUIKit [XLUIKit](https://github.com/mengxianliang/XLUIKit)
