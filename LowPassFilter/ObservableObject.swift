//
//  ObservableObject.swift
//  LowPassFilter
//
//  Created by Seet, Ting Yang Irvin (uif08816) on 25/7/22.
//

import Foundation

class ObservableObject<T> {
  var value: T? {
    didSet {
      DispatchQueue.main.async {
        self.listener?(self.value)
      }
    }
  }

  init( _ value: T?) {
    self.value = value
  }

  private var listener: ((T?) -> Void)?

  func bind(_ listener: @escaping (T?) -> Void) {
    listener(value)
    self.listener = listener
  }
}
