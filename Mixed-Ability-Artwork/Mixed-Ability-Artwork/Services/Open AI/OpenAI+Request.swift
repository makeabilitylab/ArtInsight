//
//  GPTNetworking+Request.swift
//  Mixed-Ability-Artwork
//
//  Created by Melanie Kneitmix on 5/23/24.
//

import Foundation
import UIKit

// MARK: Requests

extension OpenAIService.Request {
    
    // MARK: Properites
    
    // Open AI Key
    static private var key: String {
        return "<your key here>"
    }
    
    static private var authorizationHeader: String {
        return "Bearer \(key)"
    }
    
    // Open AI Assistant ID
    static private var assistantId: String {
        return "<your assistant id here>"
    }
    
    // MARK: Requests
    
    static func upload(uiImage: UIImage) -> URLRequest? {
        guard let url = URL(string: "https://api.openai.com/v1/files") else {
            return nil
        }
        
        guard let imageData = uiImage.jpegData(compressionQuality: 0.8) else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue(authorizationHeader, forHTTPHeaderField: "Authorization")
        
        var body = Data()
        
        // Add purpose
        body.appendString("--\(boundary)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"purpose\"\r\n\r\n")
        body.appendString("vision\r\n")
        
        // Add file
        body.appendString("--\(boundary)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\r\n")
        body.appendString("Content-Type: image/jpeg\r\n\r\n")
        body.append(imageData)
        body.appendString("\r\n")
        body.appendString("--\(boundary)--\r\n")
        
        request.httpBody = body
        
        return request
    }
    
    static func describe(imageId: String) -> URLRequest? {
        guard let url = URL(string: "https://api.openai.com/v1/threads/runs") else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(authorizationHeader, forHTTPHeaderField: "Authorization")
        request.setValue("assistants=v2", forHTTPHeaderField: "OpenAI-Beta")
        
        let userMessage = "Describe the image below, given the provided parameters. Only include the description in your response."
        
        // Payload
        let json: [String: Any] = [
            "assistant_id": assistantId,
            "thread": [
                "messages": [
                    [
                        "role": "user",
                        "content": [
                            [
                                "type": "text",
                                "text": userMessage
                            ],
                            [
                                "type": "image_file",
                                "image_file": [
                                    "file_id": imageId
                                ]
                            ]
                        ]
                    ]
                ]
            ]
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: [])
            request.httpBody = jsonData
        } catch {
            print("Error! Failed to serialize payload [\(error)]")
            return nil
        }
        
        return request
    }
    
    static func describe(threadId: String, imageId: String) -> URLRequest? {
        guard let url = URL(string: "https://api.openai.com/v1/threads/runs") else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(authorizationHeader, forHTTPHeaderField: "Authorization")
        request.setValue("assistants=v2", forHTTPHeaderField: "OpenAI-Beta")
        
        let userMessage = "Describe the image below, given the provided parameters. Only include the description in your response."
        
        // Payload
        let json: [String: Any] = [
            "assistant_id": assistantId,
            "thread": [
                "messages": [
                    [
                        "role": "user",
                        "content": [
                            [
                                "type": "text",
                                "text": userMessage
                            ],
                            [
                                "type": "image_file",
                                "image_file": [
                                    "file_id": imageId
                                ]
                            ]
                        ]
                    ]
                ]
            ]
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: [])
            request.httpBody = jsonData
        } catch {
            print("Error! Failed to serialize payload [\(error)]")
            return nil
        }
        
        return request
    }
    
    static func poll(threadId: String, runId: String) -> URLRequest? {
        guard let url = URL(string: "https://api.openai.com/v1/threads/\(threadId)/runs/\(runId)") else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(authorizationHeader, forHTTPHeaderField: "Authorization")
        request.setValue("assistants=v2", forHTTPHeaderField: "OpenAI-Beta")
        
        return request
    }
    
    static func messages(threadId: String) -> URLRequest? {
        guard let url = URL(string: "https://api.openai.com/v1/threads/\(threadId)/messages") else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(authorizationHeader, forHTTPHeaderField: "Authorization")
        request.setValue("assistants=v2", forHTTPHeaderField: "OpenAI-Beta")
        
        return request
    }
    
    static func createThread() -> URLRequest? {
        guard let url = URL(string: "https://api.openai.com/v1/threads") else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(authorizationHeader, forHTTPHeaderField: "Authorization")
        request.setValue("assistants=v2", forHTTPHeaderField: "OpenAI-Beta")
        
        
        return request
    }
    
    static func addMessageToThread(threadId: String, message: String, imageId:String = "") -> URLRequest? {
        guard let url = URL(string: "https://api.openai.com/v1/threads/\(threadId)/messages") else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(authorizationHeader, forHTTPHeaderField: "Authorization")
        request.setValue("assistants=v2", forHTTPHeaderField: "OpenAI-Beta")
        
        let json: [String: Any]
        
        
        // Payload
        if imageId.isEmpty {
            json = [
                
                "role": "user",
                "content": [
                    [
                        "type": "text",
                        "text": message
                    ]
                ]
            ]
        } else {
            json = [
                
                "role": "user",
                "content": [
                    [
                        "type": "text",
                        "text": message
                    ],
                    [
                        "type": "image_file",
                        "image_file": [
                            "file_id": imageId
                        ]
                    ]
                ]
            ]
        }
        
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: [])
            request.httpBody = jsonData
        } catch {
            print("Error! Failed to add message to thread: \(error)")
            return nil
        }
        
        return request
    }
    
    static func runThread(threadId: String) -> URLRequest? {
        guard let url = URL(string: "https://api.openai.com/v1/threads/\(threadId)/runs") else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(authorizationHeader, forHTTPHeaderField: "Authorization")
        request.setValue("assistants=v2", forHTTPHeaderField: "OpenAI-Beta")
        
        // Payload
        let json: [String: Any] = [
            "assistant_id": assistantId,
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: [])
            request.httpBody = jsonData
        } catch {
            print("Error! Failed to thread \(threadId): \(error)")
            return nil
        }
        
        return request
    }
    
}

// MARK: Private extensions

private extension Data {
    
    mutating func appendString(_ string: String) {
        guard let data = string.data(using: .utf8) else {
            return
        }
        
        append(data)
    }
    
}

