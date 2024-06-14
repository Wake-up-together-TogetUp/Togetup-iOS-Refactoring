//
//  ViewModelType.swift
//  TogetUp
//
//  Created by nayeon  on 5/20/24.
//

import Foundation
import RxSwift

protocol ViewModelType {

    associatedtype Input
    associatedtype Output

    var disposeBag: DisposeBag { get set }

    func transform(input: Input) -> Output
}
