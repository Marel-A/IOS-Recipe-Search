//
//  RecipeDetailViewController.swift
//  playground
//
//  Created by Marel Alvarado on 7/25/22.
//

import UIKit

class RecipeDetailViewController: UIViewController {
    
    @IBOutlet weak var recipeTitle: UILabel!
    @IBOutlet weak var recipeImage: UIImageView!
    @IBOutlet weak var ingredientListTableView: UITableView!
    @IBOutlet weak var recipeInstructionsLabel: UILabel!
    @IBOutlet weak var starButton: UIButton!
    

    @IBOutlet weak var ingredientListTableViewHeight: NSLayoutConstraint!
    
    
    var portedRecipe: Recipe?
    
    var ingredientList = [String]()
    var instructionSteps = [String]()
    var fullSteps = String()
    
    var isStarred = false
    var starredMatch = [Recipe]()
    
    required init?(coder: NSCoder, portedRecipe: Recipe?, starred: [Recipe]) {
        self.portedRecipe = portedRecipe
        self.starredMatch = starred
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateView()
        // Do any additional setup after loading the view.
    }
    
    func updateView() {

        guard let portedRecipe = portedRecipe else {
            return
        }
        
        let handler =  URLSession.shared.dataTask(with: URL(string: portedRecipe.image)!) { (data,response,error) in
            
            
            if let urlData = data {
                DispatchQueue.main.async {
                    self.recipeImage.image = UIImage(data: urlData,scale: 1.0)!
                }
            }
            else {
                print(error!)
            }
        }
        handler.resume()
        
        for step in portedRecipe.extendedIngredients {
            ingredientList.append(step.original)
        }
        
        for steps in portedRecipe.analyzedInstructions {
            for step in steps.steps {
                instructionSteps.append(step.step)
            }
        }
        recipeTitle.text = portedRecipe.title
        
        ingredientListTableView.dataSource = self

        recipeInstructionsLabel.text = instructionSteps.joined(separator: " ")
        
        ingredientListTableViewHeight.constant = CGFloat(tableView(ingredientListTableView, numberOfRowsInSection: 0) * 45)
        
        if portedRecipe.isStarred {
            starButton.isSelected = true
        }
        else {
            starButton.isSelected = false
        }
    }
    
    @IBAction func starButtonTapped(_ sender: Any) {
        starButton.isSelected.toggle()
        portedRecipe?.isStarred.toggle()
    }
    
    
    
}

extension RecipeDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ingredientList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ingredientCell", for: indexPath)
        
        cell.textLabel?.text = ingredientList[indexPath.row]
        
        return cell
    }
    
    
}
