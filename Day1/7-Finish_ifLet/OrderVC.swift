//
//  OrderVC.swift
//  _idx_TCABootcamp_46CB3511_ios_min12.0
//
//  Created by jefferson.setiawan on 16/06/22.
//

import AsyncDisplayKit
import RxComposableArchitecture
import SharedUI

internal final class OrderVC: ASDKViewController<ASDisplayNode> {
    private lazy var counterNode = CounterNode(store: store.scope(
        state: \.counterState,
        action: OrderAction.counter
    ))

    private let addOrderBtn = ButtonNode(title: "Add Order")
    private var productNode: CardNode?

    private let store: Store<OrderState, OrderAction>

    internal init(store: Store<OrderState, OrderAction>) {
        self.store = store
        super.init(node: ASDisplayNode())
        node.backgroundColor = .baseWhite
        node.automaticallyManagesSubnodes = true
        node.layoutSpecBlock = { [weak self] _, _ in
            guard let self = self else { return ASLayoutSpec() }
            let mainStack = ASStackLayoutSpec.vertical()
            mainStack.spacing = 8
            mainStack.children = [self.productNode, self.counterNode, self.addOrderBtn].compactMap { $0 }
            return ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: .minimumXY, child: mainStack)
        }
        bindState()
    }

    override internal func viewDidLoad() {
        super.viewDidLoad()
        bindAction()
        store.send(.didLoad)
    }

    private func bindState() {
        store.scope(state: \.productState).actionless
            .ifLet(
                then: { [weak self] scopedStore in
                    self?.productNode = CardNode(wrappedNode: OrderProductNode(store: scopedStore))
                    self?.node.setNeedsLayout()
                },
                else: { [weak self] in
                    self?.productNode = nil
                    self?.node.setNeedsLayout()
                }
            )
            .disposed(by: rx.disposeBag)
    }

    private func bindAction() {
        addOrderBtn.rx.tap
            .asDriver()
            .drive(onNext: { [store] in
                store.send(.didTapAddOrder)
            })
            .disposed(by: rx.disposeBag)
    }

    internal required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
