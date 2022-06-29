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
    private lazy var shopNode = ASDisplayNode()
    
    private let totalPriceTextNode = ASTextNode2()
    
    private let store: Store<CartPageState, CartPageAction>
    internal init(store: Store<CartPageState, CartPageAction>) {
        self.store = store
        super.init(node: ASDisplayNode())
        node.backgroundColor = .baseWhite
        node.automaticallyManagesSubnodes = true
        node.layoutSpecBlock = { [weak self] _, _ in
            guard let self = self else { return ASLayoutSpec() }
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
        let string = NumberFormatter.currencyFormatter().string(for: 10000) ?? ""
        totalPriceTextNode.attributedText = NSAttributedString.heading2("""
        Total Price:
        \(string)
        """)
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
    
    private let state: ShopProductState
    internal init(state: ShopProductState) {
        self.state = state
        super.init()
        backgroundColor = .baseWhite
        automaticallyManagesSubnodes = true
        nameTextNode.style.flexGrow = 1
        bindState()
    }
    
    override internal func didLoad() {
        super.didLoad()
        minusBtn.rx.tap.asDriver()
            .drive(onNext: { _ in
                print(".didTapMinus")
            })
            .disposed(by: rx.disposeBag)

        plusBtn.rx.tap.asDriver()
            .drive(onNext: { _ in
                print(".didTapPlus")
            })
            .disposed(by: rx.disposeBag)
        
        deleteButton.rx.tap.asDriver()
            .drive(onNext: { _ in
                print(".didTapDelete")
            })
            .disposed(by: rx.disposeBag)
        
        toggleNode.rx.isSelected
            .asDriver()
            .drive(onNext: { _ in
                print(".didTapToggle")
            })
            .disposed(by: rx.disposeBag)

        textFieldNode.rx.text
            .asDriver()
            .drive(onNext: { text in
                print(".textDidChange(\(text)")
            })
            .disposed(by: rx.disposeBag)
    }
    
    private func bindState() {
        nameTextNode.attributedText = .heading3(state.name)
        
        textFieldNode.text = String(state.quantity)
        
        priceNode.attributedText = .display3(NumberFormatter.currencyFormatter().string(for: state.price) ?? "")
        
        toggleNode.isSelected = state.isActive
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
