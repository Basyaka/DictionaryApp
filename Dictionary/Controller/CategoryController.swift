//
//  CategoryController.swift
//  Dictionary
//
//  Created by Vlad Novik on 7/7/20.
//  Copyright © 2020 Vlad Novik. All rights reserved.
//

import UIKit
import CoreData

class CategoryController: UITableViewController {
    
    var categoryArray = [Category]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        customization()
        
        loadCategory()
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.categoryCell, for: indexPath) as!  CategoryViewCell
        cell.categoryLabel?.text = categoryArray[indexPath.row].name
        return cell
    }
    
    //MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: K.itemsSegue, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! DictionaryController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categoryArray[indexPath.row]
        }
    }
    
    //MARK: - DB methods
    func saveCategory() {
        do {
            try context.save()
        } catch {
            print("Error saving \(error)")
        }
        self.tableView.reloadData()
    }
    
    func loadCategory(with request: NSFetchRequest<Category> = Category.fetchRequest()) {
        do {
            categoryArray =  try context.fetch(request)
        } catch {
            print("Error reading: \(error)")
        }
        tableView.reloadData()
    }
    
    //MARK: - Buttons logic
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var categoryTF = UITextField()
        
        let alert = UIAlertController(title: "Add New Category", message: nil, preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            let newCategory = Category(context: self.context)
            newCategory.name = categoryTF.text!
            
            self.categoryArray.append(newCategory)
            
            self.saveCategory()
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        alert.addTextField { (alertTextField) in 
            alertTextField.placeholder = "Category"
            alertTextField.autocapitalizationType = .words
            categoryTF = alertTextField
        }
        
        alert.addAction(cancel)
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - UITableView Swipe
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let swipeDelete = UIContextualAction(style: .normal, title: "Delete") { (action, view, success) in
            self.saveCategory()
            self.context.delete(self.categoryArray[indexPath.row])
            self.categoryArray.remove(at: indexPath.row)
            self.saveCategory()
        }
        swipeDelete.backgroundColor = .red
        swipeDelete.image = UIImage(systemName: "trash.fill")
        return UISwipeActionsConfiguration(actions: [swipeDelete])
    }
    
}

//MARK: - Customization
extension CategoryController {
    func customization() {
        let image = UIImage(named: "BackgroundTableView.jpg")
        let imageView = UIImageView(image: image)
        tableView.backgroundView = imageView
        imageView.alpha = 0.8
    }
}
