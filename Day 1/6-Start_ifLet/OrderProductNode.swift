//
//  OrderProductNode.swift
//  _idx_TCABootcamp_2051A757_ios_min12.0
//
//  Created by jefferson.setiawan on 23/06/22.
//

import AsyncDisplayKit
import RxComposableArchitecture
import SharedUI

internal struct ProductState: Equatable {
    internal var id: Int
    internal var name: String
    internal var price: Int
}

internal final class OrderProductNode: ASDisplayNode {
    private let productNameNode = ASTextNode2()
    private let priceNode = ASTextNode2()
    
    private let store: Store<ProductState, Never>

    internal init(store: Store<ProductState, Never>) {
        self.store = store
        super.init()
        automaticallyManagesSubnodes = true
        bindState()
    }
    
    private func bindState() {
        store.subscribe(\.name)
            .subscribe(onNext: { [productNameNode] in
                productNameNode.attributedText = .display1($0)
            })
            .disposed(by: rx.disposeBag)
        
        store.subscribe(\.price)
            .subscribe(onNext: { [priceNode] in
                priceNode.attributedText = .display3("Rp \($0)", textStyle: .bold)
            })
            .disposed(by: rx.disposeBag)
    }

    override internal func layoutSpecThatFits(_: ASSizeRange) -> ASLayoutSpec {
        ASStackLayoutSpec(
            direction: .vertical,
            spacing: 8,
            justifyContent: .start,
            alignItems: .stretch,
            children: [productNameNode, priceNode]
        )
    }
}
