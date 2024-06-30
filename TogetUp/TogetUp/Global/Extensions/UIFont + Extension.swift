//
//  UIFont + Extension.swift
//  TogetUp
//
//  Created by 이예원 on 6/30/24.
//

import UIKit

extension UIFont {
    public enum FontType: String {
        case extraBold = "ExtraBold"
        case bold = "Bold"
        case semiBold = "SemiBold"
        case regular = "Regular"
    }
    
    static func AppleSDGothicNeo(_ type: FontType, size: CGFloat) -> UIFont {
        return UIFont(name: "AppleSDGothicNeo-\(type.rawValue)", size: size) ?? UIFont.systemFont(ofSize: size, weight: type == .bold ? .bold : .medium)
    }
    
    // Title
    class var titleBLarge: UIFont { return AppleSDGothicNeo(.extraBold, size: 30) }
    class var titleMLarge: UIFont { return AppleSDGothicNeo(.extraBold, size: 26) }
    class var titleLarge: UIFont { return AppleSDGothicNeo(.extraBold, size: 20) }
    class var titleMedium: UIFont { return AppleSDGothicNeo(.extraBold, size: 18) }
    class var titleSmall: UIFont { return AppleSDGothicNeo(.bold, size: 14) }
    
    // Label
    class var labelMLarge: UIFont { return AppleSDGothicNeo(.semiBold, size: 16) }
    class var labelLarge: UIFont { return AppleSDGothicNeo(.semiBold, size: 14) }
    class var labelMedium: UIFont { return AppleSDGothicNeo(.semiBold, size: 12) }
    class var labelSmall: UIFont { return AppleSDGothicNeo(.semiBold, size: 11) }
    
    // Body
    class var bodyLarge: UIFont { return AppleSDGothicNeo(.regular, size: 16) }
    class var bodyMedium: UIFont { return AppleSDGothicNeo(.regular, size: 14) }
    class var bodySmall: UIFont { return AppleSDGothicNeo(.regular, size: 12) }
    
    // Button
    class var buttonLarge: UIFont { return AppleSDGothicNeo(.bold, size: 18) }
    class var buttonMedium: UIFont { return AppleSDGothicNeo(.bold, size: 16) }
    class var buttonSmall: UIFont { return AppleSDGothicNeo(.bold, size: 14) }
}
