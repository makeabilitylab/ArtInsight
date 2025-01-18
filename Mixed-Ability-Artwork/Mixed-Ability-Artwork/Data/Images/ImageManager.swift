//
//  ImageManager.swift
//  Mixed-Ability-Artwork
//
//  Created by Melanie Kneitmix on 5/23/24.
//

import Foundation
import UIKit

class ImageManager {
    
    // MARK: Properties
    
    private let root = "Mixed-Ability-Artwork/Descriptions"
    
    private let dateFormatter = DateFormatter()
    
    static let shared = ImageManager()
    
    // MARK: Initiazliation
    
    private init() {
        createDirIfNeeded(for: "")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    }
    
    // MARK: Images
    
    func save(item: ImageDescription) {
        let image = item.uiImage
        let name = item.name ?? ""
        let descriptiveDescription = item.descriptiveDescription
        let creativeDescription = item.creativeDescription
        let questions = item.questions
        let author = item.author ?? ""
        let dateTaken = dateFormatter.string(from: item.dateTaken ?? Date())

        guard let data = image.jpegData(compressionQuality: 1.0) else { return }
        
        let fileName = item.id
        let nameURL = getNameURL(for: fileName)
        let imageURL = getImageURL(for: fileName)
        let descriptiveURL = getDescriptiveDescriptionURL(for: fileName)
        let creativeURL = getCreativeDescriptionURL(for: fileName)
        let questionsURL = getQuestionsURL(for: fileName)
        let authorURL = getAuthorURL(for: fileName)
        let dateURL = getDateURL(for: fileName)
        
        do {
            try data.write(to: imageURL)
            try name.write(to: nameURL, atomically: true, encoding: .utf8)
            try descriptiveDescription.write(to: descriptiveURL, atomically: true, encoding: .utf8)
            try creativeDescription.write(to: creativeURL, atomically: true, encoding: .utf8)
            try questions.write(to: questionsURL, atomically: true, encoding: .utf8)
            try author.write(to: authorURL, atomically: true, encoding: .utf8)
            try dateTaken.write(to: dateURL, atomically: true, encoding: .utf8)

            print("Saved image and description to \(root)/\(fileName)")
        } catch {
            print("Failed to save image and description: \(error)")
        }
    }
    
    func getImageDescription(fileName: String) -> ImageDescription? {
        let imageURL = getImageURL(for: fileName)
        let nameURL = getNameURL(for: fileName)
        let descriptiveURL = getDescriptiveDescriptionURL(for: fileName)
        let creativeURL = getCreativeDescriptionURL(for: fileName)
        let questionsURL = getQuestionsURL(for: fileName)
        let authorURL = getAuthorURL(for: fileName)
        let dateURL = getDateURL(for: fileName)
        
        guard let uiImage = UIImage(contentsOfFile: imageURL.path) else {
            return nil
        }
        
        guard let name = try? String(contentsOf: nameURL) else {
            return nil
        }
        
        guard let author = try? String(contentsOf: authorURL) else {
            return nil
        }
        
        guard let dateTaken = try? dateFormatter.date(from: String(contentsOf: dateURL)) else {
            return nil
        }
        
        guard let descriptiveDescription = try? String(contentsOf: descriptiveURL) else {
            return nil
        }
        
        guard let creativeDescription = try? String(contentsOf: creativeURL) else {
            return nil
        }
        
        guard let questions = try? String(contentsOf: questionsURL) else {
            return nil
        }
        
        return ImageDescription(id: fileName, uiImage: uiImage, descriptiveDescription: descriptiveDescription, creativeDescription: creativeDescription, questions: questions, name: name, author: author, dateTaken: dateTaken)
    }
    
    func getAllImageDescriptions() -> [ImageDescription] {
        let documentsDirectory = getDocumentsDirectory()
        let rootDirectory = documentsDirectory.appendingPathComponent(root)
        var imageDescriptions = [ImageDescription]()
        
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: rootDirectory, includingPropertiesForKeys: nil)
            
            for fileURL in fileURLs {
                let fileName = fileURL.lastPathComponent
                
                if let imageDescription = getImageDescription(fileName: fileName) {
                    imageDescriptions.append(imageDescription)
                }
            }
        } catch {
            print("Failed to read contents of directory: \(error)")
        }
        print("Successfully returned all image descriptions!")
        return imageDescriptions
    }
    
    // MARK: `FileManager`
    
    private func getDocumentsDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    private func getImageURL(for filename: String) -> URL
    {
        return getDocumentsDirectory().appendingPathComponent("\(root)/\(filename)/image.jpg")
    }
    
    private func getNameURL(for filename: String) -> URL
    {
        return getDocumentsDirectory().appendingPathComponent("\(root)/\(filename)/name.txt")
    }
    
    private func getAuthorURL(for filename: String) -> URL
    {
        return getDocumentsDirectory().appendingPathComponent("\(root)/\(filename)/author.txt")
    }
    
    private func getDateURL(for filename: String) -> URL
    {
        return getDocumentsDirectory().appendingPathComponent("\(root)/\(filename)/date.txt")
    }
    
    private func getDescriptiveDescriptionURL(for filename: String) -> URL
    {
        return getDocumentsDirectory().appendingPathComponent("\(root)/\(filename)/descriptiveDescription.txt")
    }
    
    private func getCreativeDescriptionURL(for filename: String) -> URL
    {
        return getDocumentsDirectory().appendingPathComponent("\(root)/\(filename)/creativeDescription.txt")
    }
    
    private func getQuestionsURL(for filename: String) -> URL
    {
        return getDocumentsDirectory().appendingPathComponent("\(root)/\(filename)/questions.txt")
    }
    
    func createDirIfNeeded(for filename: String) {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("\(root)/\(filename)" + "/")
        do {
            try FileManager.default.createDirectory(atPath: dir.path, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func deleteDirIfExists(for filename: String) {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("\(root)/\(filename)" + "/")
        do {
            if FileManager.default.fileExists(atPath: dir.path) {
                try FileManager.default.removeItem(atPath: dir.path)
                print("Directory deleted successfully.")
            } else {
                print("Directory does not exist.")
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
}
