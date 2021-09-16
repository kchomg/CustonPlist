//
//  ListViewController.swift
//  CustonPlist
//
//  Created by Seok Eun Hong on 2021/09/16.
//

import UIKit

class ListViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var account: UITextField!
    
    var accountlist = [String]()
    
    override func viewDidLoad() {
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
    }
    
    @objc func pickerDone(_ sender: Any) {
        self.view.endEditing(true)
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
            }
        }))
        
        self.present(alert, animated: false, completion: nil)
    }
}
