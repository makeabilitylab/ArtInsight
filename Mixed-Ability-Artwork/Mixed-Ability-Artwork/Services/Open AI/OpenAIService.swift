//
//  GPTNetworking.swift
//  Mixed-Ability-Artwork
//
//  Created by Melanie Kneitmix on 5/20/24.
//

import Foundation
import UIKit
import SwiftUI

class OpenAIService {
    
    // MARK: Types
    
    typealias Completion = (Result<String, ServiceError>) -> Void
    
    struct Request { } // namespace
    
    // MARK: Properties
    
    private let decoder = JSONDecoder()
    
    static let shared = OpenAIService()
    
    // MARK: Image Description
    
    func describe(uiImage: UIImage, completion: @escaping Completion) {
        print("OpenAI! Uploading image...")
        
        guard let upload = Request.upload(uiImage: uiImage) else {
            completion(.failure(.uploadFailed))
            return
        }
        
        URLSession.shared.dataTask(with: upload) { data, response, error in
            guard let file = self.tryDecode(File.self, from: data, error: error) else {
                completion(.failure(.messagesFailed))
                return
            }
            
            self.describe(imageId: file.id, completion: completion)
        }.resume()
    }
    
    private func describe(imageId: String, completion: @escaping Completion) {
        print("OpenAI! Describing image...")
        
        guard let describe = Request.describe(imageId: imageId) else {
            completion(.failure(.describeFailed))
            return
        }
        
        URLSession.shared.dataTask(with: describe) { data, response, error in
            guard let run = self.tryDecode(Run.self, from: data, error: error) else {
                completion(.failure(.messagesFailed))
                return
            }
            
            self.poll(threadId: run.thread_id, runId: run.id, completion: completion)
        }.resume()
    }
    
    func poll(threadId: String, runId: String, completion: @escaping Completion) {
        poll(threadId: threadId, runId: runId, interval: 5.0, deadline: Date().addingTimeInterval(60.0), completion: completion)
    }
    
    func newPoll(threadId: String, runId: String, completion: @escaping Completion) {
        newPoll(threadId: threadId, runId: runId, interval: 5.0, deadline: Date().addingTimeInterval(60.0), completion: completion)
    }
    
    private func poll(threadId: String, runId: String, interval: TimeInterval, deadline: Date, completion: @escaping Completion) {
        print("OpenAI! Polling for response...")
        
        guard let poll = Request.poll(threadId: threadId, runId: runId) else {
            completion(.failure(.pollFailed))
            return
        }
        
        URLSession.shared.dataTask(with: poll) { data, response, error in
            guard let run = self.tryDecode(Run.self, from: data, error: error) else {
                completion(.failure(.messagesFailed))
                return
            }
            
            switch run.status {
            case "completed": self.messages(threadId: threadId, completion: completion)
            case "failed": completion(.failure(.pollFailed))
            default:
                guard Date() < deadline else {
                    completion(.failure(.pollFailed))
                    return
                }
                
                DispatchQueue.global().asyncAfter(deadline: .now() + interval) {
                    self.poll(threadId: threadId, runId: runId, interval: interval, deadline: deadline, completion: completion)
                }
            }
        }.resume()
    }
    
    private func newPoll(threadId: String, runId: String, interval: TimeInterval, deadline: Date, completion: @escaping Completion) {
        print("OpenAI! Polling for response...")
        
        guard let poll = Request.poll(threadId: threadId, runId: runId) else {
            completion(.failure(.pollFailed))
            return
        }
        
        URLSession.shared.dataTask(with: poll) { data, response, error in
            guard let run = self.tryDecode(Run.self, from: data, error: error) else {
                completion(.failure(.messagesFailed))
                return
            }
            
            switch run.status {
            case "completed": completion(.success("Poll successful!"))
            case "failed": completion(.failure(.pollFailed))
            default:
                guard Date() < deadline else {
                    completion(.failure(.pollFailed))
                    return
                }
                
                DispatchQueue.global().asyncAfter(deadline: .now() + interval) {
                    self.poll(threadId: threadId, runId: runId, interval: interval, deadline: deadline, completion: completion)
                }
            }
        }.resume()
    }
    
    
    func messages(threadId: String, completion: @escaping Completion) {
        print("OpenAI! Getting response message...")
        
        guard let messages = Request.messages(threadId: threadId) else {
            completion(.failure(.pollFailed))
            return
        }
        
        URLSession.shared.dataTask(with: messages) { data, response, error in
            guard let messages = self.tryDecode(Messages.self, from: data, error: error) else {
                completion(.failure(.messagesFailed))
                return
            }
            
            guard let message = messages.data.first else {
                completion(.failure(.messagesFailed))
                return
            }
            
            guard let content = message.content.first else {
                completion(.failure(.messagesFailed))
                return
            }
            
            guard let description = content.text?.value else {
                completion(.failure(.messagesFailed))
                return
            }
            
            completion(.success(description))
        }.resume()
    }
    
    func createThread(completion: @escaping Completion) {
        print("OpenAI! Creating thread...")
        
        guard let thread = Request.createThread() else {
            completion(.failure(.threadFailed))
            return
        }
        
        URLSession.shared.dataTask(with: thread) { data, response, error in
            do {
                let decoder = JSONDecoder()
                let decoded = try decoder.decode(Thread.self, from: data!)
                
                completion(.success(decoded.id))
            } catch {
                print(String(describing: error)) // <- ✅ Use this for debuging!
            }
        }.resume()
    }
    
    
    func addMessageToThread(threadId: String, message: String, imageId:String = "", completion: @escaping Completion) {
        print("OpenAI! Adding \"\(message)\" to message thread...")
        
        guard let update = Request.addMessageToThread(threadId: threadId, message: message, imageId: imageId) else {
            completion(.failure(.describeFailed))
            return
        }
        
        URLSession.shared.dataTask(with: update) { data, response, error in
            guard let message = self.tryDecode(Message.self, from: data, error: error) else {
                completion(.failure(.messagesFailed))
                return
            }
            
            completion(.success("Added message to thread!"))
        }.resume()
    }
    
    func runThread(threadId: String, completion: @escaping Completion) {
        print("OpenAI! Running thread \(threadId)...")
        
        guard let thread = Request.runThread(threadId: threadId) else {
            completion(.failure(.threadFailed))
            return
        }
        
        URLSession.shared.dataTask(with: thread) { data, response, error in
            guard let thread = self.tryDecode(Run.self, from: data, error: error) else {
                completion(.failure(.threadFailed))
                return
            }
            
            completion(.success(thread.id))
        }.resume()
    }
    
    func uploadImage(uiImage: UIImage, completion: @escaping Completion) {
        print("OpenAI! Uploading image...")
        
        guard let upload = Request.upload(uiImage: uiImage) else {
            completion(.failure(.uploadFailed))
            return
        }
        
        URLSession.shared.dataTask(with: upload) { data, response, error in
            guard let file = self.tryDecode(File.self, from: data, error: error) else {
                completion(.failure(.messagesFailed))
                return
            }
            
            completion(.success(file.id))
        }.resume()
    }
    
    
    // MARK: Decode
    
    func tryDecode<T>(_ type: T.Type, from data: Data?, error: Error?) -> T? where T: Decodable {
        if let error = error {
            print("Error! Request failed with error [\(error.localizedDescription)]")
            return nil
        }
        
        guard let data = data else {
            print("Error! Data is undefined")
            return nil
        }
        
        do {
            return try decoder.decode(type, from: data)
        } catch {
            print("Error! Failed to decode data [\(error.localizedDescription)]")
            return nil
        }
    }
    
}



