//
//  Reactive + Extension.swift
//  TogetUp
//
//  Created by nayeon  on 7/15/24.
//

import RxSwift
import RxCocoa
import UIKit

extension Reactive where Base: UIViewController {
    var viewWillAppear: ControlEvent<Void> {
        let source = self.methodInvoked(#selector(Base.viewWillAppear(_:))).map { _ in }
        return ControlEvent(events: source)
    }
}
