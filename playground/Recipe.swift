//
//  Recipe.swift
//  playground
//
//  Created by Marel Alvarado on 7/13/22.
//

import Foundation
import UIKit

struct Instructions: Codable {
    let steps: [Steps]
}

struct Steps: Codable {
    var step: String
}

struct Ingredients: Codable {
    let original: String
}

struct Recipe: Codable {
    var isStarred: Bool
    
    let title: String
    let image: String
    var analyzedInstructions: [Instructions]
    let extendedIngredients: [Ingredients]
    
    enum CodingKeys: String, CodingKey {
        case title
        case image
        case analyzedInstructions
        case extendedIngredients
    }
    
    init(from decoder: Decoder) throws {
        isStarred = Bool()
        let values = try decoder.container(keyedBy: Recipe.CodingKeys.self)
        
        title = try values.decode(String.self, forKey: Recipe.CodingKeys.title)
        image = try values.decode(String.self, forKey: Recipe.CodingKeys.image)
        analyzedInstructions = try values.decode([Instructions].self, forKey: Recipe.CodingKeys.analyzedInstructions)
        extendedIngredients = try values.decode([Ingredients].self, forKey: Recipe.CodingKeys.extendedIngredients)
    }
    
    static let archiveURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("starred").appendingPathExtension("plist")
    
    static func saveStarred(_ starred: [Recipe]) {
        let pListEncoder = PropertyListEncoder()
        let encodedToDoList = try? pListEncoder.encode(starred)
        try? encodedToDoList?.write(to: archiveURL, options: .noFileProtection)
    }
    
    static func loadList() -> [Recipe]? {
        guard let decodedStarred = try? Data(contentsOf: archiveURL) else {return nil}
        let pListDecoder = PropertyListDecoder()
        return try? pListDecoder.decode([Recipe].self, from: decodedStarred)
    }
}

enum HTTPError: Error, LocalizedError {
    case responseError
}

struct searchResponse: Codable {
    let results: [Recipe]
}

class RecipeController {
    
    //The API key used is free via Spoonacular for personal use; if no results come up when searching
    //try registering for a key and paste it after "apiKey=" and before "&fillIndredients".
    let APIurl = "https://api.spoonacular.com/recipes/complexSearch?apiKey=428bc45a05a943f9ae4e133ff7c467a9&fillIngredients=true&addRecipeInformation=true&?&query="
    
    func getResults(matching query: String) async throws -> [Recipe] {
        var decoded = searchResponse(results: [Recipe]())

        var urlData2 = Data()
        
        guard let components = URLComponents(string: APIurl + query + "&offset=0" + "&number=10")?.url else {return [Recipe]()}

        let (data,response) = try await URLSession.shared.data(from: components)
        
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                urlData2 = data
        }
        
        decoded = try JSONDecoder().decode(searchResponse.self,from: urlData2)

        return decoded.results
    }
}
