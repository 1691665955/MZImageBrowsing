# MZImageBrowsing
图片预览、缩放、分享、保存

#### 注意添加相册权限
- Privacy - Photo Library Additions Usage Description
- Privacy - Photo Library Usage Description

<div align=center>
<img src="1.gif" width="300px" />
</div>

#### Cocoapods 引入
```
pod 'MZImageBrowsing', '~> 0.0.3'
```

#### 使用
```
// 使用要预览的imageView数组初始化
let controller = MZImageBrowsingController(imageViewList: imageViews, currentIndex: index)
self.present(controller, animated: true, completion: nil)

// 使用网络图片链接数组和当前选中的imageView初始化
let controller = MZImageBrowsingController(imageUrlList: urls, currentImageView: imageView, currentIndex: index)
self.present(controller, animated: true, completion: nil)
```
