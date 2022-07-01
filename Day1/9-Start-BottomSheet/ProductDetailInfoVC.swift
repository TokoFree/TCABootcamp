//
//  ProductDetailInfoVC.swift
//  _idx_TCABootcamp_1FCF754C_ios_min12.0
//
//  Created by jefferson.setiawan on 26/06/22.
//

import AsyncDisplayKit
import RxComposableArchitecture
import SharedUI

internal struct ProductDetailState: Equatable {
    internal var name: String
    internal var price: Int
    internal var description: String
    internal var isWishlist: Bool
}

internal final class ProductDetailInfoVC: ASDKViewController<ASDisplayNode> {
    private let productNameNode = ASTextNode2()
    private let priceNode = ASTextNode2()
    private let descriptionNode = ASTextNode2()

    private let store: Store<ProductDetailState, Never>

    internal init(store: Store<ProductDetailState, Never>) {
        self.store = store
        super.init(node: ASDisplayNode())
        node.backgroundColor = .baseWhite
        node.automaticallyManagesSubnodes = true
        node.layoutSpecBlock = { [weak self] _, _ in
            guard let self = self else { return ASLayoutSpec() }
            let mainInfoStack = ASStackLayoutSpec.vertical()
            mainInfoStack.children = [self.productNameNode, self.priceNode]
            mainInfoStack.style.flexGrow = 1
            let hStack = ASStackLayoutSpec.horizontal()
            hStack.children = [mainInfoStack]
            let mainStack = ASStackLayoutSpec.vertical()
            mainStack.spacing = 8
            mainStack.children = [hStack, self.descriptionNode]
            return mainStack
        }
        bindState()
    }

    override internal func viewDidLoad() {
        super.viewDidLoad()
    }

    internal required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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

        store.subscribe(\.description)
            .subscribe(onNext: { [descriptionNode] in
                descriptionNode.attributedText = .display3($0, textStyle: .bold)
            })
            .disposed(by: rx.disposeBag)
    }
}
