//
//  NetworkStateMonitorConnector.swift
//  Tamagochi
//
//  Created by Tim Akhmetov on 12.08.2024.
//

import SwiftUI
import Network

fileprivate var networkStateMonitorConnector = "NetworkStateMonitorConnector"

class NetworkStateMonitorConnector: ObservableObject {
    private var networkStateMonitorConnector = "NetworkStateMonitorConnector"
    
    private let networkMonitor = NWPathMonitor()
    private let workerQueue = DispatchQueue(label: "Monitor")
    var isConnected = false

    init() {
        networkMonitor.pathUpdateHandler = { path in
            self.isConnected = path.status == .satisfied
            Task {
                await MainActor.run {
                    self.objectWillChange.send()
                }
            }
        }
        networkMonitor.start(queue: workerQueue)
    }
}
