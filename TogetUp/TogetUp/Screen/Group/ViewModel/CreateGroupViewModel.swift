//
//  CreateGroupViewModel.swift
//  TogetUp
//
//  Created by nayeon  on 3/26/24.
//

import RxSwift
import RxCocoa

class CreateGroupViewModel: ViewModelType {
    struct Input {
        let groupName: Observable<String>
        let groupIntro: Observable<String>
        let nextButtonTapped: Observable<Void>
    }
    
    struct Output {
        let isNextButtonEnabled: Observable<Bool>
        let groupName: Observable<String>
        let groupIntro: Observable<String>
    }
    
    var disposeBag = DisposeBag()

    func transform(input: Input) -> Output {
        let isNextButtonEnabled = Observable.combineLatest(input.groupName, input.groupIntro)
            .map { !$0.isEmpty && !$1.isEmpty }
            .startWith(false)
        
        return Output(
            isNextButtonEnabled: isNextButtonEnabled,
            groupName: input.groupName,
            groupIntro: input.groupIntro
        )
    }
}
