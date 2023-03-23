//
//  ViewController.swift
//  playground
//
//  Created by Marel Alvarado on 7/12/22.
//

import UIKit

var foodItems = ["item"]


class foodCell: UITableViewCell {
    @IBOutlet weak var foodItem: UILabel!
    //@IBOutlet weak var foodDesc: UILabel!
    @IBOutlet weak var foodImage: UIImageView!
}


class ViewController: UIViewController {
    var Recipes = [Recipe]()
    var starredRecipes = [Recipe]()
    
    var recipeArray = [Recipe]()

    var recipeController = RecipeController()
    
    @IBOutlet var recipeTable: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var recipesButton: UIButton!
    @IBOutlet weak var starredButton: UIButton!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let saveStarred = Recipe.loadList() {
            starredRecipes = saveStarred
        }
        
        recipeTable.dataSource = self
    }
    
    func termSearch() {
        self.recipeTable.reloadData()
        
        let searchTerm = searchBar.text ?? ""
        
        if !searchTerm.isEmpty {
            let query = searchTerm
            Task {
                do{
                    let results = try await recipeController.getResults(matching: query)
                    Recipes = results
                    self.recipeTable.reloadData()
                }
                catch {
                    print(error)
                }
            }
        }
    }

    @IBSegueAction func showRecipeDetail(_ coder: NSCoder, sender: Any?) -> RecipeDetailViewController? {
        guard let cell = sender as? UITableViewCell, let indexPath = recipeTable.indexPath(for: cell)
        else {
            return nil
        }
        
        var selectedRecipe = recipeArray[indexPath.row]
        if(starredRecipes.contains(where: {$0.title == recipeArray[indexPath.row].title})) {
            selectedRecipe.isStarred = true
        }
        
        return RecipeDetailViewController(coder: coder, portedRecipe: selectedRecipe, starred: starredRecipes)
    }
    
    @IBAction func recipesButtonSelected(_ sender: Any) {
        if(recipesButton.tintColor != .systemBlue) {
            let tempTint = recipesButton.tintColor
            let tempBG = recipesButton.backgroundColor
            
            recipesButton.tintColor = starredButton.tintColor
            recipesButton.backgroundColor = starredButton.backgroundColor
            
            starredButton.tintColor = tempTint
            starredButton.backgroundColor = tempBG
        }
        recipeTable.dataSource = self
        recipeTable.reloadData()
    }
    
    @IBAction func starredButtonSelected(_ sender: Any) {
        if(starredButton.tintColor != .systemBlue) {
            let tempTint = starredButton.tintColor
            let tempBG = starredButton.backgroundColor
            
            starredButton.tintColor = recipesButton.tintColor
            starredButton.backgroundColor = recipesButton.backgroundColor
            
            recipesButton.tintColor = tempTint
            recipesButton.backgroundColor = tempBG
        }
        recipeTable.dataSource = self
        recipeTable.reloadData()
    }
    
    @IBAction func unwindToMain(_ unwindSegue: UIStoryboardSegue) {
        let sourceViewController = unwindSegue.source as! RecipeDetailViewController
        
        if let exitedRecipe = sourceViewController.portedRecipe {
            if(exitedRecipe.isStarred && !starredRecipes.contains(where: {$0.title == exitedRecipe.title})) {
                starredRecipes.append(exitedRecipe)
                Recipe.saveStarred(starredRecipes)
            }
            if(!exitedRecipe.isStarred && starredRecipes.contains(where: {$0.title == exitedRecipe.title})) {
                starredRecipes.remove(at: starredRecipes.firstIndex(where: {$0.title == exitedRecipe.title})!)
                Recipe.saveStarred(starredRecipes)
                
                recipeTable.reloadData()
            }
        }
    }
}

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(recipesButton.tintColor == .systemBlue) {
            return Recipes.count
        }
        else {
            return starredRecipes.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(recipesButton.tintColor == .systemBlue) {
            recipeArray = Recipes
        }
        else {
            recipeArray = starredRecipes
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "foodCell", for: indexPath) as! foodCell

        if(!recipeArray.isEmpty) {
            cell.foodItem.text = recipeArray[indexPath.row].title
        
            let handler =  URLSession.shared.dataTask(with: URL(string: recipeArray[indexPath.row].image)!) { (data,response,error) in
                
                
                if let urlData = data {
                    DispatchQueue.main.async {
                        cell.imageView?.image = UIImage(data: urlData,scale: 4.0)!
                    }
                }
                else {
                    print(error!)
                }
            }
            handler.resume()
        }
        
        return cell
    }
}

extension ViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        termSearch()
        
        searchBar.resignFirstResponder()
    }
}
