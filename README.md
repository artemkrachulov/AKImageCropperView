# AKImageCropper

AKImageCropper is cropping class for iOS devices. Has many settings for flexible integration into your project. The plugin is written in Swift.

## Features

* Supported crop rectangle animation (show / dismiss)
* Full image resolution
* Zoom and scroll image
* Translation to landscape or portrait orientation
* Crop overlay customization (draw custom crop rectangle, color, grid, etc.)
* Easy to set up

## Requirements

- iOS 8.0+
- Xcode 7.3+

## Installation

1. Clone or download demo project.
2. Add `AKImageCropper` folder to your project.

## Initializing

```swift
init(image: UIImage?)
```

Initialize and returns a newly allocated croper view object with CGRectZero frame rectangle.
Parameters:

* `image` : The initial image to display in the croper view.

## Accessing the Images

```swift
var image: UIImage?
```

The image to display in the croper view. The initial value of this property is `nil`.

```swift
var croppedImage: UIImage? {get}
```

The image cropped from specified rectangle. If rectangle not set property will return current image visible in the cropper view. The initial value of this property is `nil`.

## Crop rectangle

```swift
var cropRect: CGRect {get}
```
Returns crop rectangle frame, measured in points. If overlay view not active - crop rectangle will return visbible image size frame.

```swift
func cropRect(rect: CGRect)
```
Will set crop rectangle frame in the overlay view.
Parameters:

* `rect` : Rectangle origin and size in the overlay view.

```swift
var cropRectScaled: CGRect {get}
```

Returns crop rectangle frame translated with scroll view zoom and offset factor, measured in points.

### Animating overlay view

```swift
func showOverlayView(animated: Bool, completion: (() -> Void)?)
func showOverlayView(animated: Bool, withCropRect rect: CGRect, completion: (() -> Void)?)
```

Presents the overlay view.
Parameters:

* `flag` : Pass true to animate the transition.
* `cropRect` : The crop rectangle, measured in points. The origin of the frame is relative to the overlay view. If you may specify `nil` for this parameter, crop rectangle will have size that equal to the scroll view and `CGPointZero` origin coordinates.
* `completion` : The block to execute after the overlay view is presented. This block has no return value and takes no parameters. You may specify `nil` for this parameter.

```swift
func hideOverlayView(animated: Bool, completion: (() -> Void)?)
```

Dismisses the overlay view.
Parameters:

* `flag` : Pass true to animate the transition.
* `completion` : The block to execute after the Overlay view is dismissed. This block has no return value and takes no parameters. You may specify `nil` for this parameter.

## Configuration

```swift
var configuration: AKImageCropperConfiguration
```

List of all confuguration options for crop rectangle and overlay view presented in `AKImageCropperConfiguration` class.

### AKImageCropperConfiguration

```swift
var touchArea: CGFloat
/// Calculates:
///     offset(touchArea/2)-(stroke line)-inset(touchArea/2)
///
///               - - - Crop rectangle frame - - -
///              |
///              | < - Stroke line
///              |
///     |< - - - - - - - >| < - Finger touch area
///     | offset | inset  |
```

Finger touch area on the stroke line of crop rectangle. The initial value of this property is `30` pixels.

```swift
var cropRect: (
    minimumSize: CGSize,
    grid: Bool,
    gridLinesCont: Int,
    gridLineWidth: Int,
    gridColor: UIColor,
    cornerOffset: CGFloat,
    cornerSize: CGSize,
    cornerColor: UIColor,
    strokeColor: UIColor,
    strokeWidth: Int
)
```

Options:
* `minimumSize` : The minimum crop rectangle frame size to which is possible reduce frame. Maximum value equal to the scroll view frame size. The initial value of this property is `30` pixels width and `30` pixels height
* `grid` :  `true` value will show grid inside crop rectange frame.
* `gridLinesCont` : The number of vertical and horizontal lines inside the crop rectangle. The initial value of this property is `2` (`2` vertical and `2` horizontal lines).
* `gridLineWidth` : The width of the grig vertical and horizontal line. The initial value of this property is `1` px.
* `gridColor` : The color of the vertical and horizontal lines inside the crop rectangle. The initial value of this property is `UIColor.whiteColor()`.
* `cornerOffset` : The distance to which will be offset corners of the crop rectangle stroke line. The initial value of this property is `3` pixels.
* `cornerSize` : The size of the crop rectangle corner. The initial value of this property is `18` pixels width and `18` pixels height.
* `cornerColor` : The color of the corners of the crop rectangle. The initial value of this property is `UIColor.whiteColor()`.
* `strokeColor` : The color of the outer crop rectangle line. The initial value of this property is `UIColor.whiteColor()`.
* `strokeWidth` : The width of the crop rectangle stroke. The initial value of this property is `1` px.

```swift
var overlay: (
    animationDuration: NSTimeInterval,
    animationOptions: UIViewAnimationOptions,
    bgColor: UIColor
)
```

Options:
* `animationDuration` : The duration of the transition animation, measured in seconds. The initial value of this property is `0.3` seconds.
* `animationOptions` : Specifies the supported animation curves. The initial value of this property is `CurveEaseOut`.
* `bgColor` : The view’s background color. The initial value of this property is `UIColor.blackColor().colorWithAlphaComponent(0.5)`.

### Accessing the Delegate

```swift
weak var cropRectDelegate: AKImageCropperCropRectDelegate?
```

A cropper view delegate that tells how draw cropper rectangle.

```swift
weak var delegate: AKImageCropperViewDelegate?
```

A cropper view delegate responds to editing-related messages from the crop rectangle.


## AKImageCropperCropRectDelegate

### Customizing corners

```swift
func drawCornerInTopLeftPoint(point: CGPoint, configuration: AKImageCropperConfiguration)
func drawCornerInTopRightPoint(point: CGPoint, configuration: AKImageCropperConfiguration)
func drawCornerInBottomRightPoint(point: CGPoint, configuration: AKImageCropperConfiguration)
func drawCornerInBottomLeftPoint(point: CGPoint, configuration: AKImageCropperConfiguration)
```

Parameters:
* `point` : Start point in the crop rectangle frame
* `configuration` : All configuration options.

### Customizing frame

```swift
  func drawStroke(cropRect: CGRect, configuration: AKImageCropperConfiguration)
  func drawGrid(cropRect: CGRect, configuration: AKImageCropperConfiguration)
```

Parameters:
* `cropRect` : Crop rectangle frame origin and size.
* `configuration` : All configuration options.

## AKImageCropperViewDelegate

```swift
optional func cropRectChanged(rect: CGRect)
```

Responding to user actions.
Parameters:
* `rect` : New rectangle origin and size in the overlay view.

## Overlay view state

```swift
var overlayIsActive {get}
```

Returns a boolean value that determines overaly view state in current moment.

---

Please do not forget to ★ this repository to increases its visibility and encourages others to contribute.

### Author

Artem Krachulov: [www.artemkrachulov.com](http://www.artemkrachulov.com/)
Mail: [artem.krachulov@gmail.com](mailto:artem.krachulov@gmail.com)

### License

Released under the [MIT license](http://www.opensource.org/licenses/MIT)