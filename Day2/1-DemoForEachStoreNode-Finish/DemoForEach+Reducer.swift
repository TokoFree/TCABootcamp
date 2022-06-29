//
//  DemoForEach+Reducer.swift
//  _idx_TCABootcamp_3A02968E_ios_min12.0
//
//  Created by jefferson.setiawan on 28/06/22.
//

import CasePaths
import RxComposableArchitecture
import RxSwift

internal struct DemoForEachState: Equatable {
    internal var stackData: IdentifiedArrayOf<DemoItemState> = []
    internal var lastId: Int = 0
}

internal enum DemoForEachAction: Equatable {
    case didLoad
    case shuffle
    case addItem
    case child(id: Int, action: DemoItemAction)

    /// Side Effect
    case receiveData([DemoItemState])
}

internal struct DemoForEachEnvironment {
    internal var loadData: () -> Effect<[DemoItemState]>
}

internal let demoForEachReducer = Reducer<DemoForEachState, DemoForEachAction, DemoForEachEnvironment> { state, action, env in
    switch action {
    case .didLoad:
        return env.loadData()
            .map(DemoForEachAction.receiveData)
            .eraseToEffect()
    case let .receiveData(data):
        state.stackData = IdentifiedArray(data)
        state.lastId = data.count
        return .none
    case .shuffle:
        state.stackData.shuffle()
        return .none
    case .addItem:
        state.lastId += 1
        state.stackData.append(DemoItemState(
            id: state.lastId,
            text: "Data \(state.lastId)",
            isActive: true
        ))
        return .none
    case let .child(id, .remove):
        state.stackData.remove(id: id)
        return .none
    case let .child(id, .toggle):
        state.stackData[id: id]?.isActive.toggle()
        return .none
    }
}

internal struct DemoItemState: Equatable, HashDiffable {
    internal var id: Int
    internal var text: String
    internal var isActive: Bool
}

internal enum DemoItemAction: Equatable {
    case toggle
    case remove
}
