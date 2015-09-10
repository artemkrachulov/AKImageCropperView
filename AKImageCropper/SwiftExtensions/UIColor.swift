//
//  UIColor.swift
//  Extension file
//
//  Created by Krachulov Artem
//  Copyright (c) 2015 The Krachulovs. All rights reserved.
//  Website: http://www.artemkrachulov.com/
//

import UIKit

extension UIColor {
    
    /// Convert RGBA value to HEX
    ///
    /// Usage:
    ///
    ///  UIColor(red: 1, green: 0.8, blue: 0.6, alpha: 0.2).toHex() // #FFCC9933
    ///  UIColor(red: 1, green: 0.8, blue: 0.6, alpha: 1).toHex() // #FFCC99
    
    func toHex() -> String {
        
        let rgbaComponents = CGColorGetComponents(self.CGColor)
        var hex = "#"
        
        for index in 0...3 {
            
            let value = UInt8(rgbaComponents[index] * 255)
            
            if (index == 3 && value == 255) == false {
                
                hex += String(format:"%0.2X", value)
            }
        }
        return hex
    }
    
    /// Convert HEX value to RGBA
    ///
    /// Supported single and multiple HEX character. Supported lowercase and uppercase HEX characters
    /// Default value for alpha is 1
    ///
    /// Usage:
    ///
    ///  var rgba = UIColor().fromHex(hex: "#FC9") // UIColor(red: 1.0, green: 0.8, blue: 0.6, alpha: 1)
    ///  var rgba = UIColor().fromHex(hex: "#FFCC99") // UIColor(red: 1.0, green: 0.8, blue: 0.6, alpha: 1)
    ///  var rgba = UIColor().fromHex(hex: "#FC93") // UIColor(red: 1.0, green: 0.8, blue: 0.6, alpha: 0.2)
    ///  var rgba = UIColor().fromHex(hex: "#FFCC9933") // UIColor(red: 1.0, green: 0.8, blue: 0.6, alpha: 0.2)
    
    func fromHex(#hex: String) -> UIColor! {
        
        let hex = hex.lowercaseString
        let hexCharSet = NSCharacterSet(charactersInString: "#0123456789abcdef")
        
        if hex.rangeOfCharacterFromSet(hexCharSet.invertedSet, options: .CaseInsensitiveSearch) != nil {
            
            println("Error: Unknown character in HEX string \(hex)")
            
        } else {
            if hex.substringToIndex(advance(hex.startIndex, 1)) == "#" {
                
                let hexLength = count(hex)
                
                if hexLength < 4 || hexLength == 6 || hexLength == 8 || hexLength > 9  {
                    
                    println("Error: Unknown HEX length \(hex)")
                    
                } else {
                    
                    var red: CGFloat = 255
                    var green: CGFloat = 255
                    var blue: CGFloat = 255
                    var alpha: CGFloat = 255
                    
                    // Range for paired or unpaired hex chars
                    let range = hexLength == 5 || hexLength == 9 ? 3 : 2
                    
                    // Multiplyer if we need duplicate hex char
                    let multiply = hexLength == 4 || hexLength == 5 ? 1 : 2
                    
                    for index in 0...range {
                        
                        var hexChar = hex.substringWithRange(Range(start: advance(hex.startIndex, multiply * index + 1), end: advance(hex.startIndex, multiply * index + 1 + multiply)))
                        
                        // Duplicate char
                        if multiply == 1 {
                            
                            hexChar += hexChar
                        }
                        
                        /// strtoul - Convert string to unsigned long integer
                        ///
                        /// Parses the C-string str, interpreting its content as an integral number of the specified base, which is returned as an value of type unsigned long int. This function operates like strtol to interpret the string, but produces numbers of type unsigned long int (see strtol for details on the interpretation process).
                        let value = CGFloat(strtoul(hexChar, nil, 16))
                        
                        switch index {
                        case 0:  red = value
                        case 1:  green = value
                        case 2:  blue = value
                        case 3: alpha = value
                        default: ()
                        }
                    }
                    
                    return UIColor(red: red / 255, green: green / 255, blue: blue / 255, alpha: alpha / 255)
                }
            } else {
                
                println("Error: HEX without \"#\"")
            }
        }
        return nil
    }
}
