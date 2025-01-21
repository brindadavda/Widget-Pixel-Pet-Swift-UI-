//
//  UIDevice+Extensions.swift
//  Tamagochi
//
//  Created by Systems
//

import UIKit

typealias UIDevice_TamagochiVVV = UIDevice

extension UIDevice_TamagochiVVV {
    
    var systemSize: String {
        guard let systemAttributes = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory() as String),
            let totalSize = (systemAttributes[.systemSize] as? NSNumber)?.int64Value else {
                return ""
        }

        return ByteCountFormatter.string(fromByteCount: totalSize, countStyle: ByteCountFormatter.CountStyle.binary)
    }

    var systemFreeSize: String {
        guard let systemAttributes = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory() as String),
            let freeSize = (systemAttributes[.systemFreeSize] as? NSNumber)?.int64Value else {
                return ""
        }
        return ByteCountFormatter.string(fromByteCount: freeSize, countStyle: ByteCountFormatter.CountStyle.binary)
    }
    
    @available(iOSApplicationExtension, unavailable)
    var hasDynamicIsland: Bool {
        guard userInterfaceIdiom == .phone else {
            return false
        }
        guard let window = (UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.flatMap { $0.windows }.first { $0.isKeyWindow}) else {
            print("Do not found key window")
            return false
        }
        return window.safeAreaInsets.top >= 51
    }
    
    @available(iOSApplicationExtension, unavailable)
    var hasPhysicalButton: Bool {
        if let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }) {
            return windowScene.windows
                .map { $0.safeAreaInsets.bottom }
                .contains(where: { $0 == 0 })
        }
        return false
    }
    
}
