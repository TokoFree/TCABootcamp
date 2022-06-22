//
//  CounterNode.swift
//  _idx_TCABootcamp_8B947D03_ios_min12.0
//
//  Created by jefferson.setiawan on 22/06/22.
//

import AsyncDisplayKit
import RxComposableArchitecture
import SharedUI

internal struct CounterState: Equatable {
    internal var number: Int
    internal var errorMessage: String?
    internal var isMinusButtonEnabled: Bool { number > 0 }
}

internal enum CounterAction: Equatable {
    case didTapMinus
    case didTapPlus
    case textDidChange(String)
}

internal final class CounterNode: ASDisplayNode {
    private let textFieldNode: TextFieldNode = {
        let node = TextFieldNode(title: "Your Number", shouldResetErrorMessageAfterTyping: false)
        node.style.width = ASDimensionMakeWithPoints(200)
        node.keyboardType = .numberPad
        return node
    }()

    private let minusBtn = ButtonNode(title: "-")
    private let plusBtn = ButtonNode(title: "+")

    private let store: Store<CounterState, CounterAction>
    internal init(store: Store<CounterState, CounterAction>) {
        self.store = store
        super.init()
        automaticallyManagesSubnodes = true

        bindState()
    }

    private func bindState() {
        store.subscribe(\.number)
            .map(String.init)
            .subscribe(textFieldNode.rx.text)
            .disposed(by: rx.disposeBag)

        store.subscribe(\.isMinusButtonEnabled)
            .subscribe(minusBtn.rx.isEnabled)
            .disposed(by: rx.disposeBag)

        store.subscribe(\.errorMessage)
            .subscribe(textFieldNode.rx.errorMessage)
            .disposed(by: rx.disposeBag)
    }

    override internal func didLoad() {
        super.didLoad()
        minusBtn.rx.tap.asDriverOnErrorJustComplete()
            .drive(onNext: { [store] in
                store.send(.didTapMinus)
            })
            .disposed(by: rx.disposeBag)

        plusBtn.rx.tap.asDriverOnErrorJustComplete()
            .drive(onNext: { [store] in
                store.send(.didTapPlus)
            })
            .disposed(by: rx.disposeBag)

        textFieldNode.rx.text
            .asDriver()
            .drive(onNext: { [store] text in
                store.send(.textDidChange(text))
            })
            .disposed(by: rx.disposeBag)
    }

    override internal func layoutSpecThatFits(_: ASSizeRange) -> ASLayoutSpec {
        let counterStack = ASStackLayoutSpec.horizontal()
        counterStack.spacing = 8
        counterStack.children = [minusBtn, textFieldNode, plusBtn]
        return counterStack
    }
}
