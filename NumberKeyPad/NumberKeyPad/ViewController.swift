//
//  ViewController.swift
//  NumberKeyPad
//
//  Created by 60067659 on 30/01/2020.
//  Copyright © 2020 최승민. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    var btnComma: UIButton = UIButton.init(type: .custom)

    @objc func custBtnClickEvent() {
        textField.keyboardType = .namePhonePad
        textField.reloadInputViews()
        self.btnComma.isHidden = true
        self.view.sendSubviewToBack(self.btnComma)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    }

    @objc func keyboardWillShow() {
        DispatchQueue.main.async {
            self.textField.becomeFirstResponder()
            if self.textField.keyboardType == .numberPad {

                self.btnComma.tag = 15000
                // Keyboard 뷰를 찾는다.
                let keyboard: UIView? = self.findKeyboard()
                // Button 의 크기를 Keyboard의 각 키만큼 뽑는다.
                self.btnComma.frame = self.findKeySizeForView(view: keyboard)

                // Button 속성
                self.btnComma.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 5, right: 0)
                self.btnComma.backgroundColor = .clear

                // PrimaryLanguage 에 따라서 나타나는 button 의 텍스트가 변경된다.
                if self.textField.textInputMode?.primaryLanguage?.contains("ko") ?? false {
                    self.btnComma.setTitle("한글", for: .normal)
                } else if self.textField.textInputMode?.primaryLanguage?.contains("en") ?? false {
                    self.btnComma.setTitle("ABC", for: .normal)
                } else {
                    self.btnComma.setTitle("문자", for: .normal)
                }

                self.btnComma.adjustsImageWhenHighlighted = false
                self.btnComma.setTitleColor(.black, for: .normal)
                self.btnComma.titleLabel?.font = UIFont.systemFont(ofSize: 20)
                self.btnComma.addTarget(self, action: #selector(self.custBtnClickEvent), for: .touchUpInside)
                self.btnComma.addTarget(self, action: #selector(self.custBtnClickEvent), for: .allEvents)
                keyboard!.addSubview(self.btnComma)
                keyboard?.layoutIfNeeded()
                self.view.layoutIfNeeded()
            }
        }
    }

    //Keyboard View를 찾는다.
    func findKeyboard() -> UIView? {
        for window in UIApplication.shared.windows {
            let inputSetContainer = self.viewWithPrefix(at: "<UIInputSetContainerView", in: window)
            if inputSetContainer != nil {
                let inputSetHost = self.viewWithPrefix(at: "<UIInputSetHostView", in: inputSetContainer!)

                if inputSetHost != nil {
                    let kbinputbackdrop = self.viewWithPrefix(at: "<_UIKBCompatInput", in: inputSetHost!)
                    if kbinputbackdrop != nil {
                        let theKeyboard = self.viewWithPrefix(at: "<UIKeyboard", in: kbinputbackdrop!)
                        return theKeyboard
                    }
                }
            }
        }
        return nil
    }

    // 각 Device 에 맞는 Keyboard 버튼들의 사이즈를 구한다.
    func findKeySizeForView(view: UIView?) -> CGRect {
        if let view = view {
            if let uiKeyboardImpl = self.viewWithPrefix(at: "<UIKeyboardImpl", in: view) {
                if let uiKeyboardLayoutStar = self.viewWithPrefix(at: "<UIKeyboardLayoutStar", in: uiKeyboardImpl) {
                    if let uiKBKeyplaneView = self.viewWithPrefix(at: "<UIKBKeyplaneView", in: uiKeyboardLayoutStar) {
                        for view in uiKBKeyplaneView.subviews {
                            let pointOrigin: CGPoint = view.layer.frame.origin
                            if pointOrigin.x <= 0, pointOrigin.y == uiKBKeyplaneView.frame.size.height - view.frame.size.height, view.description.hasPrefix("<UIKBKeyView") {
                                return view.layer.frame
                            }
                        }
                    }
                }
            }

        }

        return CGRect.zero
    }

    // SubView의 Description 을 뽑아오는 함수.
    func viewWithPrefix(at prefix: String, in view: UIView) -> UIView? {
        for subview in view.subviews {
            if subview.description.hasPrefix(prefix) {
                return subview
            }
        }
        return nil
    }

}

