# AKImageCropper

A View subclass for image cropping for iSO devices with support for landscape orientation. Cropper allows to specify the location and size of the crop frame. Easy to set up. Has many settings for flexible integration into your project. The plugin is written in Swift.

**Features:**

* Easy to set up and use
* Crop frame animation
* Full image resolution
* Zoom and scroll
* Сolor customization
* Action callbacks

## Usage

### Storyboard

```swift
@IBOutlet weak var cropView: AKImageCropperView!

override func viewDidLoad() {
    super.viewDidLoad()

    cropView.image = UIImage(named: "yourImage")
}

override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()

    // Refreshing
    cropView.refresh()
}
```

### Programmatically

```swift
var cropView: AKImageCropperView!

override func viewDidLoad() {
    super.viewDidLoad()

    let image = UIImage(named: "yourImage")
    let frame = CGRectMake(0, 0, 300, 300)
    cropView = AKImageCropperView(frame: frame, image: image, showCropFrame: false)

    view.addSubview(cropView)
}

override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()

    // Refreshing
    cropView.refresh()
}
```

## Initializing

```swift
init(frame: CGRect, image: UIImage, showCropFrame: Bool)
```

| Parameter     | Description    |
| :------------ | :------------- |
| frame         | The frame rectangle for the cropper view, measured in points. The origin of the frame is relative to the superview in which you plan to add it. |
| image         | The image you want to crop. The minimum size of the image is calculated by the formula: minWidth x minHeight = fingerSize*2 x fingerSize*2, where fingerSize - a size width of finger touch (default 30 px). |
| showCropFrame | Pass true to show crop frame on initialization. |

Initializes and returns a newly allocated croper view object with the specified frame rectangle, image to crop and crop frame show/hide on initialization flag.

```swift
init(image: UIImage, showCropFrame: Bool)
```

| Parameter     | Description    |
| :------------ | :------------- |
| image         | The image you want to crop. The minimum size of the image is calculated by the formula: minWidth x minHeight = fingerSize*2 x fingerSize*2, where fingerSize - a size width of finger touch (default 30 px). |
| showCropFrame | Pass true to show crop frame on initialization. |

Initializes and returns a newly allocated croper view object with CGRectZero frame rectangle, image to crop and crop frame show/hide on initialization flag.

## Properties

### Configuring cropper view

```swift
var image: UIImage!
```

The image you want to crop. The minimum size of the image is calculated by the formula: minWidth x minHeight = fingerSize*2 x fingerSize*2, where fingerSize - a size width of finger touch (default 30 px).
The initial value of this property is `nil`.

```swift
var cropRect: CGRect
```

The crop frame rectangle, measured in points. In depending, if crop overlay is active value returns crop frane rectangle located in the overlay or crop frane rectangle based on scroll view size and content offset origin points.

```swift
var cropImageRect: CGRect
```

The crop frame rectangle `cropRect` translated to image with zoom scale factor, measured in points.

```swift
var cropFrameAnimationDuration: NSTimeInterval
```

The duration of the transition animation, measured in seconds.
The initial value of this property is `300` milliseconds.

```swift
var cropFrameAnimationOptions: UIViewAnimationOptions
```

Specifies the supported animation curves.
The initial value of this property is `CurveLinear`.

### Configuring overlay view with crop frame

```swift
var fingerSize: CGFloat
```

A size width of finger touch on the outside line of crop frame. This value used to calculate a size of the outer offset crop frame. See diagram below.
```swift
//     __ __ __ __ Crop View __ __
//    |
//    |      __ __ __ __ Crop Frame __ __
//    |     |
//    |<--->| -- Offset fingerSize / 2 (Default: 15.0)
//    |     |
//    |<---- ----> -- Finger touch size "fingerSize"  (Default: 30.0)
//    |     |
```
The initial value of this property is `30` pixels.

```swift
var grid: Bool
```

A Boolean value that determines whether the lines inside the crop frame will be shown.
The initial value of this property is `true`.

```swift
var gridLines: Int8
```

The number of vertical and horizontal lines inside the crop frame.
The initial value of this property is `2` (`2` vertical and `2` horizontal lines).

```swift
var overlayColor: UIColor
```

Overlay background color where crop frame is located.
The initial value of this property is `UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)` (Black with 50% alpha).

```swift
var strokeColor: UIColor
```

The color of the outer frame line.
The initial value of this property is `UIColor(red: 1, green: 1, blue: 1, alpha: 1)` (White).

```swift
var cornerColor: UIColor
```

The color of the outer corners of the frame.
The initial value of this property is `UIColor(red: 1, green: 1, blue: 1, alpha: 1)` (White).

```swift
var gridColor: UIColor
```

The color of the vertical and horizontal lines inside the crop frame.
The initial value of this property is `UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)` (White with 50% alpha).

### Crop Frame state

```swift
var cropFrameIsActive { get }
```

A Boolean value that determines crop frame state in current moment.
The initial value of this property is `false`.

### Managing the Delegate

```swift
weak var delegate: AKImageCropperDelegate?
```
The object that acts as the delegate of the cropper view.

## Methods

### Refreshing and destroying

```swift
func refresh()
```

Call this method to refresh all sizes of the views that used to construct the copper view.

```swift
func destroy()
```

Call this method to destroy the copper view with removing itself from superview.

### Crop rectangle

```swift
func setCropRect(rect: CGRect)
```

| Parameter     | Description    |
| :------------ | :------------- |
| rect          | The crop frame rectangle for the cropper view, measured in points. The origin of the frame is relative to the superview where overlay view placed. |

### Presenting crop overlay

```swift
func showOverlayViewAnimated(flag: Bool,
               withCropFrame cropRect: CGRect!,
                             completion: (() -> Void)?)
```

| Parameter     | Description    |
| :------------ | :------------- |
| flag          | Pass true to animate the transition. |
| cropRect      | The frame rectangle for the crop frame, measured in points. The origin of the frame is relative to the crop overlay view. If you may specify `nil` for this parameter, crop frame rectangle will have size that eaual of image view. |
| completion    | The block to execute after the crop overlay is presented. This block has no return value and takes no parameters. You may specify `nil` for this parameter. |

Presents a crop view.

```swift
func dismissOverlayViewAnimated(flag: Bool,
                                completion: (() -> Void)?)
```

| Parameter     | Description    |
| :------------ | :------------- |
| flag          | Pass true to animate the transition. |
| completion    | The block to execute after the crop overlay is dismissed. This block has no return value and takes no parameters. You may specify `nil` for this parameter. |

Dismisses the crop view.

### Get cropped image

```swift
func croppedImage() -> UIImage
```

Returns a cropped image. Расмер выреззанного изображения учитывается с зумм фактором

### Responding to user actions

```swift
optional func cropperViewDidScroll(scrollView: UIScrollView)
```

| Parameter     | Description    |
| :------------ | :------------- |
| scrollView    | The scroll-view object in which the scrolling occurred. |

Tells the delegate when the user scrolls the image view within the receiver.

```swift
optional func cropperViewDidZoom(scrollView: UIScrollView)
```

| Parameter     | Description    |
| :------------ | :------------- |
| scrollView    | The scroll-view object in which the scrolling occurred. |

Tells the delegate that the scroll view’s zoom factor changed.

```swift
optional func croperViewDidMoveCropFrame(frame: UIView)
```

| Parameter     | Description    |
| :------------ | :------------- |
| frame         | Crop frame.    |

Tells the delegate that the crop frame size changed.

### Author

Artem Krachulov: [www.artemkrachulov.com](http://www.artemkrachulov.com/), email [artem.krachulov@gmail.com](mailto:artem.krachulov@gmail.com)

### License

Released under the [MIT license](http://www.opensource.org/licenses/MIT)