

简单的通过点 9 数据构建可拉伸的 UIImage 对象  

```swift

import NinePatch

...

guard let url = Bundle.main.url(forResource: "nine_patch_img", withExtension: "png") else { return }
guard let data = try? Data(contentsOf: url) else { return }
let img = NinePatch.ninePatchImage(withData: data, scale: 3.0)
let imageView = UIImageView(image: img)
imageView.center = CGPoint(x: view.frame.width * 0.5, y: view.frame.height * 0.5)
imageView.bounds = CGRect(x: 0, y: 0, width: 300, height: 100)
view.addSubview(imageView)

```

