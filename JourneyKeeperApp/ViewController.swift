//
//  ViewController.swift
//  JourneyKeeperApp
//
//  Created by Eren Elçi on 2.10.2024.
//

import UIKit
import CoreData

class ViewController: UIViewController , UITableViewDelegate , UITableViewDataSource {

    @IBOutlet var tableView: UITableView!
    
    var nameArray = [String]()
    var subtitleArray = [String]()
    var idArray = [UUID]()
    
    var selectedName: String = ""
    var selectedSubtitle: String = ""
    var selectedID : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addMapLocation))
        
        
        
        tableView.delegate  = self
        tableView.dataSource = self
        
        getData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name("newPlace"), object: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        var context = cell.defaultContentConfiguration()
        context.text = nameArray[indexPath.row]
        context.secondaryText = subtitleArray[indexPath.row]
        cell.contentConfiguration = context
        return cell
    }
    
    
    @objc func addMapLocation(){
        selectedName = ""
        performSegue(withIdentifier: "toMapVC", sender: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier ==  "toMapVC" {
            let destination = segue.destination as! MapViewController
            destination.choosedName = selectedName
            destination.chooseSubtitle = selectedSubtitle
            destination.choosedID = selectedID
        }
    }
    
    @objc func  getData() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Konum")
        request.returnsObjectsAsFaults = false
        
        do {
            let results = try context.fetch(request)
            
            if results.count > 0 {
                self.nameArray.removeAll(keepingCapacity: true)
                self.subtitleArray.removeAll(keepingCapacity: true)
                self.idArray.removeAll(keepingCapacity: true)
                
                for result in results as! [NSManagedObject]{
                    if let name = result.value(forKey: "title") as? String {
                        self.nameArray.append(name)
                    }
                    
                    if let subtitle = result.value(forKey: "subtitle") as? String {
                        self.subtitleArray.append(subtitle)
                    }
                    
                    if let id = result.value(forKey: "id") as? UUID {
                        self.idArray.append(id)
                    }
                    tableView.reloadData()
                }
                
                
            }
        } catch {
            print("Veriler getirilirken hata oluştu")
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedName = nameArray[indexPath.row]
        selectedSubtitle = subtitleArray[indexPath.row]
        selectedID = idArray[indexPath.row]
        performSegue(withIdentifier: "toMapVC", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Konum")
            
            let idString = idArray[indexPath.row].uuidString
            
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
            
            fetchRequest.returnsObjectsAsFaults = false
            
            
            do {
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                        if let id = result.value(forKey: "id") as? UUID {
                            if id == idArray[indexPath.row] {
                                context.delete(result)
                                nameArray.remove(at: indexPath.row)
                                idArray.remove(at: indexPath.row)
                                subtitleArray.remove(at: indexPath.row)
                                self.tableView.reloadData()
                                
                                
                                do{
                                    try context.save()
                                } catch {
                                    print( "error")
                                }
                                
                                
                            }
                        }
                    }
                }
            } catch {
                print("error")
            }
           
            
            
            
        }
    }


}

