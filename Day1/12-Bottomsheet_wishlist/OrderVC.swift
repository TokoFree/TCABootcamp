//
//  OrderVC.swift
//  _idx_TCABootcamp_46CB3511_ios_min12.0
//
//  Created by jefferson.setiawan on 16/06/22.
//

import AsyncDisplayKit
import RxComposableArchitecture
import SharedUI

internal final class OrderVC: ASDKViewController<ASDisplayNode> {
    private lazy var counterNode = CounterNode(store: store.scope(
        state: \.counterState,
        action: OrderAction.counter
    ))

    private let addOrderBtn = ButtonNode(title: "Add Order")
    private var productNode: CardNode?

    private var errorNode: EmptyStateNode?

    private let loadingNode = CircularActivityIndicatorNode()

    private let store: Store<OrderState, OrderAction>

    internal init(store: Store<OrderState, OrderAction>) {
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
            if let productNode = self.productNode {
                let mainStack = ASStackLayoutSpec.vertical()
                mainStack.spacing = 8
                mainStack.children = [productNode, self.counterNode, self.addOrderBtn]
                return ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: .minimumXY, child: mainStack)
            }
            return ASLayoutSpec()
        }
        bindState()
    }

    override internal func viewDidLoad() {
        super.viewDidLoad()
        bindAction()
        store.send(.didLoad)
    }

    private func bindState() {
        store.scope(state: \.productState, action: OrderAction.productInfo)
            .ifLet(
                then: { [weak self] scopedStore in
                    self?.productNode = CardNode(wrappedNode: OrderProductNode(store: scopedStore))
                    self?.node.setNeedsLayout()
                },
                else: { [weak self] in
                    self?.productNode = nil
                    self?.node.setNeedsLayout()
                }
            )
            .disposed(by: rx.disposeBag)

        store.subscribe(\.isLoading)
            .subscribe(onNext: { [weak self] in
                if $0 {
                    self?.loadingNode.startAnimating()
                } else {
                    self?.loadingNode.stopAnimating()
                }
            })
            .disposed(by: rx.disposeBag)

        store.subscribe(\.networkError)
            .subscribe(onNext: { [weak self] error in
                if let error = error {
                    self?.errorNode = EmptyStateNode(imageSource: EmptyStateNode.ImageSource?.some(.image(UIImage(named: error.imageSource))), message: error.message)
                    self?.node.setNeedsLayout()
                }
            })
            .disposed(by: rx.disposeBag)

        store.scope(state: \.bottomSheetState, action: OrderAction.bottomSheet)
            .ifLet(
                then: { [weak self] scopedStore in
                    let vc = ProductDetailInfoVC(store: scopedStore)
                    self?.navigationController?.present(
                        BottomSheetViewController(wrapping: vc),
                        animated: true,
                        onDismiss: {
                            self?.store.send(.dismissBottomSheet)
                        }
                    )
                }
            )
            .disposed(by: rx.disposeBag)
    }

    private func bindAction() {
        addOrderBtn.rx.tap
            .asDriver()
            .drive(onNext: { [store] in
                store.send(.didTapAddOrder)
            })
            .disposed(by: rx.disposeBag)
    }

    internal required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
