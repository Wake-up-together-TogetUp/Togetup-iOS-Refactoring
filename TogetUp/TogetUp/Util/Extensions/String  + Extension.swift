//
//  String  + Extension.swift
//  TogetUp
//
//  Created by 이예원 on 8/5/24.
//

import Foundation

extension String {
    func toFormattedDateString(from fromFormat: String, to toFormat: String) -> String? {
        let fromDateFormatter = DateFormatter()
        fromDateFormatter.dateFormat = fromFormat
        
        guard let date = fromDateFormatter.date(from: self) else {
            return nil
        }
        
        let toDateFormatter = DateFormatter()
        toDateFormatter.dateFormat = toFormat
        toDateFormatter.amSymbol = "am"
        toDateFormatter.pmSymbol = "pm"
        toDateFormatter.locale = Locale(identifier: "en_US")
        
        return toDateFormatter.string(from: date)
    }
}
