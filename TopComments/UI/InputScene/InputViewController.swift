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

private let segueIdentifier = "ShowComments"

class InputViewController: UIViewController, UITextFieldDelegate {

    private let maxBound = 500
    private let paginationConst = 10
    private var responseResults = [Comment]()
    
    private let networkService = NetworkService()
    private var wasCanceled = false
    
    @IBOutlet weak var lowerBoundTextField: UITextField!
    @IBOutlet weak var upperBoundTextField: UITextField!
    @IBOutlet weak var requestButton: UIButton!
    @IBOutlet weak var activityIndicator: NVActivityIndicatorView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    //MARK: - UIView
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lowerBoundTextField.delegate = self
        upperBoundTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        //adding an observer for managing the view during keyboard events
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK - UITextField Delegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        //letting a user to enter only numbers
        let newString = NSString(string: textField.text!).replacingCharacters(in: range, with: string)
        let allowedCharacters = CharacterSet(charactersIn:"0123456789")
        let characterSet = CharacterSet(charactersIn: newString)
        
        //letting user to enter only 3 characters and not grater than max ammount of comments
        if newString.count > 3  || !allowedCharacters.isSuperset(of: characterSet) || (Int(newString) != nil && Int(newString)! > maxBound) {
            return false
        }

        //enabling request button only when the user entered something
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
        
        //focusing the request button slightly higher than the top edge of the keyboard when it apperars
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
    
    @IBAction func requestButtonPressed() {
        lowerBoundTextField.resignFirstResponder()
        upperBoundTextField.resignFirstResponder()
        
        //pressing on the button which can either create a network request, or cancel it
        
        guard let buttonType = ButtonTitle(rawValue: requestButton.title(for: .normal)!) else { return }
        
        switch buttonType {
        case .cancel:
            wasCanceled = true
            cancelFetchRequest()
        case .request:
            wasCanceled = false
            guard let lowerBound = Int(lowerBoundTextField.text!) else {return}
            guard var upperBound = Int(upperBoundTextField.text!) else {return}
            
            if lowerBound < upperBound {
                requestButton.setTitle(ButtonTitle.cancel.rawValue, for: .normal)
                activityIndicator.startAnimating()
                if (upperBound - lowerBound) >= self.paginationConst {
                    upperBound = lowerBound + self.paginationConst
                }
                performFetchRequest(lowerBound, to: upperBound)
            } else {
                presentAlert(with: "The upper bound should be grater than the lower bound")
            }
        }
    }
    
    private var delayEventsCombiner: EventsCombiner?
    
    private func performFetchRequest(_ startId: Int, to endId: Int) {
        
        //combining 2 events: a loading animation for 3 seconds and a network request
        
        delayEventsCombiner = EventsCombiner(totalEvents: 2) { [weak self] in
            defer {
                self?.activityIndicator.stopAnimating()
            }
            
            if self?.responseResults.count == 0 {
                self?.presentAlert(with: "Can not fetch comments")
                return
            }
            if self?.wasCanceled ?? false {
                return
            }
            
            self?.performSegue(withIdentifier: segueIdentifier, sender: self)
        }
        
        Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { [weak self] timer in
            defer {
                self?.delayEventsCombiner?.completeOne()
            }
            self?.requestButton.setTitle(ButtonTitle.request.rawValue, for: .normal)
        }
        
        networkService.fetchCommentsFrom(startId, to: endId) { [weak self] comments in
            defer {
                self?.delayEventsCombiner?.completeOne()
            }
            
            guard let comments = comments else {
                self?.presentAlert(with: "Network error")
                return
            }
            self?.responseResults = comments
        }
    }
    
    private func presentAlert(with message: String) {
        let alertController = UIAlertController(title: "Attention!", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    private func cancelFetchRequest(){
        
        //attempt to cancel a current request
        activityIndicator.stopAnimating()
        requestButton.setTitle(ButtonTitle.request.rawValue, for: .normal)
        
        //in some cases a network request is too fast to cancel, we have a response and the alert won't be shown
        networkService.cancelRequest(completion: { [weak self] in
            self?.presentAlert(with: "Current request was canceled")
        })
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

private class EventsCombiner {
    
    private let completion: () -> Void
    private let totalEvents: Int
    private var completeEvents: Int = 0
    
    init(totalEvents: Int, completion: @escaping (() -> Void)) {
        self.totalEvents = totalEvents
        self.completion = completion
    }
    
    func completeOne() {
        completeEvents += 1
        if totalEvents == completeEvents {
            completion()
        }
    }
    
}

