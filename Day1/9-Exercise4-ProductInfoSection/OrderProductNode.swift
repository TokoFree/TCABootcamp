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

    internal init(state: ProductState) {
        super.init()
        automaticallyManagesSubnodes = true
        productNameNode.attributedText = .display1(state.name)
        priceNode.attributedText = .display3("Rp \(state.price)", textStyle: .bold)
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
