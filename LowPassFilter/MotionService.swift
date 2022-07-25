//
//  MotionService.swift
//  LowPassFilter
//
//  Created by Seet, Ting Yang Irvin (uif08816) on 25/7/22.
//

import CoreMotion
import UIKit

public class MotionService {
  static let shared = MotionService()
  let motionManager = CMMotionManager()
  var isCounting = false
  var steps = 0
  var threshold = 1.0

  func startService() {
    motionManager.deviceMotionUpdateInterval = 0.1
    motionManager.startDeviceMotionUpdates(to: OperationQueue.main) { [self] motionManager, error in
      if let acc = motionManager?.userAcceleration {
        if (fabs(acc.x) > self.threshold) || (fabs(acc.y) > self.threshold) || (fabs(acc.z) > self.threshold) {
          print("steps detected")
          if self.isCounting {
            self.steps += 1
          }
        }
      }
    }
  }

  // MARK: - Restart sensors when switching between foreground/background
  private let opQueue: OperationQueue = {
    let opQueue = OperationQueue()
    opQueue.name = "core-motion-updates"
    return opQueue
  }()

  private var shouldRestartMotionUpdates = false

  init() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(appDidEnterBackground),
      name: UIApplication.didEnterBackgroundNotification,
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(appDidBecomeActive),
      name: UIApplication.didBecomeActiveNotification,
      object: nil
    )
  }

  deinit {
    NotificationCenter.default.removeObserver(
      self,
      name: UIApplication.didEnterBackgroundNotification,
      object: nil
    )
    NotificationCenter.default.removeObserver(
      self,
      name: UIApplication.didBecomeActiveNotification,
      object: nil
    )
  }

  func start() {
    self.shouldRestartMotionUpdates = true
    self.restartMotionUpdates()
  }

  func stop() {
    self.shouldRestartMotionUpdates = false
    self.motionManager.stopDeviceMotionUpdates()
  }

  @objc private func appDidEnterBackground() {
    self.restartMotionUpdates()
  }

  @objc private func appDidBecomeActive() {
    self.restartMotionUpdates()
  }

  private func restartMotionUpdates() {
    guard self.shouldRestartMotionUpdates else { return }
    self.motionManager.stopDeviceMotionUpdates()
    self.motionManager.startDeviceMotionUpdates(using: .xArbitraryZVertical, to: self.opQueue) { deviceMotion, _ in
      guard deviceMotion != nil else { return }
      print(deviceMotion)
    }
  }
}

