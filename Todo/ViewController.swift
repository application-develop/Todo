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
    
    // テーブルの行ごとのセルを返却する
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Storyboardで指定したtodoCelld識別子を利用して再利用可能なセルを取得する
        let cell = tableView.dequeueReusableCell(withIdentifier: "todoCell", for: indexPath)
        
        // 行番号に合ったTodoの情報を取得する
        let myTodo = todoList[indexPath.row]
        // セルのラベルにTodoのタイトルをセット
        cell.textLabel?.text = myTodo.todoTitle
        
        if myTodo.todoDone{
            // チェック有り
            cell.accessoryType = UITableViewCell.AccessoryType.checkmark
        } else {
            // チェック無し
            cell.accessoryType = UITableViewCell.AccessoryType.none
        }
        
        return cell
    }
    
    // セルをタップした時の処理
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let myTodo = todoList[indexPath.row]
        if myTodo.todoDone{
            // 完了済みの場合には未完了に設定
            myTodo.todoDone = false
        } else {
            // 未完了の場合には完了に設定
            myTodo.todoDone = true
        }
        
        // セルの状態を変更
        tableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.fade)
        
        // データ保存 & Data型にシリアライズする
        do {
            let data: Data = try NSKeyedArchiver.archivedData(withRootObject: todoList, requiringSecureCoding: true)
            // UserDefaultsに保存
            let userDefaults = UserDefaults.standard
            userDefaults.set(data, forKey: "todoList")
            userDefaults.synchronize()
        } catch {
            // エラー処理無し
        }
    }
    
    // セルを削除したい時の処理
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath){
        
        // 削除処理かどうか
        if editingStyle == UITableViewCell.EditingStyle.delete{
            // Todoリストから削除
            todoList.remove(at: indexPath.row)
            
            // セルを削除
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.fade)
            
            // データ保存 & Data型にシリアライズする
            do {
                let data: Data = try NSKeyedArchiver.archivedData(withRootObject: todoList, requiringSecureCoding: true)
                
                let userDefaults = UserDefaults.standard
                userDefaults.set(data, forKey: "todoList")
                userDefaults.synchronize()
            } catch {
                // エラー処理無し
            }
        }
    }
    
    
    // Todoを格納した配列
    var todoList = [MyTodo]()
    
    @IBOutlet weak var tableView: UITableView!
    
    // +ボタンをタップした時に呼ばれる処理
    @IBAction func tapAddButton(_ sender: Any) {
        // アラートダイアログ生成
        let alertController = UIAlertController(title: "ToDo 追加", message: "ToDoを入力してください", preferredStyle: UIAlertController.Style.alert)
        
        // テキストエリアを追加
        alertController.addTextField(configurationHandler: nil)
        
        // OKボタンを追加
        let okAction = UIAlertAction(title: "追加", style: UIAlertAction.Style.default){(
            action: UIAlertAction) in
            
            // OKボタンが押された時の処理
            if let textField = alertController.textFields?.first{
                // Todoの配列に入力値を挿入 & 先頭に挿入する
                let myTodo = MyTodo()
                myTodo.todoTitle = textField.text!
                self.todoList.insert(myTodo, at: 0)
                
                // テーブルに行が追加されたことをでテーブルに通知
                self.tableView.insertRows(at: [IndexPath(row: 0, section:0)],
                                          with: UITableView.RowAnimation.right)
                
                // Todoの保存処理
                let userDefaults = UserDefaults.standard
                // Data型にシリアライズ
                do{
                    let data = try NSKeyedArchiver.archivedData(withRootObject: self.todoList, requiringSecureCoding: true)
                    userDefaults.set(data, forKey: "rodoList")
                    userDefaults.synchronize()
                } catch {
                    // エラー処理無し
                }
            }
        }
        // OKボタンがタップされた時の処理
        alertController.addAction(okAction)
        // キャンセルボタンがタップされた時の処理
        let cancelButton = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler: nil)
        // キャンセルボタンの追加
        alertController.addAction(cancelButton)
        // アラートダイアログの追加
        present(alertController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // 保存しているTodoの読み込み処理
        let userDefaults = UserDefaults.standard
        if let storedTodoList = userDefaults.object(forKey: "todoList") as? Data{
            do{
                if let unarchivedTodoList = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSArray.self, MyTodo.self], from: storedTodoList) as? [MyTodo]{
                    todoList.append(contentsOf: unarchivedTodoList)
                }
            } catch {
                // エラー処理無し
            }
        }
    }
}


// 独自クラスをシリアライズする際は、NSObjectをえ継承し、NSSecureCodingプロトコルに準拠する必要がある
class MyTodo: NSObject, NSSecureCoding{
    static var supportsSecureCoding: Bool{
        return true
    }
    
    // Todoのちタイトル
    var todoTitle: String?
    // Todoが完了したかどうかを表すフラグ
    var todoDone: Bool = false
    // コンストラクタ
    override init(){
    }
    
    // NSCodingプロトコルに宣言されているでシリアライズ処理 & デコード処理とも呼ばれる
    func encode(with aCoder: NSCoder) {
        aCoder.encode(todoTitle, forKey: "todoTitle")
        aCoder.encode(todoDone, forKey: "todoDane")
    }
    
    // NSCodingプロトコルに宣言されているシリアライズ処理 & エンコード処理とも呼ばれる
    required init?(coder aDecoder: NSCoder) {
        todoTitle = aDecoder.decodeObject(forKey: "todoTitle") as? String
        todoDone = aDecoder.decodeBool(forKey: "todoDone")
    }
}


