//
//  DemoPullbackVC.swift
//  _idx_TCABootcamp_5E32A508_ios_min12.0
//
//  Created by jefferson.setiawan on 29/06/22.
//

import AsyncDisplayKit
import RxComposableArchitecture
import SharedUI

internal final class DemoPullbackVC: ASDKViewController<ASDisplayNode> {
    private lazy var productCard = ProductCardNode(store: store.scope(
        state: \.productCard,
        action: DemoPullbackAction.productCard
    ))
    
    private let anotherTextNode = ASTextNode2()
    
    private let store: Store<DemoPullbackState, DemoPullbackAction>
    
    internal init(store: Store<DemoPullbackState, DemoPullbackAction>) {
        self.store = store
        super.init(node: ASDisplayNode())
        node.backgroundColor = .baseWhite
        node.automaticallyManagesSubnodes = true
        node.layoutSpecBlock = { [weak self] _, _ in
            guard let self = self else { return ASLayoutSpec() }
            let stack = ASStackLayoutSpec.vertical()
            stack.children = [self.anotherTextNode, self.productCard]
            return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 70, left: 16, bottom: 0, right: 16), child: stack)
        }
        
        bindState()
    }
    
    private func bindState() {
        store.subscribe(\.information)
            .map { NSAttributedString.heading3($0) }
            .subscribe(anotherTextNode.rx.attributedText)
            .disposed(by: rx.disposeBag)
    }
    
    internal override func viewDidLoad() {
        super.viewDidLoad()
        store.send(.didLoad)
    }
    
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

internal final class ProductCardNode: ASDisplayNode {
    private let nameTextNode = ASTextNode2()
    private let priceTextNode = ASTextNode2()
    private let wishlistNode: WishlistNode = {
        let node = WishlistNode()
        node.style.preferredSize = CGSize(squareWithSize: 40)
        return node
    }()
    
    private let store: Store<ProductCardState, ProductCardAction>
    
    internal init(store: Store<ProductCardState, ProductCardAction>) {
        self.store = store
        super.init()
        automaticallyManagesSubnodes = true
        backgroundColor = .baseWhite
        nameTextNode.style.flexGrow = 1
        bindState()
    }
    
    private func bindState() {
        store.subscribe(\.name)
            .map { NSAttributedString.heading2($0) }
            .asDriverOnErrorJustComplete()
            .drive(nameTextNode.rx.attributedText)
            .disposed(by: rx.disposeBag)

        store.subscribe(\.price)
            .map { NSAttributedString.display3("Rp. \($0)") }
            .asDriverOnErrorJustComplete()
            .drive(priceTextNode.rx.attributedText)
            .disposed(by: rx.disposeBag)
        
        store.subscribe(\.isWishlist)
            .subscribe(wishlistNode.rx.isSelected(animated: true))
            .disposed(by: rx.disposeBag)
    }
    
    internal override func didLoad() {
        super.didLoad()
        
        layer.borderColor = UIColor.NN300.cgColor
        layer.borderWidth = 1
        layer.shadowRadius = 2
        layer.shadowColor = UIColor.shadow.cgColor
        layer.cornerRadius = 4
        
        bindAction()
    }
    
    private func bindAction() {
        let wishlistTapGesture = UITapGestureRecognizer()
        wishlistTapGesture.rx.event
            .asDriver()
            .drive(onNext: { [store] _ in
                store.send(.didTapWishlist)
            })
            .disposed(by: rx.disposeBag)
        
        wishlistNode.view.addGestureRecognizer(wishlistTapGesture)
        
        let tapGesture = UITapGestureRecognizer()
        tapGesture.rx.event
            .asDriver()
            .drive(onNext: { [store] _ in
                store.send(.didTap)
            })
            .disposed(by: rx.disposeBag)
        
        view.addGestureRecognizer(tapGesture)
    }
    
    internal override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let hStack = ASStackLayoutSpec.horizontal()
        hStack.children = [nameTextNode, wishlistNode]
        
        let stack = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 8,
            justifyContent: .start,
            alignItems: .stretch,
            children: [hStack, priceTextNode]
        )
        return ASInsetLayoutSpec(insets: UIEdgeInsets(insetsWithInset: 8), child: stack)
    }
}
