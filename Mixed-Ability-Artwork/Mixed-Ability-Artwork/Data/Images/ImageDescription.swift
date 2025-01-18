import Foundation
import UIKit
import SwiftUI

struct ImageDescription: Hashable {
    
    // MARK: Properties
    
    var id: String
    //var threadID: String
    let uiImage: UIImage
    var descriptiveDescription: String
    var creativeDescription: String
    var questions: String
    
    // MARK: Artwork Metadata
    
    var name: String? // TODO: make use across app
    var author: String? // TODO: make use across app
    var dateTaken: Date? // TODO: make use across app

    var image: Image {
        return Image(uiImage: uiImage)
    }
}
