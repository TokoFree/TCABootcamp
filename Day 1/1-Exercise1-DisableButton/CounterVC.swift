//
//  CounterVC.swift
//  _idx_TCABootcamp_46CB3511_ios_min12.0
//
//  Created by jefferson.setiawan on 16/06/22.
//

import AsyncDisplayKit
import RxComposableArchitecture
import SharedUI

internal final class CounterVC: ASDKViewController<ASDisplayNode> {
    private let textFieldNode: TextFieldNode = {
        let node = TextFieldNode(title: "Your Number")
        node.isEnabled = false
        node.style.width = ASDimensionMakeWithPoints(200)
        return node
    }()

    private let minusBtn = ButtonNode(title: "-")
    private let plusBtn = ButtonNode(title: "+")

    private let store: Store<CounterState, CounterAction>

    internal init(store: Store<CounterState, CounterAction>) {
        self.store = store
        super.init(node: ASDisplayNode())
        node.backgroundColor = .baseWhite
        node.automaticallyManagesSubnodes = true
        node.layoutSpecBlock = { [weak self] _, _ in
            guard let self = self else { return ASLayoutSpec() }

            let counterStack = ASStackLayoutSpec.horizontal()
            counterStack.spacing = 8
            counterStack.children = [self.minusBtn, self.textFieldNode, self.plusBtn]
            return ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: .minimumXY, child: counterStack)
        }
        bindState()
    }

    override internal func viewDidLoad() {
        super.viewDidLoad()
        bindAction()
    }

    private func bindAction() {
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
    }

    private func bindState() {
        store.subscribe(\.number)
            .subscribe(onNext: { [textFieldNode] text in
                textFieldNode.text = String(text)
            })
            .disposed(by: rx.disposeBag)
        
        store.subscribe(\.isMinusButtonEnabled)
            .subscribe(minusBtn.rx.isEnabled)
            .disposed(by: rx.disposeBag)
    }

    internal required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
