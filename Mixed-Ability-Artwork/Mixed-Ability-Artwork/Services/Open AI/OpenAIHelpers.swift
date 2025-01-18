//
//  OpenAIHelpers.swift
//  Mixed-Ability-Artwork
//
//  Created by Ritesh Kanchi on 8/9/24.
//

import Foundation
import UIKit

class OpenAIHelpers {
    
    typealias StringCompletion = (String) -> Void
    typealias VoidCompletion = () -> Void
    typealias FailureCompletion = (OpenAIService.ServiceError) -> Void
    
    static let shared = OpenAIHelpers()
    
    private func handleResult<T>(
        result: Result<T, OpenAIService.ServiceError>,
        success: @escaping (T) -> Void,
        failure: @escaping FailureCompletion
    ) {
        DispatchQueue.main.async {
            switch result {
            case .success(let value):
                success(value)
            case .failure(let error):
                print("Error! [\(error.localizedDescription)]")
                failure(error)
            }
        }
    }
    
    func createThread(completion: @escaping StringCompletion, failure: @escaping FailureCompletion) {
        OpenAIService.shared.createThread { result in
            self.handleResult(result: result, success: completion, failure: failure)
        }
    }
    
    func uploadImage(uiImage: UIImage, completion: @escaping StringCompletion, failure: @escaping FailureCompletion) {
        OpenAIService.shared.uploadImage(uiImage: uiImage) { result in
            self.handleResult(result: result, success: completion, failure: failure)
        }
    }
    
    func addMessage(
        threadId: String,
        message: String,
        imageId: String = "",
        completion: @escaping VoidCompletion,
        failure: @escaping FailureCompletion
    ) {
        OpenAIService.shared.addMessageToThread(threadId: threadId, message: message, imageId: imageId) { result in
            self.handleResult(result: result, success: { _ in completion() }, failure: failure)
        }
    }
    
    func runThread(threadId: String, completion: @escaping StringCompletion, failure: @escaping FailureCompletion) {
        OpenAIService.shared.runThread(threadId: threadId) { result in
            self.handleResult(result: result, success: completion, failure: failure)
        }
    }
    
    func pollForResult(
        threadId: String,
        runId: String,
        messages: @escaping (_ threadId: String) -> Void,
        failure: @escaping FailureCompletion
    ) {
        OpenAIService.shared.newPoll(threadId: threadId, runId: runId) { result in
            self.handleResult(result: result, success: messages, failure: failure)
        }
    }
    
    func getMessages(threadId: String, completion: @escaping StringCompletion, failure: @escaping FailureCompletion) {
        OpenAIService.shared.messages(threadId: threadId) { result in
            self.handleResult(result: result, success: completion, failure: failure)
        }
    }
}
