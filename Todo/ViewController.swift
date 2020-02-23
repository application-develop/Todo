//
//  ViewController.swift
//  Todo
//
//  Created by Nishigaki Taichi on 2020/02/21.
//  Copyright © 2020 Nishigaki Taichi. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "todoCell", for: indexPath)
        
        let myTodo = todoList[indexPath.row]
        cell.textLabel?.text = myTodo.todoTitle
        
        if myTodo.todoDone{
            cell.accessoryType = UITableViewCell.AccessoryType.checkmark
        } else {
            cell.accessoryType = UITableViewCell.AccessoryType.none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let myTodo = todoList[indexPath.row]
        if myTodo.todoDone{
            myTodo.todoDone = false
        } else {
            myTodo.todoDone = true
        }
        
        tableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.fade)
        
        do {
            let data: Data = try NSKeyedArchiver.archivedData(withRootObject: todoList, requiringSecureCoding: true)
            let userDefaults = UserDefaults.standard
            userDefaults.set(data, forKey: "todoList")
            userDefaults.synchronize()
        } catch {
            //エラー処理無し
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath){
        
        if editingStyle == UITableViewCell.EditingStyle.delete{
            todoList.remove(at: indexPath.row)
            
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.fade)
            
            do {
                let data: Data = try NSKeyedArchiver.archivedData(withRootObject: todoList, requiringSecureCoding: true)
                
                let userDefaults = UserDefaults.standard
                userDefaults.set(data, forKey: "todoList")
                userDefaults.synchronize()
            } catch {
                //エラー処理無し
            }
        }
    }
    
    
    
    var todoList = [MyTodo]()
    
    @IBOutlet weak var tableView: UITableView!
    
    
    @IBAction func tapAddButton(_ sender: Any) {
        let alertController = UIAlertController(title: "ToDo 追加", message: "ToDoを入力してください", preferredStyle: UIAlertController.Style.alert)
        
        alertController.addTextField(configurationHandler: nil)
        let okAction = UIAlertAction(title: "追加", style: UIAlertAction.Style.default){(
            action: UIAlertAction) in
            
            if let textField = alertController.textFields?.first{
                
                let myTodo = MyTodo()
                myTodo.todoTitle = textField.text!
                self.todoList.insert(myTodo, at: 0)
                
                self.tableView.insertRows(at: [IndexPath(row: 0, section:0)],
                                          with: UITableView.RowAnimation.right)
                
                let userDefaults = UserDefaults.standard
                do{
                    let data = try NSKeyedArchiver.archivedData(withRootObject: self.todoList, requiringSecureCoding: true)
                    userDefaults.set(data, forKey: "rodoList")
                    userDefaults.synchronize()
                } catch {
                    //エラー処理無し
                }
            }
        }
        
        alertController.addAction(okAction)
        
        let cancelButton = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler: nil)
        
        alertController.addAction(cancelButton)
        
        present(alertController, animated: true, completion: nil)
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let userDefaults = UserDefaults.standard
        if let storedTodoList = userDefaults.object(forKey: "todoList") as? Data{
            do{
                if let unarchivedTodoList = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSArray.self, MyTodo.self], from: storedTodoList) as? [MyTodo]{
                    todoList.append(contentsOf: unarchivedTodoList)
                }
            } catch {
                //エラー処理無し
            }
        }
    }
}

class MyTodo: NSObject, NSSecureCoding{
    static var supportsSecureCoding: Bool{
        return true
    }
    
    var todoTitle: String?
    var todoDone: Bool = false
    
    override init(){
        
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(todoTitle, forKey: "todoTitle")
        aCoder.encode(todoDone, forKey: "todoDane")
    }
    
    required init?(coder aDecoder: NSCoder) {
        todoTitle = aDecoder.decodeObject(forKey: "todoTitle") as? String
        todoDone = aDecoder.decodeBool(forKey: "todoDone")
    }
}


