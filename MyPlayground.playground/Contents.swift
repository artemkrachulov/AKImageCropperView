//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"


var value: CGFloat {
    return pow(15, 58)
}

public func ceil(x: Double, multiplier: Double) -> Double {
    return multiplier * ceil(x / multiplier)
}

public func floor(x: Double, multiplier: Double) -> Double {
    return multiplier * floor(x / multiplier)
}

public func round(x: Double, multiplier: Double) -> Double {
    return multiplier * round(x / multiplier)
}

let v =  0.93

ceil(x: v, multiplier: 0.05)

floor(x: v, multiplier: 0.05)

round(x: v, multiplier: 0.05)

round(5.55)




struct AKCropAreaPart: OptionSet {
    
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    static let None                 = AKCropAreaPart(rawValue: 0)
    static let All                  = AKCropAreaPart(rawValue: 1)
    static let TopEdge              = AKCropAreaPart(rawValue: 2)
    static let LeftEdge             = AKCropAreaPart(rawValue: 3)
    static let BottomEdge           = AKCropAreaPart(rawValue: 4)
    static let RightEdge            = AKCropAreaPart(rawValue: 5)
    static let TopLeftCorner        = AKCropAreaPart(rawValue: 6)
    static let TopRightCorner       = AKCropAreaPart(rawValue: 7)
    static let BottomRightCorner    = AKCropAreaPart(rawValue: 8)
    static let BottomLeftCorner     = AKCropAreaPart(rawValue: 9)
    
    /// Active parts in moving
    
    func move() -> [AKCropAreaPart] {
        switch self {
        case AKCropAreaPart.TopEdge:
            return [AKCropAreaPart.TopEdge]
        case AKCropAreaPart.LeftEdge:
            return [AKCropAreaPart.LeftEdge]
        case AKCropAreaPart.BottomEdge:
            return [AKCropAreaPart.BottomEdge]
        case AKCropAreaPart.RightEdge:
            return [AKCropAreaPart.RightEdge]
        case AKCropAreaPart.TopLeftCorner:
            return [AKCropAreaPart.TopEdge, AKCropAreaPart.LeftEdge]
        case AKCropAreaPart.TopRightCorner:
            return [AKCropAreaPart.TopEdge, AKCropAreaPart.RightEdge]
        case AKCropAreaPart.BottomRightCorner:
            return [AKCropAreaPart.BottomEdge, AKCropAreaPart.RightEdge]
        case AKCropAreaPart.BottomLeftCorner:
            return [AKCropAreaPart.BottomEdge, AKCropAreaPart.LeftEdge]
        case AKCropAreaPart.All:
            return [AKCropAreaPart.TopEdge, AKCropAreaPart.RightEdge, AKCropAreaPart.BottomEdge, AKCropAreaPart.LeftEdge]
        default:
            return []
        }
    }
}

let aa:[AKCropAreaPart] = [.TopRightCorner,.BottomLeftCorner]


aa.contains(.TopRightCorner)
aa.contains(.TopEdge)

struct CheckInSteps: OptionSet {
    
    let rawValue: Int
    init(rawValue: Int) { self.rawValue = rawValue }
    
    static let questions = CheckInSteps(rawValue: 0)
    static let rules = CheckInSteps(rawValue: 1)
    static let nda = CheckInSteps(rawValue: 2)
}

let bb: CheckInSteps = [.nda,.rules]


bb.contains(.nda)

bb.contains(.questions)

if bb.contains(.questions) {
   
} else if bb.contains(.rules) {
    
  
} else if bb.contains(.nda) {
  
}


//view.subviews.count

func method() {
    /*var view = UIView()
    
    var anotherView: UIView? {
        willSet {
     
            if anotherView != nil {
                anotherView?.removeFromSuperview()
            }
     
            if newValue != nil {
                view.addSubview(newValue!)
            }
        }
    }
    
    
    anotherView = UIView()
    
    view.subviews.count
    
    anotherView = UIView()
    
    view.subviews.count
    
    
    anotherView = nil*/

//    let v = value
    
    for i in 0...100000 {
        let _ = value * 1000
        
    }
    
}
func reverseFrame(_ frame: CGRect, angle: Double, append edgeInsets: UIEdgeInsets = .zero) -> CGRect  {
    
    var reversedFrame = frame
    
    var reversedInsets: UIEdgeInsets
    
    switch angle {
    case M_PI_2:
        reversedInsets = UIEdgeInsetsMake(
            edgeInsets.right,
            edgeInsets.top,
            edgeInsets.left,
            edgeInsets.bottom)
    case M_PI:
        reversedInsets = UIEdgeInsetsMake(
            edgeInsets.bottom,
            edgeInsets.right,
            edgeInsets.top,
            edgeInsets.left)
    case M_PI_2 * 3:
        reversedInsets = UIEdgeInsetsMake(
            edgeInsets.left,
            edgeInsets.bottom,
            edgeInsets.right,
            edgeInsets.top)
    default:
        reversedInsets = edgeInsets
    }
    
    reversedFrame.origin = CGPoint(x: reversedInsets.left, y: reversedInsets.top)
    reversedFrame.size.width -= reversedInsets.left + reversedInsets.right
    reversedFrame.size.height -= reversedInsets.top + reversedInsets.bottom
    
    return reversedFrame
}

/*
let methodStart = Date()

method()

let methodFinish = Date()
let executionTime = methodFinish.timeIntervalSince(methodStart)
print("Execution time: \(executionTime)")
 

*/
let rect = CGRect(x: 0, y: 0, width: 500, height: 1000)

rect.insetBy(dx: 50, dy: 50)

let insets = UIEdgeInsetsMake(50, 20, 50, 20)

UIEdgeInsetsInsetRect(rect, insets);


//public func UIEdgeInsetsInsetRect(_ rect: CGRect, _ insets: UIEdgeInsets) -> CGRect


print(reverseFrame(rect, angle: 90.0, append: insets))


 // Execution time: 0.0101169943809509






 
