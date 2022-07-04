enum ItemCellType: Equatable, HashDiffable {
    case promo(PromoState)
    case ads(AdsState)
    
    internal var id: String {
        switch self {
        case .promo(let promoState):
            return promoState.id
        case .ads(let adsState):
            return adsState.name
        }
    }
}

internal struct AdsState: Equatable {
    internal var name: String
}

internal enum AdsAction: Equatable {
    case didTap
}

internal final class AdsNode: ASDisplayNode {
    private let imageNode: ASImageNode = {
        let image = ASImageNode()
        image.image = UIImage(unifyIcon: .promo_ads_filled)
        image.style.preferredSize = CGSize(squareWithSize: 40)
        return image
    }()
    private let titleNode = ASTextNode2()
    private let store: Store<AdsState, AdsAction>
    internal init(store: Store<AdsState, AdsAction>) {
        self.store = store
        super.init()
        automaticallyManagesSubnodes = true
        bindState()
    }
    
    private func bindState() {
        store.subscribe(\.name)
            .subscribe(onNext: { [titleNode] in
                titleNode.attributedText = .heading2("This is Ads for \($0)")
            })
            .disposed(by: rx.disposeBag)
    }
    
    internal override func didLoad() {
        super.didLoad()
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
        let stack = ASStackLayoutSpec(direction: .horizontal, spacing: 4, justifyContent: .start, alignItems: .stretch, children: [imageNode, titleNode])
        return ASInsetLayoutSpec(insets: UIEdgeInsets(insetsWithInset: 4), child: stack)
    }
}
