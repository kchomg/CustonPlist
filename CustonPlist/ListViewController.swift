//
//  ListViewController.swift
//  CustonPlist
//
//  Created by Seok Eun Hong on 2021/09/16.
//

import UIKit

class ListViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var account: UITextField!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var gender: UISegmentedControl!
    @IBOutlet weak var married: UISwitch!
    
    var accountlist = [String]()
    
    // 메인 번들에 정의된 Plist 내용을 저장할 딕셔너리
    var defaultPlist: NSDictionary!
    
    override func viewDidLoad() {
        // 메인 번들에 UserInfo.plist가 포함되어 있으면 이를 읽어와 딕셔너리에 담는다.
        if let defaultPlistPath = Bundle.main.path(forResource: "UserInfo" /* 대상 파일의 이름 */, ofType: "plist" /* 확장자 */) { // Bundle.main 속성은 앱의 메인 번들 리소스를 객체 형태로 제공.
            self.defaultPlist = NSDictionary(contentsOfFile: defaultPlistPath)
        }
        
        let picker = UIPickerView()
        
        picker.delegate = self
        
        // account 텍스트 필드 입력 방식을 가상 키보드 대신 피커 뷰로 설정
        self.account.inputView = picker
        
        // 툴 바 객체 정의
        let toolbar = UIToolbar()
        toolbar.frame = CGRect(x: 0, y: 0, width: 0, height: 35) // 항상 화면 폭을 가득 채우도록 렌더링되므로 높이만 지정해주면 된다.
        toolbar.barTintColor = .lightGray
        
        // 액세서리 뷰 영역에 툴 바를 표시
        self.account.inputAccessoryView = toolbar
        
        // 툴 바에 들어갈 닫기 버튼
        let done = UIBarButtonItem()
        done.title = "Done"
        done.target = self
        done.action = #selector(pickerDone)
        
        // 가변 폭 버튼 정의
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        // 신규 계정 등록 버튼
        let new = UIBarButtonItem()
        new.title = "NEW"
        new.target = self
        new.action = #selector(newAccount(_:))
        
        // 버튼을 툴 바에 추가
        toolbar.setItems([new, flexSpace, done], animated: true) // 툴 바에서 버튼의 배치 순서는 입력된 순서를 따르기 때문에 순서가 바뀌면 안된다.
        
        // 기본 저장소 객체 불러오기
        let plist = UserDefaults.standard
        
        // 불러온 값을 설정
        self.name.text = plist.string(forKey: "name")
        self.married.isOn = plist.bool(forKey: "married")
        self.gender.selectedSegmentIndex = plist.integer(forKey: "gender")
        
        // 저장된 계정 선택 정보 읽어오기
        let accountlist = plist.array(forKey: "accountlist") as? [String] ?? [String]()
        self.accountlist = accountlist
        
        if let account = plist.string(forKey: "selectedAccount") {
            self.account.text = account
            // 저장된 프로퍼티 파일을 꺼내 화면에 값을 표시
            let customPlist = "\(account).plist"
            let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            let path = paths[0] as NSString
            let clist = path.strings(byAppendingPaths: [customPlist]).first!
            let data = NSDictionary(contentsOfFile: clist) // 데이터를 읽기만 하면 되기 때문에 굳이 NSMutableDicitionary를 사용할 필요가 없다.
            
            self.name.text = data?["name"] as? String
            self.gender.selectedSegmentIndex = data?["gender"] as? Int ?? 0
            self.married.isOn = data?["married"] as? Bool ?? false
        }
        
        // 사용자 계정의 값이 비어 있다면 값을 설정하는 것을 막는다.
        if (self.account.text?.isEmpty)! {
            self.account.placeholder = "등록된 계정이 없습니다."
            self.gender.isEnabled = false
            self.married.isEnabled = false
        }
        
        // 내비게이션 바에 newAccount 메소드와 연결된 버튼을 추가한다.
        let addBtn = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(newAccount(_:)))
        self.navigationItem.rightBarButtonItem = addBtn
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.accountlist.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.accountlist[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // 선택된 계정값을 텍스트 필드에 입력
        let account = self.accountlist[row] // 선택된 계정
        self.account.text = account
        
        // 사용자가 계정을 생성하면 이 계정을 선택한 것으로 간주하고 저장
        let plist = UserDefaults.standard
        plist.set(account, forKey: "selectedAccount")
        plist.synchronize()
    }
    
    @objc func pickerDone(_ sender: Any) {
        self.view.endEditing(true)
        
        // 선택된 계정에 대한 커스텀 프로퍼티 파일을 읽어와 세팅한다.
        if let _account = self.account.text {
            let customPlist = "\(_account).plist"
            let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            let path = paths[0] as NSString
            let clist = path.strings(byAppendingPaths: [customPlist]).first!
            let data = NSDictionary(contentsOfFile: clist)
            
            self.name.text = data?["name"] as? String
            self.gender.selectedSegmentIndex = data?["gender"] as? Int ?? 0
            self.married.isOn = data?["married"] as? Bool ?? false
        }
    }
    
    @objc func newAccount(_ sender: Any) {
        self.view.endEditing(true) // 열려있는 입력용 뷰부터 닫아준다.
        
        let alert = UIAlertController(title: "새 계정을 입력하세요.", message: nil, preferredStyle: .alert)
        
        alert.addTextField { UITextField in
            UITextField.placeholder = "ex) abc@gmail.com"
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
            if let account = alert.textFields?[0].text {
                self.accountlist.append(account) // 계정 목록 배열에 추가한다.
                self.account.text = account // 계정 텍스트 필드에 표시한다.
                
                // 컨트롤 값을 모두 초기화한다.
                self.name.text = ""
                self.gender.selectedSegmentIndex = 0
                self.married.isOn = false
                
                // 계정 목록을 통째로 저장한다.
                let plist = UserDefaults.standard
                plist.set(self.accountlist, forKey: "accountlist")
                plist.set(account, forKey: "selectedAccount")
                plist.synchronize()
                
                // 입력 항목을 활성화 한다.
                self.gender.isEnabled = true
                self.married.isEnabled = true
            }
        }))
        
        self.present(alert, animated: false, completion: nil)
    }
    
    @IBAction func changeGender(_ sender: UISegmentedControl) {
        let value = sender.selectedSegmentIndex
        
        // 저장 로직 시작
        let customPlist = "\(self.account.text!).plist"
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let path = paths[0] as NSString
        let plist = path.strings(byAppendingPaths: [customPlist]).first!
        let data = NSMutableDictionary(contentsOfFile: plist) ?? NSMutableDictionary(dictionary: self.defaultPlist) // 저장된 파일이 없을 때 표준 템플릿 딕셔너리가 저장된 defaulPlsit를 사용
        
        data.setValue(value, forKey: "gender")
        data.write(toFile: plist, atomically: true)
    }
    
    @IBAction func changedMarried(_ sender: UISwitch) {
        let value = sender.isOn
        
        // 저장 로직 시작
        let customPlist = "\(self.account.text!).plist"
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let path = paths[0] as NSString
        let plist = path.strings(byAppendingPaths: [customPlist]).first!
        let data = NSMutableDictionary(contentsOfFile: plist) ?? NSMutableDictionary(dictionary: self.defaultPlist)
        
        data.setValue(value, forKey: "married")
        data.write(toFile: plist, atomically: true)
        
        // 값이 제대로 저장되었는지 확인.
        print("custom plist = \(plist)")
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 && (self.account.text?.isEmpty)! == false {
            let alert = UIAlertController(title: nil, message: "이름을 입력하세요", preferredStyle: .alert)
            
            alert.addTextField { UITextField in
                UITextField.text = self.name.text
            }
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
                let value = alert.textFields?[0].text
                
                // 저장 로직 시작
                let customPlist = "\(self.account.text!).plist" // 읽어올 파일명
                let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
                let path = paths[0] as NSString
                let plist = path.strings(byAppendingPaths: [customPlist]).first! // 커스텀 프로퍼티 파일을 읽어온다.
                let data = NSMutableDictionary(contentsOfFile: plist) ?? NSMutableDictionary(dictionary: self.defaultPlist) // 읽어온 파일을 딕셔너리 객체로 변환, 만약 파일이 없다면 새로운 딕셔너리 객체를 생성.
                
                data.setValue(value, forKey: "name")
                data.write(toFile: plist, atomically: true)
                
                self.name.text = value
            }))
            
            self.present(alert, animated: false, completion: nil)
        }
    }
}
