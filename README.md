# AKImageCropper

-> ![Preview](https://raw.githubusercontent.com/artemkrachulov/AKMaskField/master/Assets/preview.png) <-

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
    cropView = AKImageCropperView(frame: frame, image: image, showOverlayView: false)

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
init(frame: CGRect, image: UIImage, showOverlayView: Bool)
```

| Parameter       | Description    |
| :-------------- | :------------- |
| frame           | The frame rectangle for the cropper view, measured in points. The origin of the frame is relative to the superview in which you plan to add it. |
| image           | The image you want to crop. |
| showOverlayView | Pass true to show overlay view with crop rect on initialization. |

Initializes and returns a newly allocated croper view object with the specified frame rectangle, image to crop and crop frame show/hide on initialization flag.

```swift
init(image: UIImage, showOverlayView: Bool)
```

| Parameter       | Description    |
| :-------------- | :------------- |
| image           | The image you want to crop. |
| showOverlayView | Pass true to show overlay view with crop rect on initialization. |

Initializes and returns a newly allocated croper view object with CGRectZero frame rectangle, image to crop and overlay view show / hide on initialization flag.

## Properties

<!-- ### Image -->

```swift
var image: UIImage!
```

The image you want to crop.
The initial value of this property is `nil`.

```swift
var imageView: UIImageView! {get}
```

Returns image view object.

### Crop rectangle

```swift
var cropRect: CGRect {get}
```

Returns crop frame rectangle, measured in points. If overlay view is active value returns crop rectangle located on the overlay view, if not - crop rectangle based on scroll view frame.

```swift
var cropRectTranslatedToImage: CGRect {get}
```

Returns crop rectangle `cropRect` translated to image with scroll view scale factor, measured in points.

```swift
var cropRectMinSize: CGSize
```

The minimum value to which is possible to reduce the size of crop rectangle.
The initial value of this property is `30` pixels width and `30` pixels height.

```swift
var scrollView: AKImageCropperScollView! {get}
```

Returns scroll view object as `UIScrollView` subclass. `UIScrollViewDelegate` protocol can be extended in your view controller.

### Configuring overlay animation

```swift
var overlayViewAnimationDuration: NSTimeInterval
```

The duration of the transition animation, measured in seconds.
The initial value of this property is `300` milliseconds.

```swift
var overlayViewAnimationOptions: UIViewAnimationOptions
```

Specifies the supported animation curves.
The initial value of this property is `CurveLinear`.

### Configuring overlay view

```swift
var fingerSize: CGFloat

//     __ __ __ __ Crop View __ __
//    |
//    |      __ __ __ __ Crop Frame __ __
//    |     |
//    |<--->| -- Offset fingerSize / 2 (Default: 15.0)
//    |     |
//    |<---- ----> -- Finger touch size "fingerSize"  (Default: 30.0)
//    |     |
```

A size width of finger touch. This value used to calculate a size of the outer offset crop frame. See diagram.
The initial value of this property is `30` pixels.

```swift
var cornerOffset: Int
```
The distance to which will be offset corners of the crop rectangle.
The initial value of this property is `3` pixels.

```swift
var cornerSize: Int
```
The size of the crop rectangle corners.
The initial value of this property is `18` pixels width and `18` pixels height.

```swift
var grid: Bool
```

A Boolean value that determines whether the lines inside the crop frame will be shown.
The initial value of this property is `true`.

```swift
var gridLines: Int
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

### Overlay view state

```swift
var overlayViewIsActive {get}
```

Returns a boolean value that determines overaly view state in current moment.

### Managing the Delegate

```swift
weak var delegate: AKImageCropperViewDelegate?
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
| rect          | The crop rectangle for the overlay view, measured in points. The origin of the frame is relative to the superview where overlay view placed. |

### Presenting crop overlay

```swift
func showOverlayViewAnimated(flag: Bool,
               withCropFrame cropRect: CGRect!,
                             completion: (() -> Void)?)
```

| Parameter     | Description    |
| :------------ | :------------- |
| flag          | Pass true to animate the transition. |
| cropRect      | The crop rectangle, measured in points. The origin of the frame is relative to the overlay view. If you may specify `nil` for this parameter, crop rectangle will have size that eaual of scroll view. |
| completion    | The block to execute after the overlay view is presented. This block has no return value and takes no parameters. You may specify `nil` for this parameter. |

Presents a crop view.

```swift
func dismissOverlayViewAnimated(flag: Bool,
                                completion: (() -> Void)?)
```

| Parameter     | Description    |
| :------------ | :------------- |
| flag          | Pass true to animate the transition. |
| completion    | The block to execute after the overlay view is dismissed. This block has no return value and takes no parameters. You may specify `nil` for this parameter. |

Dismisses the crop view.

### Get cropped image

```swift
func croppedImage() -> UIImage
```

Returns a cropped image.

### Responding to user actions

```swift
optional func cropRectChanged(rect: CGRect)
```

| Parameter     | Description    |
| :------------ | :------------- |
| rect          | New crop rectangle origin and size. |

Tells the delegate when the crop rectangle was changed.

### Draw crop rectagle

```swift
optional func overlayViewDrawInTopLeftCropRectCornerPoint(point: CGPoint)
```

| Parameter     | Description    |
| :------------ | :------------- |
| point         | Point where placed corner view. |

Draws corner on the overlay view context in top left corner of the crop rectangle.

```swift
optional func overlayViewDrawInTopRightCropRectCornerPoint(point: CGPoint)
```

| Parameter     | Description    |
| :------------ | :------------- |
| point         | Point where placed corner view. |

Draws corner on the overlay view context in top right corner of the crop rectangle.

```swift
optional func overlayViewDrawInBottomRightCropRectCornerPoint(point: CGPoint)
```

| Parameter     | Description    |
| :------------ | :------------- |
| point         | Point where placed corner view. |

Draws corner on the overlay view context in bottom right corner of the crop rectangle.

```swift
optional func overlayViewDrawInBottomLeftCropRectCornerPoint(point: CGPoint)
```

| Parameter     | Description    |
| :------------ | :------------- |
| point         | Point where placed corner view. |

Draws corner on the overlay view context in bottom left corner of the crop rectangle.

```swift
optional func overlayViewDrawStrokeInCropRect(cropRect: CGRect)
```

| Parameter     | Description    |
| :------------ | :------------- |
| cropRect      | Crop rectangle origin and size. |

Draws stroke line for the crop rectangle on the overlay view context.


```swift
optional func overlayViewDrawGridInCropRect(cropRect: CGRect)
```

| Parameter     | Description    |
| :------------ | :------------- |
| cropRect      | Crop rectangle origin and size. |

Draws grid lines inside the crop rectangle on the overlay view context.

### Author

Artem Krachulov: [www.artemkrachulov.com](http://www.artemkrachulov.com/), email [artem.krachulov@gmail.com](mailto:artem.krachulov@gmail.com)

### License

Released under the [MIT license](http://www.opensource.org/licenses/MIT)