//
//  ViewController.swift
//  CMPedometerExample
//
//  Created by 박성원 on 2018. 4. 6..
//  Copyright © 2018년 step. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var avgPace: UILabel!
    @IBOutlet weak var paceLabel: UILabel!
    @IBOutlet weak var steps: UILabel!
    @IBOutlet weak var statusTitle: UILabel!
    
    let stopColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
    let startColor = UIColor(red: 0.0, green: 0.75, blue: 0.0, alpha: 1.0)

    var numberOfSteps:Int! = nil

    var distance:Double = 0.0
    var averagePace:Double = 0.0
    var pace:Double = 0.0

    var pedometer = CMPedometer()

    var timer = Timer()
    var timerInterval = 1.0
    var timeElapsed:TimeInterval = 1.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func startStopAction(_ sender: UIButton) {
        if sender.titleLabel?.text == "Start"{
            pedometer = CMPedometer()
            startTimer()
            pedometer.startUpdates(from: Date(), withHandler: { (pedometerData, error) in
                if let pedData = pedometerData{
                    self.numberOfSteps = Int(truncating: pedData.numberOfSteps)
                    if let distance = pedData.distance{
                        self.distance = Double(truncating: distance)
                    }
                    if let averageActivePace = pedData.averageActivePace {
                        self.averagePace = Double(truncating: averageActivePace)
                    }
                    if let currentPace = pedData.currentPace {
                        self.pace = Double(truncating: currentPace)
                    }
                } else {
                    self.numberOfSteps = nil
                }
            })
            
            statusTitle.text = "Pedometer On"
            sender.setTitle("Stop", for: .normal)
            sender.backgroundColor = stopColor
        }
        else {
            pedometer.stopUpdates()
            stopTimer()
            
            statusTitle.text = "Pedometer Off: " + timeIntervalFormat(interval: timeElapsed)
            sender.backgroundColor = startColor
            sender.setTitle("Start", for: .normal)
        }
    }
    
    //MARK: - timer functions
    func startTimer() {
        if timer.isValid { timer.invalidate() }
        timer = Timer.scheduledTimer(timeInterval: timerInterval, target: self,selector: #selector(timerAction(timer:)), userInfo: nil,repeats: true)
    }
    
    func stopTimer() {
        timer.invalidate()
        displayPedometerData()
    }
    
    @objc func timerAction(timer:Timer) {
        displayPedometerData()
    }
    
    func displayPedometerData() {
        timeElapsed += 1.0
        statusTitle.text = "On: " + timeIntervalFormat(interval: timeElapsed)
        
        if let numberOfSteps = self.numberOfSteps{
            steps.text = String(format:"Steps: %i",numberOfSteps)
        }

        distanceLabel.text = String(format:"Distance: %02.02f meters,\n %02.02f mi",distance,miles(meters: distance))
        avgPace.text = paceString(title: "Avg Pace", pace: averagePace)
        paceLabel.text = paceString(title: "Pace:", pace: pace)
    }
    
    func timeIntervalFormat(interval: TimeInterval) -> String {
        var seconds = Int(interval + 0.5)
        let hours = seconds / 3600
        let minutes = (seconds / 60) % 60
        seconds = seconds % 60
        return String(format:"%02i:%02i:%02i",hours,minutes,seconds)
    }

    func paceString(title: String, pace: Double) -> String {
        var minPerMile = 0.0
        let factor = 26.8224 //conversion factor
        if pace != 0 {
            minPerMile = factor / pace
        }
        let minutes = Int(minPerMile)
        let seconds = Int(minPerMile * 60) % 60
        
        return String(format: "%@: %02.2f m/s \n\t\t %02i:%02i min/mi",title,pace,minutes,seconds)
    }
    
    func computedAvgPace() -> Double {
        pace = distance / timeElapsed
        return pace
    }
    
    func miles(meters: Double) -> Double {
        let mile = 0.000621371192
        return meters * mile
    }
    
}

