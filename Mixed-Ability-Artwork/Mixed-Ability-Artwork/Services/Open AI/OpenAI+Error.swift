//
//  OpenAI+Types.swift
//  Mixed-Ability-Artwork
//
//  Created by Melanie Kneitmix on 5/24/24.
//

import Foundation

extension OpenAIService {
    
    enum ServiceError: Error {
        case uploadFailed
        case describeFailed
        case pollFailed
        case messagesFailed
        case threadFailed
    }
    
}

// MARK: `LocalizedError`

extension OpenAIService.ServiceError: LocalizedError {
    
    var errorDescription: String? {
        switch self {
        case .uploadFailed: "Failed to upload image"
        case .describeFailed: "Failed to start thread to describe image"
        case .pollFailed: "Failed to poll for response"
        case .messagesFailed: "Failed to get response message"
        case .threadFailed: "Failed to create/run thread"
        }
    }
    
}
