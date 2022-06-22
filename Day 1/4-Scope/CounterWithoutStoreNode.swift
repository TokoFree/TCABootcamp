//
//  CounterWithoutStoreNode.swift
//  _idx_TCABootcamp_787C2DE3_ios_min12.0
//
//  Created by jefferson.setiawan on 22/06/22.
//

import AsyncDisplayKit
import RxCocoa
import SharedUI

internal final class CounterWithoutStoreNode: ASDisplayNode {
    private let textFieldNode: TextFieldNode = {
        let node = TextFieldNode(title: "Your Number", shouldResetErrorMessageAfterTyping: false)
        node.style.width = ASDimensionMakeWithPoints(200)
        node.keyboardType = .numberPad
        return node
    }()

    private let minusBtn = ButtonNode(title: "-")
    private let plusBtn = ButtonNode(title: "+")
    
    internal var onTapPlus: (() -> ())?
    internal var onTapMinus: (() -> ())?
    internal var onTextChanged: ((String) -> ())?
    
    internal var didTapPlusDriver: Driver<Void> {
        plusBtn.rx.tap.asDriver()
    }
    
    internal var didTapMinusDriver: Driver<Void> {
        minusBtn.rx.tap.asDriver()
    }
    
    internal var textDidChangeDriver: Driver<String> {
        textFieldNode.rx.text
            .asDriver()
    }

    internal init(state: CounterState) {
        super.init()
        automaticallyManagesSubnodes = true
        
        update(state)
        
        plusBtn.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                self?.onTapPlus?()
            })
            .disposed(by: rx.disposeBag)
        
        minusBtn.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                self?.onTapMinus?()
            })
            .disposed(by: rx.disposeBag)
        
        textFieldNode.rx.text
            .asDriver()
            .drive(onNext: { [weak self] in
                self?.onTextChanged?($0)
            })
            .disposed(by: rx.disposeBag)
    }
    
    internal func update(_ state: CounterState) {
        textFieldNode.text = String(state.number)
        textFieldNode.errorMessage = state.errorMessage
        minusBtn.isEnabled = state.isMinusButtonEnabled
    }

    override internal func layoutSpecThatFits(_: ASSizeRange) -> ASLayoutSpec {
        let counterStack = ASStackLayoutSpec.horizontal()
        counterStack.spacing = 8
        counterStack.children = [minusBtn, textFieldNode, plusBtn]
        return counterStack
    }
}
