//
//  DictionaryController.swift
//  Dictionary
//
//  Created by Vlad Novik on 6/26/20.
//  Copyright © 2020 Vlad Novik. All rights reserved.
//

import UIKit
import CoreData

class DictionaryController: UIViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var dictArray = [Dictionary]()
    
    var selectedCategory : Category? {
        didSet {
            loadItem()
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var wordTranslateButton: UIButton!
    @IBOutlet weak var reverceButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        customization()
        registerForKeyboardNotificationsItem()
        
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
        
        loadItem()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self,action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    deinit {
        removeKeyboardNotificationItem()
    }
    
    //MARK: - Buttons logic
    
    @IBAction func sortReverce(_ sender: UIButton) {
        if wordTranslateButton.title(for: .normal) == "Word" {
            if reverceButton.title(for: .normal) == "A-Z" {
                reverceButton.setTitle("Z-A", for: .normal)
                sortDictionaryZA()
                tableView.reloadData()
            } else {
                reverceButton.setTitle("A-Z", for: .normal)
                sortDictonaryAZ()
                tableView.reloadData()
            }
        } else if wordTranslateButton.title(for: .normal) == "Translate" {
            if reverceButton.title(for: .normal) == "A-Z" {
                reverceButton.setTitle("Z-A", for: .normal)
                sortTranslateZA()
                tableView.reloadData()
            } else {
                reverceButton.setTitle("A-Z", for: .normal)
                sortTranslateAZ()
                tableView.reloadData()
            }
        }
    }
    
    @IBAction func wordTranslatePressed(_ sender: UIButton) {
        if wordTranslateButton.title(for: .normal) == "Word" {
            wordTranslateButton.setTitle("Translate", for: .normal)
        } else {
            wordTranslateButton.setTitle("Word", for: .normal)
        }
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var wordTF = UITextField()
        var transcrptionTF = UITextField()
        var translateTF = UITextField()
        
        let alert = UIAlertController(title: "Add New Value", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            
            let newItem = Dictionary(context: self.context)
            newItem.dict = wordTF.text!
            newItem.transcription = transcrptionTF.text!
            newItem.translate = translateTF.text!
            newItem.parentCategory = self.selectedCategory
            
            self.dictArray.append(newItem)
            self.saveItem()
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Word"
            alertTextField.autocapitalizationType = .words
            wordTF = alertTextField
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Transcription"
            transcrptionTF = alertTextField
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Translate"
            alertTextField.autocapitalizationType = .words
            translateTF = alertTextField
        }
        
        alert.addAction(cancel)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}

//MARK: - UITableViewDataSource
extension DictionaryController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dictArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.dictionaryCell, for: indexPath) as! DictionaryViewCell
        cell.wordLabel.text = dictArray[indexPath.row].dict
        cell.transcriptionLabel.text = dictArray[indexPath.row].transcription
        cell.translateLabel.text = dictArray[indexPath.row].translate
        return cell
    }
}

//MARK: - UITableViewDelegate
extension DictionaryController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let swipeDelete = UIContextualAction(style: .normal, title: "Delete") { (action, view, success) in
            self.saveItem()
            self.context.delete(self.dictArray[indexPath.row])
            self.dictArray.remove(at: indexPath.row)
            self.saveItem()
        }
        swipeDelete.backgroundColor = .red
        swipeDelete.image = UIImage(systemName: "trash.fill")
        return UISwipeActionsConfiguration(actions: [swipeDelete])
    }
}

//MARK: - UISearchBarDelegate
extension DictionaryController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request: NSFetchRequest<Dictionary> = Dictionary.fetchRequest()
        
        if wordTranslateButton.title(for: .normal) == "Word" {
            let predicate = NSPredicate(format: "dict CONTAINS[cd] %@", searchBar.text!)
            request.sortDescriptors = [NSSortDescriptor(key: "dict", ascending: true)]
            loadItem(with: request, predicate: predicate)
            tableView.reloadData()
        } else if wordTranslateButton.title(for: .normal) == "Translate" {
            let predicate = NSPredicate(format: "translate CONTAINS[cd] %@", searchBar.text!)
            request.sortDescriptors = [NSSortDescriptor(key: "translate", ascending: true)]
            loadItem(with: request, predicate: predicate)
            tableView.reloadData()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItem()
            tableView.reloadData()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}


//MARK: - Database methods
extension DictionaryController {
    func saveItem() {
        do {
            try context.save()
        } catch {
            print("Error saving \(error)")
        }
        self.tableView.reloadData()
    }
    
    func loadItem(with request: NSFetchRequest<Dictionary> = Dictionary.fetchRequest(), predicate: NSPredicate?  = nil) {
        
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }
        
        do {
            dictArray =  try context.fetch(request)
        } catch {
            print("Error reading: \(error)")
        }
    }
}

//MARK: - Customization
extension DictionaryController {
    func customization() {
        let image = UIImage(named: "BackgroundTableView.jpg")
        let imageView = UIImageView(image: image)
        tableView.backgroundView = imageView
        imageView.alpha = 0.8
        
        wordTranslateButton.layer.cornerRadius = 12
        wordTranslateButton.layer.borderWidth = 2
        wordTranslateButton.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        wordTranslateButton.clipsToBounds = true
        
        reverceButton.layer.cornerRadius = 12
        reverceButton.layer.borderWidth = 2
        reverceButton.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        reverceButton.clipsToBounds = true
        
        searchBar.backgroundColor = #colorLiteral(red: 0.7833812237, green: 0.8763417602, blue: 0.9400722384, alpha: 1)
        
        tableView.rowHeight = 60.0
    }
}

//MARK: - Sort logic
extension DictionaryController {
    
    func sortDictonaryAZ() {
        dictArray = dictArray.sorted { (element1, element2) -> Bool in
            let dict1 = element1.dict ?? ""
            let dict2 = element2.dict ?? ""
            return (dict1.localizedCaseInsensitiveCompare(dict2) == .orderedAscending)
        }
    }
    
    func sortDictionaryZA() {
        dictArray = dictArray.sorted { (element1, element2) -> Bool in
            let dict1 = element1.dict ?? ""
            let dict2 = element2.dict ?? ""
            return (dict2.localizedCaseInsensitiveCompare(dict1) == .orderedAscending)
        }
    }
    
    func sortTranslateZA() {
        dictArray = dictArray.sorted { (element1, element2) -> Bool in
            let translate1 = element1.translate ?? ""
            let translate2 = element2.translate ?? ""
            return (translate2.localizedCaseInsensitiveCompare(translate1) == .orderedAscending)
        }
    }
    
    func sortTranslateAZ() {
        dictArray = dictArray.sorted { (element1, element2) -> Bool in
            let translate1 = element1.translate ?? ""
            let translate2 = element2.translate ?? ""
            return (translate1.localizedCaseInsensitiveCompare(translate2) == .orderedAscending)
        }
    }
}

//MARK: - Nortification Center
extension DictionaryController {
    
    func registerForKeyboardNotificationsItem() {
        NotificationCenter.default.addObserver(self, selector: #selector(kbWillShowItem), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(kbWillHideItem), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func removeKeyboardNotificationItem() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func kbWillShowItem(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        let kbFrameSize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        tableView.contentOffset = CGPoint(x: 0, y: kbFrameSize.height)
    }
    @objc func kbWillHideItem() {
        tableView.contentOffset = CGPoint.zero
    }
}

//MARK: - Dismiss keyboard
extension DictionaryController {
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}



