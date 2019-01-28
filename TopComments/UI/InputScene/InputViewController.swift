//
//  InputViewController.swift
//  TopComments
//
//  Created by  Oleksandra on 1/26/19.
//  Copyright © 2019 sandra-alt. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

private enum ButtonTitle : String {
    case request = "Show Comments"
    case cancel = "Cancel"
}

class InputViewController: UIViewController, UITextFieldDelegate {

    private let maxBound = 500
    private let paginationConst = 10
    private var responseResults = [Comment]()
    private let networkService = NetworkService()
    
    @IBOutlet weak var lowerBoundTextField: UITextField!
    @IBOutlet weak var upperBoundTextField: UITextField!
    @IBOutlet weak var requestButton: UIButton!
    @IBOutlet weak var activityIndicator: NVActivityIndicatorView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lowerBoundTextField.delegate = self
        upperBoundTextField.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name:.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK - UITextField Delegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newString = NSString(string: textField.text!).replacingCharacters(in: range, with: string)
        let allowedCharacters = CharacterSet(charactersIn:"0123456789")
        let characterSet = CharacterSet(charactersIn: newString)
        if newString.count > 3  || !allowedCharacters.isSuperset(of: characterSet) || (Int(newString) != nil && Int(newString)! > maxBound) {
            return false
        }

        let validInput = (newString.count > 0) && ((textField.isEqual(lowerBoundTextField) && (upperBoundTextField.text != ""))  || (textField.isEqual(upperBoundTextField) && (lowerBoundTextField.text != "")))
        
        requestButton.isEnabled = validInput
        
        return true
    }
    
    //MARK: - Keyboard Handling
    
    @objc func keyboardWillShow(notification:NSNotification){
        guard let keyboardFrameValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        let keyboardFrame = view.convert(keyboardFrameValue.cgRectValue, from: nil)
        
        var contentInset:UIEdgeInsets = scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        scrollView.contentInset = contentInset
        
        let verticalSpaceToKeyboard: CGFloat = 20.0
        
        var aRect = requestButton.frame
        aRect.size.height += verticalSpaceToKeyboard
        scrollView.scrollRectToVisible(aRect, animated: true)
    }
    
    @objc func keyboardWillHide(notification:NSNotification){
        let contentInset: UIEdgeInsets = .zero
        scrollView.contentInset = contentInset
    }
    
    // MARK: - Button Actions and Navigation
    
    private let segueIdentifier = "ShowComments"
    
    @IBAction func requestButtonPressed() {
        lowerBoundTextField.resignFirstResponder()
        upperBoundTextField.resignFirstResponder()
        
        guard let buttonType = ButtonTitle(rawValue: requestButton.title(for: .normal)!) else {
            return
        }
        switch buttonType {
        case .cancel:
            networkService.cancelRequest(completion: {
                self.activityIndicator.stopAnimating()
                self.requestButton.setTitle(ButtonTitle.request.rawValue, for: .normal)
            })
            
        default:
            
            guard let lowerBound = Int(lowerBoundTextField.text!) else {return}
            guard var upperBound = Int(upperBoundTextField.text!) else {return}
            
            if lowerBound < upperBound {
                requestButton.setTitle(ButtonTitle.cancel.rawValue, for: .normal)
                activityIndicator.startAnimating()

                if (upperBound - lowerBound) >= self.paginationConst {
                    upperBound = lowerBound + self.paginationConst
                }
                networkService.fetchCommentsFrom(lowerBound, to: upperBound, completion: { (comments) in
                        self.activityIndicator.stopAnimating()
                        self.requestButton.setTitle(ButtonTitle.request.rawValue, for: .normal)
                        self.responseResults = comments
                        self.performSegue(withIdentifier: self.segueIdentifier, sender: self)
                })
            } else {
                presentAlert()
            }
        }
    }
    
    func presentAlert() {
        let alertController = UIAlertController(title: "Alert", message: "The upper bound should be grater than the lower bound", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueIdentifier {
            let commentsViewController: CommentsViewController = segue.destination as! CommentsViewController
            commentsViewController.comments = responseResults
            commentsViewController.startId = Int(lowerBoundTextField.text!)!
            commentsViewController.endId = Int(upperBoundTextField.text!)!
        }
    }
    
}

