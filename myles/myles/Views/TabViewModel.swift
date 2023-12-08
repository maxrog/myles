//
//  TabViewModel.swift
//  myles
//
//  Created by Max Rogers on 12/8/23.
//

import SwiftUI

// TODO - allow user to set whether this is enabled

enum Tabs: Int {
    case home = 0
    case settings
}

/// View model to persist tab selection
class TabViewModel: ObservableObject {

    /// User's selected tab in main tab view
    @AppStorage(StorageKeys.selectedTabIndex.rawValue) var selectedTabIndex: Int = 0
    
}

fileprivate
enum StorageKeys: String {
    case selectedTabIndex
}
