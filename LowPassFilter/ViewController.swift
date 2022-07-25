//
//  ViewController.swift
//  LowPassFilter
//
//  Created by Seet, Ting Yang Irvin (uif08816) on 25/7/22.
//
// Inspiration: https://www.youtube.com/watch?v=L59S6Aksgmk

import UIKit
import CoreMotion

class ViewController: UIViewController {
  @IBOutlet weak var startStopButton: UIButton!
  @IBOutlet weak var resetButton: UIButton!
  @IBOutlet weak var stepsLabel: UILabel!
  @IBOutlet weak var thresholdTextField: UITextField!

  var motionService = MotionService.shared

  override func viewDidLoad() {
    super.viewDidLoad()

    showStartButton()
    showResetButton()

    // Textfield
    thresholdTextField.delegate = self
    NotificationCenter.default.addObserver(
      self,
      selector:
        #selector(keyboardWillShow),
      name: UIResponder.keyboardWillShowNotification,
      object: nil)
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(keyboardWillHide),
      name: UIResponder.keyboardWillHideNotification,
      object: nil)

    motionService.startService()

    Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _  in
      let steps = self!.motionService.steps
      self!.stepsLabel.text = "Steps: \(steps)"
    }
  }

  fileprivate func showResetButton() {
    resetButton.titleLabel?.font = .systemFont(ofSize: 25.0)
    resetButton.backgroundColor = .white
    resetButton.layer.cornerRadius = 10
    resetButton.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 8.0, leading: 8.0, bottom: 8.0, trailing: 8.0)
  }

  fileprivate func showStartButton() {
    startStopButton.setTitle("START", for: .normal)
    startStopButton.titleLabel?.font = .systemFont(ofSize: 50.0)
    startStopButton.backgroundColor = .green
    startStopButton.tintColor = .white
  }

  fileprivate func showStopButton() {
    startStopButton.setTitle("STOP", for: .normal)
    startStopButton.titleLabel?.font = .systemFont(ofSize: 50.0)
    startStopButton.backgroundColor = .red
    startStopButton.tintColor = .white
  }

  // MARK: - Keyboard
  @objc func keyboardWillShow(notification: NSNotification) {
    if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
      if self.view.frame.origin.y == 0 {
        self.view.frame.origin.y -= keyboardSize.height
      }
    }
  }

  @objc func keyboardWillHide(notification: NSNotification) {
    if self.view.frame.origin.y != 0 {
      self.view.frame.origin.y = 0
    }
  }

  @IBAction func startStopButtonPressed(_ sender: Any) {
    if motionService.isCounting {
      showStartButton()
      motionService.isCounting = false
    } else {
      showStopButton()
      motionService.isCounting = true
    }
  }

  @IBAction func resetButtonPressed(_ sender: Any) {
    motionService.steps = 0
  }
}

// MARK: - UITextFieldDelegate
extension ViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    thresholdTextField.endEditing(true)
    return true
  }

  func textFieldDidEndEditing(_ textField: UITextField) {
    if (textField.text ?? "").isEmpty {
      // do nothing
    } else if let userInput = textField.text, let threshold = userInput.double, threshold.sign == .plus {
      motionService.threshold = threshold
      textField.attributedPlaceholder = NSAttributedString(string: userInput)
    } else {
      let alert = UIAlertController(
        title: "Error",
        message: "Please use positive numbers. E.g., 1, 2.0",
        preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
      self.present(alert, animated: true, completion: nil)
    }
    thresholdTextField.text = ""
  }
}

extension StringProtocol {
  var double: Double? { Double(self) }
  var float: Float? { Float(self) }
  var integer: Int? { Int(self) }
}
