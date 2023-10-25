//
//  ToDoListTVC.swift
//  CoreDаta
//
//  Created by Roman Litvinovich on 25/10/2023.
//

import UIKit
import CoreData


class ToDoListTVC: UITableViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var selectedCategory: CategoryModel? {
        didSet {
            self.title = selectedCategory?.name
            getData()
        }
    }
    
    var itemsArray = [ItemModel]()

    @IBAction func addNewItem(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add new item", message: "", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Your new task"
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        let addAction = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            if let textField = alert.textFields?.first,
               let text = textField.text,
               !text.isEmpty,
               let self = self {
                let newItem = ItemModel(context: self.context)
                newItem.title = text
                newItem.done = false
                newItem.parentCategory = self.selectedCategory
                
                self.itemsArray.append(newItem)
                self.saveItems()
                self.tableView.insertRows(at: [IndexPath(row: self.itemsArray.count - 1, section: 0)], with: .automatic)
            }
        }
        
        alert.addAction(cancel)
        alert.addAction(addAction)
        
        self.present(alert, animated: true)
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        itemsArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let item = itemsArray[indexPath.row]
        cell.textLabel?.text = item.title
        cell.accessoryType = item.done ? .checkmark : .none
        return cell
    }

    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            if let categoryName = selectedCategory?.name, let itemName = itemsArray[indexPath.row].title {
                
                let request: NSFetchRequest<ItemModel> = ItemModel.fetchRequest()
                        
                let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", categoryName)
                let itemPredicate = NSPredicate(format: "title MATCHES %@", itemName)
                
                request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, itemPredicate])
                        
                if let results = try? context.fetch(request) {
                    for object in results {
                        context.delete(object)
                    }
                    itemsArray.remove(at: indexPath.row)
                    saveItems()
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        itemsArray[indexPath.row].done.toggle()
        self.saveItems()
        tableView.reloadRows(at: [indexPath], with: .fade)
    }
    
    // MARK: - Core Data

    private func getData() {
        loadItems()
    }
    
    private func loadItems(with request: NSFetchRequest<ItemModel> = ItemModel.fetchRequest(),
                           predicate: NSPredicate? = nil) {
        
        guard let name = selectedCategory?.name else {
            return
        }
            
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", name)
            
        if let predicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, categoryPredicate])
        } else {
            request.predicate = categoryPredicate
        }
            
        do {
            itemsArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context")
        }
        tableView.reloadData()
    }
    
    private func saveItems() {
        do {
            try context.save()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
}

extension ToDoListTVC: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.isEmpty {
            loadItems()
            searchBar.resignFirstResponder() // завершение ввода
        } else {
            let request: NSFetchRequest<ItemModel> = ItemModel.fetchRequest()
            let searchPredicate = NSPredicate(format: "title CONTAINS %@", searchText)
            request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
            loadItems(with: request, predicate: searchPredicate)
        }
    }
}
