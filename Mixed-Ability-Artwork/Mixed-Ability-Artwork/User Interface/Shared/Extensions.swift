//
//  Extensions.swift
//  Mixed-Ability-Artwork
//
//  Created by Ritesh Kanchi on 7/26/24.
//

import Foundation
import UIKit
import SwiftUI

extension UIImage: Identifiable { }
extension ImageDescription: Identifiable { }

extension PresentationDetent: CustomStringConvertible {
    public var description: String {
        switch self {
        case .small:
            return "Small"
        case .medium:
            return "Medium"
        case .large:
            return "Large"
        default:
            return "n/a"
        }
    }
}

extension PresentationDetent {
    static var small: PresentationDetent {
        .fraction(0.25)
    }
}

extension UINavigationController: UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}
