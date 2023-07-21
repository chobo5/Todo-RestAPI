//
//  ViewController.swift
//  Todo+RestAPI
//
//  Created by 원준연 on 2023/01/11.
//

import UIKit

class ViewController: UIViewController, sendTodoDelegate{
    
    
    
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButton: UIButton!
    
    let structure = ["todos", "completedTodos"]
    var todosArray: [Todo] = []
    var completedTodosArray: [Todo] = []
    var isFiltering: Bool = false
    var filterredTodos: [Todo] = []
    var filterredCompletedTodos: [Todo] = []
    var location: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        //서치바 UI변경
        self.searchBar.searchTextField.leftView?.tintColor = .white
        self.searchBar.searchTextField.superview?.backgroundColor = .black
        self.searchBar.searchTextField.backgroundColor = UIColor.lightDark
        self.searchBar.searchTextField.textColor = .white
        self.searchBar.showsCancelButton = false
        
        //네비게이션바 색상 변경(스크롤시 투명하게 바뀌는현상 교정)
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.backgroundColor = .black
        
        //네이게이션바의 타이틀색 변경
        let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.importanceBlue]
        navigationBarAppearance.titleTextAttributes = textAttributes as [NSAttributedString.Key : Any]
        
        navigationController?.navigationBar.standardAppearance = navigationBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
        
        tableView.sectionHeaderTopPadding = 0.0
        
        tableView.register(UINib(nibName: "TodoTableViewCell", bundle: nil), forCellReuseIdentifier: "todoCell")
        
        //할일추가버튼 커스텀
        addButton.layer.cornerRadius = addButton.frame.size.width / 2
        addButton.clipsToBounds = true
        addButton.setGradiant(color1: UIColor.gradiant1 ?? UIColor.white, color2: UIColor.gradiant2 ?? UIColor.white, color3: UIColor.gradiant4 ?? UIColor.white, color4: UIColor.gradiant4 ?? UIColor.white)
        
        TodosAPI.fetchTodos { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let todos):
                todos.forEach { todo in
                    if todo.progressCount == 2 {
                        self.completedTodosArray.append(todo)
                    } else {
                        self.todosArray.append(todo)
                    }
                }
            case .failure(let error):
                print("Home", error)
            }
        }
     
    }
    
    //MARK: 메인화면이 사라지면 progressCount를 바꾼 할일들을 서버에 업데이트
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //isEdit = true인 할일들을 전부 PUT(업데이트)해준다.
        todosArray.forEach { todo in
            if todo.isEdited == true {
                TodosAPI.updateATodo(id: todo.id ?? 0 ,
                                     title: todo.title ?? "제목을 입력해주세요.",
                                     content: todo.content ?? "내용을 입력해주세요.",
                                     imageURl: todo.imageURl ?? "imageURL",
                                     progressCount: todo.progressCount ?? 0,
                                     colorCount: todo.colorCount ?? 0) { [weak self] result in
                    guard let self = self else { return }
                    switch result {
                    case.success(let success):
                        print("updateEditedTodo",success)
                    case.failure(let failure):
                        print("updateEditedTodo",failure)
                    }
                }
            }
        }
    }
    
    
    
    //POST(추가)후에 todo를 받았을때 처리하는 메소드
    func sendNewTodo(todo: Todo) {
        print("sendNewTodo", todo)
        if todo.progressCount == 2 {
            completedTodosArray.append(todo)
        } else {
            todosArray.append(todo)
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
        
    }
    
    //PUT(업데이트)후에 todo를 받았을때 처리하는 메소드
    func sendUpdatedTodo(todo: Todo) {
        print("sendUpdateTodo", todo)
        if let location = location {
            if location.section == 0 {
                todosArray[location.row].content = todo.content
                todosArray[location.row].title = todo.title
                todosArray[location.row].progressCount = todo.progressCount
                todosArray[location.row].colorCount = todo.colorCount
                todosArray[location.row].imageURl = todo.imageURl
                todosArray[location.row].modifiedDate = todo.modifiedDate
                todosArray[location.row].image = todo.image
                
                if todosArray[location.row].progressCount == 2 {
                    completedTodosArray.append(todosArray[location.row])
                    todosArray.remove(at: location.row)
                }
            } else {
                completedTodosArray[location.row].content = todo.content
                completedTodosArray[location.row].title = todo.title
                completedTodosArray[location.row].progressCount = todo.progressCount
                completedTodosArray[location.row].colorCount = todo.colorCount
                completedTodosArray[location.row].imageURl = todo.imageURl
                completedTodosArray[location.row].modifiedDate = todo.modifiedDate
                completedTodosArray[location.row].image = todo.image
                
                if completedTodosArray[location.row].progressCount ?? todo.progressCount ?? 0 < 2 {
                    todosArray.append(completedTodosArray[location.row])
                    completedTodosArray.remove(at: location.row)
                }
            }
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func sendImageOnly(image: UIImage?) {
        guard let receivedImage = image else { print(image) ;return }
        if let location = location {
            if location.section == 0 {
                todosArray[location.row].image = receivedImage
            } else {
                completedTodosArray[location.row].image = receivedImage
            }
        }
    }
    
    //MARK: - 새로운 할일 추가버튼 클릭
    @IBAction func addButtonClicked(_ sender: UIButton) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "detailTodo") as? DetailTodoViewController else { return }
        vc.isNewTodo = true
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: false)
    }
    
    
}

//MARK: -talbeView section0: 할일, section1: 완료된 할일
extension ViewController: UITableViewDataSource {
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return structure.count
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 40))
        
        let headerLabel = UILabel(frame: CGRect(x: 0, y: 0, width: headerView.frame.width - 10, height: headerView.frame.height - 10))
        
        headerView.backgroundColor = .black
        headerLabel.textAlignment = .center
        headerLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        headerLabel.textColor = .white
        
        
        
        headerView.addSubview(headerLabel)
        if section == 0 {
            headerLabel.text = "할 일"
            return headerView
        } else {
            headerLabel.text = "완료된 할 일"
            return headerView
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
        
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if isFiltering == false {
                return todosArray.count
            } else {
                return filterredTodos.count
            }
        } else {
            if isFiltering == false {
                return completedTodosArray.count
            } else {
                return filterredCompletedTodos.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "todoCell", for: indexPath) as! TodoTableViewCell
            var cellData = self.todosArray[indexPath.row]
            
            if isFiltering {
                cellData = self.filterredTodos[indexPath.row]
            }
            cell.selectionStyle = .none
            cell.progressButtons.forEach { button in
                button.addTarget(self, action: #selector(tapProgressButton(sender:)), for: .touchUpInside)
            }
            cell.updateUI(cellData)
            return cell
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "todoCell", for: indexPath) as! TodoTableViewCell
            var cellData = self.completedTodosArray[indexPath.row]
            if isFiltering {
                cellData = self.filterredCompletedTodos[indexPath.row]
            }
            cell.selectionStyle = .none
            cell.updateUI(cellData)
            return cell
        }
    }
    
    
    
    
}

extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "detailTodo") as? DetailTodoViewController else { return }
        
        vc.delegate = self
        
        self.location = indexPath
        
        if indexPath.section == 0 {
            if isFiltering == false {
                vc.todo = todosArray[indexPath.row]
            } else {
                vc.todo = filterredTodos[indexPath.row]
            }
        } else {
            if isFiltering == false {
                vc.todo = completedTodosArray[indexPath.row]
            } else {
                vc.todo = filterredCompletedTodos[indexPath.row]
            }
        }
        //isNewTodo는 기존의 할일의 내용을 불러와야한다면 false, 새로운할일(버튼이 따로존재)을 추가한다면 true
        vc.isNewTodo = false
        
        navigationController?.pushViewController(vc, animated: false)
    
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //MARK: - 할일 삭제하기
            //완료되지 않은 할일 삭제
            if indexPath.section == 0 {
                if let id = todosArray[indexPath.row].id {
                    //                    print(id)
                    //완료되지 않은 할일 서버에서 삭제
                    TodosAPI.deleteATodo(id: id) { [weak self] result in
                        guard let self = self else { return }
                        switch result {
                        case .success(let success):
                            if let deletedTodo: Todo? = success {
                                print("Successfully Deleted: \(deletedTodo)")
                            }
                        case .failure(let failure):
                            print("Failed to Delete Todo: \(failure)")
                        }
                        
                    }
                    //완료되지 않은 할일 서버에서 삭제
                    todosArray.remove(at: indexPath.row)
                    
                    
                }
                //완료된 할일 삭제
            } else if indexPath.section == 1 {
                if let id = completedTodosArray[indexPath.row].id {
                    //완료된 할일 서버에서 삭제
                    TodosAPI.deleteATodo(id: id) { [weak self] result in
                        guard let self = self else { return }
                        switch result {
                        case .success(let success):
                            if let deletedTodo: Todo? = success {
                                print("Successfully Deleted: \(deletedTodo)")
                            }
                        case .failure(let failure):
                            print("Failed to Delete Todo: \(failure)")
                        }
                        
                    }
                    //완료된 할일 배열에서 삭제
                    completedTodosArray.remove(at: indexPath.row)
                }
            }
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        } else if editingStyle == .insert {
            
        }
    }
    
}

//MARK: - SearchBar Delegate
extension ViewController: UISearchBarDelegate {
    // 서치바에서 검색을 시작할 때 호출
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.isFiltering = true
        self.searchBar.showsCancelButton = true
        self.tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let text = self.searchBar.text?.lowercased() else { return }
        self.filterredTodos = self.todosArray.filter { $0.title!.localizedCaseInsensitiveContains(text)}
        
        self.filterredCompletedTodos = self.completedTodosArray.filter { $0.title!.localizedCaseInsensitiveContains(text)}
        
        self.tableView.reloadData()
    }
    
    // 서치바에서 검색버튼을 눌렀을 때 호출
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
        
        guard let text = self.searchBar.text?.lowercased() else { return }
        
        self.filterredTodos = self.todosArray.filter { $0.title!.localizedCaseInsensitiveContains(text)}
        
        self.filterredCompletedTodos = self.completedTodosArray.filter { $0.title!.localizedCaseInsensitiveContains(text)}
        
        self.tableView.reloadData()
    }
    
    // 서치바에서 취소 버튼을 눌렀을 때 호출
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
         self.searchBar.text = ""
         self.searchBar.resignFirstResponder()
         self.isFiltering = false
         self.tableView.reloadData()
     }
    
    // 서치바 검색이 끝났을 때 호출
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
            self.tableView.reloadData()
        }
    
}

//MARK: - @objc func
extension ViewController {
    //MARK: - 완료되지 않은 todosArray에서 progressButton을 tap할때
    @objc func tapProgressButton(sender: UIButton) {
        let contentView = sender.superview?.superview //계층: button < stackview < cellView < cell
        guard let cell = contentView?.superview as? UITableViewCell else { return }
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        
        guard let todoCell = tableView.cellForRow(at: IndexPath(row: indexPath.row, section: indexPath.section)) as? TodoTableViewCell else { return }
        
        
        if sender.tag == 100 {
            //todosArray의 todo의 progressCount 변경
            todosArray[indexPath.row].progressCount = 0
            //todosArray의 todo의 isEdit = true로 변경
            todosArray[indexPath.row].isEdited = true
            
            //progressCount UI변경
            todoCell.progressButtons.forEach { button in
                if button.tag <= 100 {
                    button.tintColor = UIColor.importanceBlue
                } else {
                    button.tintColor = UIColor.deselectedColor
                }
            }
            
        } else if sender.tag == 101 {
            //todosArray의 todo의 progressCount 변경
            todosArray[indexPath.row].progressCount = 1
            //todosArray의 todo의 isEdit = true로 변경
            todosArray[indexPath.row].isEdited = true
            
            //progressCount UI변경
            todoCell.progressButtons.forEach { button in
                if button.tag <= 101 {
                    button.tintColor = UIColor.importanceBlue
                } else {
                    button.tintColor = UIColor.deselectedColor
                }
            }
            
        } else {
            //todosArray의 todo의 progressCount 변경
            todosArray[indexPath.row].progressCount = 2
            //todosArray의 todo의 isEdit = true로 변경
            todosArray[indexPath.row].isEdited = true
            //completedTodosArray에 해당 todo 추가
            completedTodosArray.append(todosArray[indexPath.row])
            //todosArray에 해당 todo 삭제
            todosArray.remove(at: indexPath.row)
            
            tableView.reloadData()
        }
    }
    
    
}


