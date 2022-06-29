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
            mainStack.children = [self.nodes]
            return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16), child: mainStack)
        }
        return node
    }()

    private lazy var nodes = ASDisplayNode()

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
        
        let shuffleButton = UIBarButtonItem(title: "Shuffle", style: .plain, target: nil, action: nil)
        let addButton = UIBarButtonItem(title: "Add", style: .plain, target: nil, action: nil)
        navigationItem.rightBarButtonItems = [shuffleButton, addButton]
        
        shuffleButton.rx.tap
            .asDriver()
            .drive(onNext: { [store] in
                print(".shuffle")
            })
            .disposed(by: rx.disposeBag)
        
        addButton.rx.tap
            .asDriver()
            .drive(onNext: { [store] in
                print(".addItem")
            })
            .disposed(by: rx.disposeBag)
    }

    internal required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
