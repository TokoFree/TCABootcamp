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
    private let store: Store<PromoState, PromoAction>
    internal init(store: Store<PromoState, PromoAction>) {
        self.store = store
        super.init()
        automaticallyManagesSubnodes = true
        bindState()
    }
    
    private func bindState() {
        store.subscribe(\.title)
            .subscribe(onNext: { [titleNode] in
                titleNode.attributedText = .heading2($0)
            })
            .disposed(by: rx.disposeBag)
        
        store.subscribe(\.amount)
            .subscribe(onNext: { [descriptionNode] in
                descriptionNode.attributedText = .display3(String("Discount Rp. \($0)"))
            })
            .disposed(by: rx.disposeBag)
        
        store.subscribe(\.isSelected)
            .subscribe(onNext: { [weak self] isSelected in
                self?.backgroundColor = isSelected ? .GN50 : .baseWhite
            })
            .disposed(by: rx.disposeBag)
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
            .drive(onNext: { [store] _ in
                store.send(.didTap)
            })
            .disposed(by: rx.disposeBag)
        view.addGestureRecognizer(tapGesture)
    }
    
    internal override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let stack = ASStackLayoutSpec(direction: .vertical, spacing: 4, justifyContent: .start, alignItems: .stretch, children: [titleNode, descriptionNode])
        return ASInsetLayoutSpec(insets: UIEdgeInsets(insetsWithInset: 4), child: stack)
    }
}
