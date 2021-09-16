//
//  ListViewController.swift
//  CustonPlist
//
//  Created by Seok Eun Hong on 2021/09/16.
//

import UIKit

class ListViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var account: UITextField!
    
    var accountlist = ["sqlpro@naver.com",
                       "webmaster@rubypaper.co.kr",
                       "abc1@gmail.com",
                       "abc2@gmail.com",
                       "abc3@gmail.com"
    ]
    
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
        
        // 버튼을 툴 바에 추가
        toolbar.setItems([done], animated: true)
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
}
