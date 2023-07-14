//
//  AddTodoViewController.swift
//  Todo+RestAPI
//
//  Created by 원준연 on 2023/01/14.
//

import UIKit
import AVFoundation
import PhotosUI //ios14버전 이상부터, PHPicker를 사용하며, multiselect / zoom in or out / search 지원 https://zeddios.tistory.com/1052
import FirebaseStorage


class DetailTodoViewController: UIViewController  {
    
    @IBOutlet weak var tableView: UITableView!
    
    var todo: Todo = Todo(content: "내용을 입력해주세요.", id: 0, imageURl: "", modifiedDate: "", progressCount: 0, title: "", colorCount: 0, createdDate: "", isEdited: false, image: nil)
    
    var isNewTodo: Bool = true //새로운 todo를 만들지, 기존의 todo를 update할지의 기준
    
    weak var delegate: sendTodoDelegate?
    
    var imageURL: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //네비게이션바 색상 변경(스크롤시 투명하게 바뀌는현상 교정)
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.backgroundColor = .black
        
        //네이게이션바의 타이틀색 변경
        let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.importanceBlue]
        navigationBarAppearance.titleTextAttributes = textAttributes as [NSAttributedString.Key : Any]
        
        navigationController?.navigationBar.standardAppearance = navigationBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
        
        tableView.register(UINib(nibName: "AddImageTableViewCell", bundle: nil), forCellReuseIdentifier: "imageCell")
        tableView.register(UINib(nibName: "TitleTableViewCell", bundle: nil), forCellReuseIdentifier: "titleCell")
        tableView.register(UINib(nibName: "ContentTableViewCell", bundle: nil), forCellReuseIdentifier: "contentCell")
        tableView.register(UINib(nibName: "PriorityTableViewCell", bundle: nil), forCellReuseIdentifier: "priorityCell")
        tableView.register(UINib(nibName: "ProgressTableViewCell", bundle: nil), forCellReuseIdentifier: "progressCell")
        
        print("todo",todo)
    }

    
    override func viewWillDisappear(_ animated: Bool) {
        //수정하지 않고 사진을 다운로드받아 다시 뒤로 가기를 눌렀을떄 이미지를 전달해 다음에 todo에 접근했을때는 image를 다운받지 않도록하기 위함
        print("viewWillDisappear")
//        if self.todo.isEdited == false {
        print(self.todo.image)
            self.delegate?.sendImageOnly(image: self.todo.image)
//        }
    }
    
    
    @IBAction func tapDoneButton(_ sender: Any) {
        
        guard let imageCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? AddImageTableViewCell else { return }
        
        guard let titleCell = tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? TitleTableViewCell else { return }
        
        guard let contentCell = tableView.cellForRow(at: IndexPath(row: 0, section: 2)) as? ContentTableViewCell else { return }
        guard let PriorityCell = tableView.cellForRow(at: IndexPath(row: 0, section: 3)) as? PriorityTableViewCell else { return }
        guard let ProgressCell = tableView.cellForRow(at: IndexPath(row: 0, section: 4)) as? ProgressTableViewCell else { return }
        
        
        
        //ViewController에서 navigationController를 push하여 넘어올때 +버튼을 통해 뷰가 전환됬다면 isNewTodo 변수를 true값으로 변경하였음
        if isNewTodo {
            //MARK: - 할일 추가하기(POST)
            TodosAPI.addATodo(title: titleCell.titleTextField.text ?? "제목을 입력해주세요.",
                              content: contentCell.contentTextView.text ?? "내용을 입력해주세요.",
                              imageURl: todo.imageURl ?? "",
                              progressCount: ProgressCell.progressCount,
                              colorCount: PriorityCell.priorityCount) { result in
                switch result {
                case.success(let data):
                    
                    print("addATodo",data)
                    //1. 이미지를 업로드하고 todo에 imageURL을 넣어준다
                    if let image = self.todo.image {
                        FirebaseStorageManager.uploadImage(image: image) { url in
                            if let url = url {
                                self.imageURL = String(describing: url)
                                print("imageUpload", self.todo)
                            } else {
                                print("urlError")
                            }
                        }
                        
                        self.todo.content = data.content
                        self.todo.id = data.id
                        self.todo.imageURl = data.imageURl
                        self.todo.modifiedDate = data.modifiedDate
                        self.todo.progressCount = data.progressCount
                        self.todo.title = data.title
                        self.todo.colorCount = data.colorCount
                        self.todo.createdDate = data.createdDate
                        self.todo.isEdited = false
                        self.todo.image = image
                    }
//                    self.todo = Todo(content: data.content, id: data.id, imageURl: data.imageURl, modifiedDate: data.modifiedDate, progressCount: data.progressCount, title: data.title, colorCount: data.colorCount, createdDate: data.createdDate, isEdited: false)
                    
                    print("self.todo", self.todo)
                    self.delegate?.sendNewTodo(todo: self.todo)
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                    
                case.failure(let failure):
                    print("addATodo",failure)
                }
            }
            
            
        }
        //ViewController에서 navigationController를 push하여 넘어올때 기존에 할일을 클릭해 뷰가 전환됬다면 isNewTodo 변수를 false값으로 변경하였음
        else {
            //MARK: - 할일 수정하기(PUT)
            TodosAPI.updateATodo(id: todo.id ?? 0,
                                 title: titleCell.titleTextField.text ?? "제목을 입력해주세요.",
                                 content: contentCell.contentTextView.text ?? "내용을 입력해주세요.",
                                 imageURl: todo.imageURl ?? "",
                                 progressCount: ProgressCell.progressCount,
                                 colorCount: PriorityCell.priorityCount) { result in
                switch result {
                case.success(let data):
                    print("updateATodo",data)
                    if let data = data {
                        //MARK: - 할일 가져오기(GET)
                        //update에서 받은 id를 통해 할일을 받아온다
                        TodosAPI.getATodo(id: data) { result in
                            switch result {
                            case.success(let todo):
                                print("getATodo",todo)
                                //1. 이미지를 업로드하고 todo에 imageURL을 넣어준다
                                if let image = self.todo.image {
                                    FirebaseStorageManager.uploadImage(image: image) { url in
                                        if let url = url {
                                            self.imageURL = String(describing: url)
                                            print("imageUpload", self.todo)
                                        } else {
                                            print("urlError")
                                        }
                                    }
                                    
                                    self.todo.content = todo.content
                                    self.todo.id = todo.id
                                    self.todo.imageURl = todo.imageURl
                                    self.todo.modifiedDate = todo.modifiedDate
                                    self.todo.progressCount = todo.progressCount
                                    self.todo.title = todo.title
                                    self.todo.colorCount = todo.colorCount
                                    self.todo.createdDate = todo.createdDate
                                    self.todo.isEdited = false
                                    self.todo.image = image
                                }
                                
                                self.delegate?.sendUpdatedTodo(todo: self.todo)
                                
                                DispatchQueue.main.async {
                                    self.navigationController?.popViewController(animated: true)
                                }
                                
                            case.failure(let failure):
                                print("getATodo", failure)
                            }
                        }
                    }
                    //
                    
                case.failure(let failure):
                    print("updateATodo",failure)
                }
            }
        }
        
        
        
        
        
        
    }
    
    
}

//MARK: - TableViewDataSource & TableViewDelegate
extension DetailTodoViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //MARK: - 이미지 셀
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "imageCell", for: indexPath) as! AddImageTableViewCell
            cell.addImageButton.addTarget(self, action: #selector(addImageButtonClicked(sender:)), for: .touchUpInside)
            
            //이미지가 있을떄
            if let image = todo.image {
                cell.addedImage.image = image
            //이미지가 없을때
            } else {
                if todo.imageURl == "" {
                    
                } else {
                    FirebaseStorageManager.downloadImage(
                        urlString: todo.imageURl ?? "") { result in
                            switch result {
                            case .success(let image):
                                DispatchQueue.main.async {
                                    print("download")
                                    self.todo.image = image
                                    cell.addedImage.image = image
                                }
                            case .failure(let error):
                                print("downoadImageError", error)
                            }
                        }
                }
            }
            
            return cell
            
            //MARK: - 제목 셀
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "titleCell", for: indexPath) as! TitleTableViewCell
            
            cell.titleTextField.text = todo.title
            return cell
            //MARK: - 내용 셀
        } else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "contentCell", for: indexPath) as! ContentTableViewCell
            
            cell.contentTextView.text = todo.content
            
            return cell
            //MARK: - 중요도 셀(빨, 노, 파)
        } else if indexPath.section == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "priorityCell", for: indexPath) as! PriorityTableViewCell
            //기존의 할일의 중요도를 그리는 부분
            
            if let colorCount = todo.colorCount {
                cell.priorityButtons.forEach { button in
                    if button.tag == colorCount + 200 { //red = 200, yellow = 201, blue = 202(colorCount를 버튼의 태그와 맞춤)
                        button.layer.borderWidth = 2
                        button.layer.borderColor = UIColor.white.cgColor
                    }
                }
            } else {
                print("서버의 colorCount가 이상합니다")
            }
            
            //각각의 중요도 버튼에 액션 추가해주기
            for index in cell.priorityButtons.indices {
                
                cell.priorityButtons[index].addTarget(self, action: #selector(priorityButtonClicked(sender:)), for: .touchUpInside)
            }
            return cell
            //MARK: - 진행도 셀(1, 2, 3)
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "progressCell", for: indexPath) as! ProgressTableViewCell
            // 기존의 할일의 진행도를 그리는 부분
            
            if let progressCount = todo.progressCount { //1번개.tag = 100, 2번개.tag = 101, 3번개.tag = 102 (progressCount를 버튼의 태그와 맞춤)
                switch progressCount {
                case 0:
                    cell.progressButtons[0].tintColor = UIColor.importanceBlue
                    cell.progressButtons[1].tintColor = UIColor.deselectedColor
                    cell.progressButtons[2].tintColor = UIColor.deselectedColor
                case 1:
                    cell.progressButtons[0].tintColor = UIColor.importanceBlue
                    cell.progressButtons[1].tintColor = UIColor.importanceBlue
                    cell.progressButtons[2].tintColor = UIColor.deselectedColor
                case 2:
                    cell.progressButtons[0].tintColor = UIColor.importanceBlue
                    cell.progressButtons[1].tintColor = UIColor.importanceBlue
                    cell.progressButtons[2].tintColor = UIColor.importanceBlue
                default:
                    cell.progressButtons[0].tintColor = UIColor.deselectedColor
                    cell.progressButtons[1].tintColor = UIColor.deselectedColor
                    cell.progressButtons[2].tintColor = UIColor.deselectedColor
                }
                
            }
            
            //각각의 진행도 버튼에 액션 추가해주기
            for index in cell.progressButtons.indices {
                
                cell.progressButtons[index].addTarget(self, action: #selector(progressButtonClicked(sender:)), for: .touchUpInside)
            }
            return cell
        }
    }
    
    
}

extension DetailTodoViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 300
        } else if indexPath.section == 1 {
            return 48
        } else if indexPath.section == 2 {
            return 174
        } else if indexPath.section == 3 {
            return 50
        } else {
            return 48
        }
    }
    
}

//MARK: - 각 셀의 버튼에서 실행할 함수 와 사진첩에 접근해 이미지를 선택하는 @objc func들
extension DetailTodoViewController: PHPickerViewControllerDelegate {
    
    @objc func priorityButtonClicked(sender: CustomButton) {
        guard let priorityCell = tableView.cellForRow(at: IndexPath(row: 0, section: 3)) as? PriorityTableViewCell else { return }
        if sender.tag == 200 {
            priorityCell.priorityCount = 0
            priorityCell.priorityButtons.forEach { sender in
                if sender.tag == 200 {
                    selectedPriority(button: sender)
                } else {
                    deSelectedPriority(button: sender)
                }
            }
            
        } else if sender.tag == 201 {
            priorityCell.priorityCount = 1
            priorityCell.priorityButtons.forEach { sender in
                if sender.tag == 201 {
                    selectedPriority(button: sender)
                } else {
                    deSelectedPriority(button: sender)
                }
            }
            
            
        } else {
            priorityCell.priorityCount = 2
            priorityCell.priorityButtons.forEach { sender in
                if sender.tag == 202 {
                    selectedPriority(button: sender)
                } else {
                    deSelectedPriority(button: sender)
                }
            }
        }
    }
    func selectedPriority(button: CustomButton) {
        //클릭한 버튼 UI변경
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.white.cgColor
    }
    
    func deSelectedPriority(button: CustomButton) {
        button.layer.borderWidth = 0
    }
    
    
    @objc func progressButtonClicked(sender: UIButton) {
        guard let progressCell = tableView.cellForRow(at: IndexPath(row: 0, section: 4)) as? ProgressTableViewCell else { return }
        if sender.tag == 100 { //빨강
            progressCell.progressCount = 0
            progressCell.progressButtons.forEach { sender in
                if sender.tag <= 100 {
                    sender.tintColor = UIColor.importanceBlue
                } else {
                    sender.tintColor = UIColor.deselectedColor
                }
            }
            
        } else if sender.tag == 101 { //노랑
            progressCell.progressCount = 1
            progressCell.progressButtons.forEach { sender in
                if sender.tag <= 101 {
                    sender.tintColor = UIColor.importanceBlue
                } else {
                    sender.tintColor = UIColor.deselectedColor
                }
            }
            
        } else { //파랑
            progressCell.progressCount = 2
            progressCell.progressButtons.forEach { sender in
                sender.tintColor = UIColor.importanceBlue
                
            }
        }
    }
    
    @objc func addImageButtonClicked(sender: UIButton) {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 1 //default가 1, 이외 여러개의 사진을 선택 할 수 있다.
        configuration.filter = .any(of: [.images]) //기본값은 nil 즉, 모든 asset들(images, videos, livePhotos)을 선택할 수 있다.
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        self.present(picker, animated: true, completion: nil)
        
    }
    
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        picker.dismiss(animated: true) //1.
        
        let itemProvider = results.first?.itemProvider //2. itemProvider생성(선택된 asset의 Representation)
        
        if let itemProvider = itemProvider,
           itemProvider.canLoadObject(ofClass: UIImage.self) { // 3. provider가 내가 지정한 타입을 로드할 수 있는지 먼저 체크를 한 뒤
            itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in // 4. 로드 할 수 있으면 로드를 합니다
                
                DispatchQueue.main.async {
                    guard let imageCell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? AddImageTableViewCell else { return }
                    self.todo.image = image as? UIImage
                    print("self.todo.image", self.todo.image)
                    imageCell.addedImage.image = image as? UIImage // 5. loadObject는 completionHandler로 NSItemProviderReading과 error를 줍니다.
                    self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                }
            }
        } else {
            // TODO: Handle empty results or item provider not being able load UIImage
        }
        
    }
    
    
}

