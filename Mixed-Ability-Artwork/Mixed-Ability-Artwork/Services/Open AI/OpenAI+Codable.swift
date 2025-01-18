//
//  OpenAI+Codable.swift
//  Mixed-Ability-Artwork
//
//  Created by Melanie Kneitmix on 5/29/24.
//

import Foundation

struct File: Codable {
    let id: String
}

struct Run: Codable {
    let id: String
    let thread_id: String
    let status: String
}

struct Messages: Codable {
    let data: [Message]
}

struct Message: Codable {
    let content: [Content]
}

struct Content: Codable {
    let text: TextContent?
}

struct TextContent: Codable {
    let value: String
}

struct Thread: Codable {
    let id: String
    let object: String
    let createdAt: Int
    let metadata: [String: AnyCodable] // Assuming metadata can be any type
    let toolResources: [String: AnyCodable] // Assuming tool_resources can be any type

    enum CodingKeys: String, CodingKey {
        case id
        case object
        case createdAt = "created_at"
        case metadata
        case toolResources = "tool_resources"
    }
}

struct AnyCodable: Codable {
    let value: Any
    
    init(_ value: Any) {
        self.value = value
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let intValue = try? container.decode(Int.self) {
            value = intValue
        } else if let doubleValue = try? container.decode(Double.self) {
            value = doubleValue
        } else if let stringValue = try? container.decode(String.self) {
            value = stringValue
        } else if let boolValue = try? container.decode(Bool.self) {
            value = boolValue
        } else if let arrayValue = try? container.decode([AnyCodable].self) {
            value = arrayValue
        } else if let dictionaryValue = try? container.decode([String: AnyCodable].self) {
            value = dictionaryValue
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unsupported type")
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        if let intValue = value as? Int {
            try container.encode(intValue)
        } else if let doubleValue = value as? Double {
            try container.encode(doubleValue)
        } else if let stringValue = value as? String {
            try container.encode(stringValue)
        } else if let boolValue = value as? Bool {
            try container.encode(boolValue)
        } else if let arrayValue = value as? [AnyCodable] {
            try container.encode(arrayValue)
        } else if let dictionaryValue = value as? [String: AnyCodable] {
            try container.encode(dictionaryValue)
        } else {
            throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "Unsupported type"))
        }
    }
}

//struct Thread: Codable {
//    let id: String
//}

//
//"id": "thread_abc123",
//  "object": "thread",
//  "created_at": 1699012949,
//  "metadata": {},
//  "tool_resources": {}
