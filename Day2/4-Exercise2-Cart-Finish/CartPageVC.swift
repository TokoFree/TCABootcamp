//
//  CartPageVC.swift
//  _idx_TCABootcamp_5E32A508_ios_min12.0
//
//  Created by jefferson.setiawan on 29/06/22.
//

import AsyncDisplayKit
import RxComposableArchitecture
import RxComposableArchitectureUI
import SharedUI
import CustomizableLayout

internal final class CartPageVC: ASDKViewController<ASDisplayNode> {
    private lazy var shopNode = ListStoreNode(
        store: store.scope(state: \.products, action: CartPageAction.product),
        collectionViewLayout: CustomizableLayout.Template.verticalListLayout(spacing: 0, margins: .zero),
        content: ShopProductNode.init
    )
    
    private let totalPriceTextNode = ASTextNode2()
    
    private var errorNode: EmptyStateNode?

    private let loadingNode = CircularActivityIndicatorNode()
    
    private let store: Store<CartPageState, CartPageAction>
    
    internal init(store: Store<CartPageState, CartPageAction>) {
        self.store = store
        super.init(node: ASDisplayNode())
        node.backgroundColor = .baseWhite
        node.automaticallyManagesSubnodes = true
        node.layoutSpecBlock = { [weak self] _, _ in
            guard let self = self else { return ASLayoutSpec() }
            if store.state.isLoading {
                return ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: .minimumXY, child: self.loadingNode)
            }
            if let errorNode = self.errorNode {
                return ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: .minimumXY, child: errorNode)
            }
            let stack = ASStackLayoutSpec.vertical()
            stack.spacing = 8
            stack.children = [self.shopNode, self.totalPriceTextNode]
            stack.style.flexGrow = 1
            return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 10, left: 8, bottom: 0, right: 8), child: stack)
        }
        
        bindState()
    }
    
    internal override func viewDidLoad() {
        super.viewDidLoad()
        store.send(.didLoad)
    }
    
    private func bindState() {
        store.subscribe(\.totalPrice)
            .map {
                let string = NumberFormatter.currencyFormatter().string(for: $0) ?? ""
                return NSAttributedString.heading2("""
                Total Price:
                \(string)
                """)
            }
            .subscribe(totalPriceTextNode.rx.attributedText)
            .disposed(by: rx.disposeBag)
        
        store.subscribe(\.isLoading)
            .subscribe(onNext: { [weak self] in
                if $0 {
                    self?.loadingNode.startAnimating()
                } else {
                    self?.loadingNode.stopAnimating()
                }
                self?.node.setNeedsLayout()
            })
            .disposed(by: rx.disposeBag)

        store.subscribe(\.networkError)
            .subscribe(onNext: { [weak self] error in
                if let error = error {
                    self?.errorNode = EmptyStateNode(imageSource: EmptyStateNode.ImageSource?.some(.image(UIImage(named: error.imageSource))), message: error.message)
                } else {
                    self?.errorNode = nil
                }
                self?.node.setNeedsLayout()
            })
            .disposed(by: rx.disposeBag)
    }
    
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

internal final class ShopProductNode: ASDisplayNode {
    private let nameTextNode = ASTextNode2()
    private let priceNode = ASTextNode2()
    private let toggleNode = ToggleNode()
    
    private let textFieldNode: TextFieldNode = {
        let node = TextFieldNode(title: "Quantity", shouldResetErrorMessageAfterTyping: false)
        node.style.width = ASDimensionMakeWithPoints(70)
        node.keyboardType = .numberPad
        return node
    }()

    private let minusBtn = ButtonNode(title: "-")
    private let plusBtn = ButtonNode(title: "+")
    
    private let deleteButton = ButtonNode(title: "🗑", mode: .ghost(usage: .main))
    
    private let store: Store<ShopProductState, ShopProductAction>
    internal init(store: Store<ShopProductState, ShopProductAction>) {
        self.store = store
        super.init()
        backgroundColor = .baseWhite
        automaticallyManagesSubnodes = true
        nameTextNode.style.flexGrow = 1
        bindState()
    }
    
    override internal func didLoad() {
        super.didLoad()
        bindAction()
    }
    
    private func bindAction() {
        minusBtn.rx.tap.asDriver()
            .drive(onNext: { [store] in
                store.send(.didTapMinus)
            })
            .disposed(by: rx.disposeBag)

        plusBtn.rx.tap.asDriver()
            .drive(onNext: { [store] in
                store.send(.didTapPlus)
            })
            .disposed(by: rx.disposeBag)
        
        deleteButton.rx.tap.asDriver()
            .drive(onNext: { [store] in
                store.send(.didTapDelete)
            })
            .disposed(by: rx.disposeBag)
        
        toggleNode.rx.isSelected
            .asDriver()
            .drive(onNext: { [store] _ in
                store.send(.didTapToggle)
            })
            .disposed(by: rx.disposeBag)

        textFieldNode.rx.text
            .asDriver()
            .drive(onNext: { [store] text in
                store.send(.textDidChange(text))
            })
            .disposed(by: rx.disposeBag)
    }
    
    private func bindState() {
        store.subscribe(\.name)
            .map { NSAttributedString.heading3($0) }
            .subscribe(nameTextNode.rx.attributedText)
        
        store.subscribe(\.quantity)
            .map(String.init)
            .subscribe(textFieldNode.rx.text)
            .disposed(by: rx.disposeBag)
        
        store.subscribe(\.price)
            .map {
                let string = NumberFormatter.currencyFormatter().string(for: $0) ?? ""
                return NSAttributedString.display3(string)
            }
            .subscribe(priceNode.rx.attributedText)
            .disposed(by: rx.disposeBag)
        
        store.subscribe(\.isActive)
            .subscribe(toggleNode.rx.isSelected)
            .disposed(by: rx.disposeBag)
    }
    
    internal override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let infoStack = ASStackLayoutSpec.horizontal()
        infoStack.spacing = 8
        infoStack.alignContent = .spaceBetween
        infoStack.alignItems = .stretch
        infoStack.children = [nameTextNode, toggleNode]
        
        let actionStack = ASStackLayoutSpec.horizontal()
        actionStack.spacing = 8
        actionStack.children = [deleteButton, minusBtn, textFieldNode, plusBtn]
        
        let endActionStack = ASStackLayoutSpec.vertical()
        endActionStack.alignItems = .end
        endActionStack.child = actionStack
        
        let mainStack = ASStackLayoutSpec.vertical()
        mainStack.spacing = 4
        mainStack.children = [infoStack, priceNode, endActionStack]
        
        return mainStack
    }
}
