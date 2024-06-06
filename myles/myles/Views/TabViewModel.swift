//
//  TabViewModel.swift
//  myles
//
//  Created by Max Rogers on 12/8/23.
//

import SwiftUI

// TODO - allow user to set whether this is enabled (saving selection)
// TODO - migrate to @Observable once @AppStorage is supported

enum Tabs: Int {
    case activity = 0
    case today
    case metrics
    case settings
}

/// View model to persist tab selection
class TabViewModel: ObservableObject {

    /// User's selected tab in main tab view
    @AppStorage(StorageKeys.selectedTabIndex.rawValue) var selectedTabIndex: Int = 0

}

private
enum StorageKeys: String {
    case selectedTabIndex
}
