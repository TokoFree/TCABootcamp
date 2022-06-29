//
//  DemoForEach+Reducer.swift
//  _idx_TCABootcamp_3A02968E_ios_min12.0
//
//  Created by jefferson.setiawan on 28/06/22.
//

import CasePaths
import RxComposableArchitecture
import RxSwift

internal struct DemoForEachState: Equatable {}

internal enum DemoForEachAction: Equatable {}

internal struct DemoForEachEnvironment {
    internal var loadData: () -> Effect<[DemoItemState]>
}

internal let demoForEachReducer = Reducer<DemoForEachState, DemoForEachAction, DemoForEachEnvironment> { _, _, _ in
    .none
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
