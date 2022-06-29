//
//  DemoForEachVC.swift
//  _idx_TCABootcamp_3A02968E_ios_min12.0
//
//  Created by jefferson.setiawan on 28/06/22.
//

import AsyncDisplayKit
import RxComposableArchitecture
import RxComposableArchitectureUI
import RxExtension
import SharedUI

internal final class DemoForEachVC: ASDKViewController<ASDisplayNode> {
    private lazy var scrollNode: ASScrollNode = {
        let node = ASScrollNode()
        node.backgroundColor = .baseWhite
        node.scrollableDirections = [.up, .down]
        node.automaticallyManagesSubnodes = true
        node.automaticallyManagesContentSize = true
        node.layoutSpecBlock = { [weak self] _, _ in
            guard let self = self else { return ASLayoutSpec() }

            let mainStack = ASStackLayoutSpec.vertical()
            mainStack.spacing = 4
            mainStack.alignItems = .stretch
            mainStack.children = [self.nodes, self.shuffleBtn, self.addMoreItemBtn]
            return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16), child: mainStack)
        }
        return node
    }()

    private lazy var nodes = ForEachStoreNode(
        store: self.store.scope(
            state: \.stackData,
            action: DemoForEachAction.child
        ),
        layoutSpecOptions: LayoutSpecOptions(stackDirection: .vertical)
    ) { store in
        DemoItemNode(store: store)
    }

    private let shuffleBtn = ButtonNode(title: "Shuffle")

    private let addMoreItemBtn = ButtonNode(title: "+ More Item")

    private let store: Store<DemoForEachState, DemoForEachAction>

    internal init(store: Store<DemoForEachState, DemoForEachAction>) {
        self.store = store
        super.init(node: ASDisplayNode())
        
        node.automaticallyManagesSubnodes = true
        node.layoutSpecBlock = { [weak self] _, _ in
            guard let self = self else { return ASLayoutSpec() }

            return ASWrapperLayoutSpec(layoutElement: self.scrollNode)
        }
    }

    override internal func viewDidLoad() {
        super.viewDidLoad()
        bindAction()
    }

    private func bindAction() {
        shuffleBtn.rx.tap.asDriverOnErrorJustComplete()
            .drive(onNext: { [store] in
                store.send(.shuffle)
            })
            .disposed(by: rx.disposeBag)
        addMoreItemBtn.rx.tap.asDriverOnErrorJustComplete()
            .drive(onNext: { [store] in
                store.send(.addItem)
            })
            .disposed(by: rx.disposeBag)
        
        store.send(.didLoad)
    }

    internal required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

internal final class DemoItemNode: ASDisplayNode {
    private let textNode = ASTextNode2()
    private let store: Store<DemoItemState, DemoItemAction>

    private let isActiveButton: ASButtonNode = {
        let btn = ASButtonNode()
        btn.setTitle("Active", with: .systemFont(ofSize: 12), with: .black, for: .normal)
        return btn
    }()

    private let removeButton: ASButtonNode = {
        let btn = ASButtonNode()
        btn.setTitle("🗑", with: .systemFont(ofSize: 12), with: .black, for: .normal)
        return btn
    }()

    internal init(store: Store<DemoItemState, DemoItemAction>) {
        self.store = store
        super.init()
        automaticallyManagesSubnodes = true
        style.height = ASDimensionMake(50)
    }

    override internal func didLoad() {
        super.didLoad()
        borderWidth = 1
        borderColor = UIColor.GN300.cgColor
        layer.cornerRadius = 8
        bindState()
        bindAction()
    }

    private func bindState() {
        store.subscribe(\.text)
            .map { NSAttributedString.body2($0) }
            .asDriverOnErrorJustComplete()
            .drive(textNode.rx.attributedText)
            .disposed(by: rx.disposeBag)

        store.subscribe(\.isActive)
            .asDriverOnErrorJustComplete()
            .drive(onNext: { [isActiveButton] isActive in
                isActiveButton.setTitle(isActive ? "✅" : "❌", with: .body1(), with: .n700A96, for: .normal)
                self.setNeedsLayout()
            })
            .disposed(by: rx.disposeBag)
    }
    
    private func bindAction() {
        isActiveButton.rx.tap.asDriverOnErrorJustComplete()
            .drive(onNext: { [store] in
                store.send(.toggle)
            })
            .disposed(by: rx.disposeBag)

        removeButton.rx.tap.asDriverOnErrorJustComplete()
            .drive(onNext: { [store] in
                store.send(.remove)
            })
            .disposed(by: rx.disposeBag)
    }

    override internal func layoutSpecThatFits(_: ASSizeRange) -> ASLayoutSpec {
        let stack = ASStackLayoutSpec(
            direction: .horizontal,
            spacing: 8,
            justifyContent: .spaceBetween,
            alignItems: .center,
            children: [textNode, isActiveButton, removeButton]
        )
        return ASInsetLayoutSpec(insets: UIEdgeInsets(insetsWithInset: 4), child: stack)
    }
}
