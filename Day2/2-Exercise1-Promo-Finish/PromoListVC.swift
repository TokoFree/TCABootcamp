//
//  PromoListVC.swift
//  _idx_TCABootcamp_7583B6FD_ios_min12.0
//
//  Created by jefferson.setiawan on 28/06/22.
//

import AsyncDisplayKit
import RxComposableArchitecture
import RxComposableArchitectureUI
import SharedUI

internal final class PromoListVC: ASDKViewController<ASDisplayNode> {
    private lazy var scrollNode: ASScrollNode = {
        let node = ASScrollNode()
        node.automaticallyManagesContentSize = true
        node.automaticallyManagesSubnodes = true
        node.layoutSpecBlock = { [weak self] _, _ in
            guard let self = self else { return ASLayoutSpec() }
            let selectedStack = ASStackLayoutSpec.vertical()
            selectedStack.children = [self.selectedPromoCaptionNode, self.selectedPromoNode, self.usePromoButton, self.dividerNode]
            let stack = ASStackLayoutSpec.vertical()
            stack.spacing = 32
            stack.children = [selectedStack, self.promoListNode]
            return stack
        }
        return node
    }()
    
    private let dividerNode = DividerNode()
    
    private lazy var promoListNode = ForEachStoreNode(
        store: store.scope(
            state: \.promos, 
            action: PromoListAction.promo
        ),
        node: PromoNode.init
    )
    private let selectedPromoCaptionNode: ASTextNode2 = {
        let node = ASTextNode2()
        node.attributedText = .heading3("Current Selected Promo: ")
        return node
    }()
    private let selectedPromoNode = ASTextNode2()
    
    private let usePromoButton = ButtonNode(title: "Apply")
    
    private let store: Store<PromoListState, PromoListAction>
    
    internal init(store: Store<PromoListState, PromoListAction>) {
        self.store = store
        super.init(node: ASDisplayNode())
        node.automaticallyManagesSubnodes = true
        node.backgroundColor = .baseWhite
        node.layoutSpecBlock = { [weak self] _, _ in
            guard let self = self else { return ASLayoutSpec() }
            return ASWrapperLayoutSpec(layoutElement: self.scrollNode)
        }
        
        bindState()
    }
    
    private func bindState() {
        store.subscribe(\.selectedPromoState)
            .subscribe(onNext: { [selectedPromoNode] in
                selectedPromoNode.attributedText = .heading2($0?.title ?? "None")
            })
            .disposed(by: rx.disposeBag)
    }
    
    internal convenience override init() {
        self.init(store: Store(
            initialState: PromoListState(selectedPromoId: "3"),
            reducer: promoListReducer,
            environment: .mock
        ))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal override func viewDidLoad() {
        super.viewDidLoad()
        usePromoButton.rx.tap.asDriver()
            .drive(onNext: { [store] in
                store.send(.didTapUsePromo)
            })
            .disposed(by: rx.disposeBag)
        store.send(.didLoad)
    }
}

