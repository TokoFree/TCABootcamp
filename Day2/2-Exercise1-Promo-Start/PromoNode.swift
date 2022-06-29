//
//  PromoNode.swift
//  _idx_TCABootcamp_7583B6FD_ios_min12.0
//
//  Created by jefferson.setiawan on 28/06/22.
//

import AsyncDisplayKit
import RxComposableArchitecture

internal struct PromoState: Equatable, HashDiffable {
    internal var id: String
    internal var title: String
    internal var amount: Int
    internal var isSelected = false
}

internal enum PromoAction: Equatable {
    case didTap
}

internal final class PromoNode: ASDisplayNode {
    private let titleNode = ASTextNode2()
    private let descriptionNode = ASTextNode2()
    private let state: PromoState
    internal init(state: PromoState) {
        self.state = state
        super.init()
        automaticallyManagesSubnodes = true
        bindState()
    }
    
    private func bindState() {
        titleNode.attributedText = .heading2(state.title)
        descriptionNode.attributedText = .display3(String("Discount Rp. \(state.amount)"))
        backgroundColor = state.isSelected ? .GN50 : .baseWhite
    }
    
    internal override func didLoad() {
        super.didLoad()
        layer.borderWidth = 1
        layer.shadowRadius = 2
        layer.shadowColor = UIColor.shadow.cgColor
        layer.cornerRadius = 4
        let tapGesture = UITapGestureRecognizer()
        tapGesture.rx.event
            .asDriver()
            .drive(onNext: { _ in
                print("TAPPED!")
            })
            .disposed(by: rx.disposeBag)
        view.addGestureRecognizer(tapGesture)
    }
    
    internal override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let stack = ASStackLayoutSpec(direction: .vertical, spacing: 4, justifyContent: .start, alignItems: .stretch, children: [titleNode, descriptionNode])
        return ASInsetLayoutSpec(insets: UIEdgeInsets(insetsWithInset: 4), child: stack)
    }
}
