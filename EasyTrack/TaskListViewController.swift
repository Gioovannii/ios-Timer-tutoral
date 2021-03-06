/// Copyright (c) 2018 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit

class TaskListViewController: UIViewController {
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var balloon: Balloon!
  
  // Properties for handleAnimation timer, animation startand end.
  // animation duration and animation height
  
  var animationTimer: Timer?
  var startTime: TimeInterval?, endTime: TimeInterval?
  let animationDuration = 3.0
  var height: CGFloat = 0
  
  var taskList: [Task] = []
  var timer: Timer?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
      target: self,
      action: #selector(presentAlertController))
  }
}

// MARK: - UITableViewDelegate
extension TaskListViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let cell = tableView.cellForRow(at: indexPath) as? TaskTableViewCell else {
      return
    }
    
    cell.updateState()
  }
}

// MARK: - UITableViewDataSource
extension TaskListViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView,
                 numberOfRowsInSection section: Int) -> Int {
    return taskList.count
  }
  
  func tableView(_ tableView: UITableView,
    cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath)
    
    if let cell = cell as? TaskTableViewCell {
      cell.task = taskList[indexPath.row]
    }
    
    return cell
  }
}

// MARK: - Actions
extension TaskListViewController {
  @objc func presentAlertController(_ sender: UIBarButtonItem) {
    createTimer()
    let alertController = UIAlertController(title: "Task name",
      message: nil,
      preferredStyle: .alert)
    alertController.addTextField { textField in
      textField.placeholder = "Task name"
      textField.autocapitalizationType = .sentences
    }
    let createAction = UIAlertAction(title: "OK", style: .default) {
      [weak self, weak alertController] _ in
      guard
        let self = self,
        let text = alertController?.textFields?.first?.text
        else {
          return
      }
      
      DispatchQueue.main.async {
        let task = Task(name: text)
        
        self.taskList.append(task)
        
        let indexPath = IndexPath(row: self.taskList.count - 1, section: 0)
        
        self.tableView.beginUpdates()
        self.tableView.insertRows(at: [indexPath], with: .top)
        self.tableView.endUpdates()
      }
    }
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    
    alertController.addAction(createAction)
    alertController.addAction(cancelAction)
    
    present(alertController, animated: true, completion: nil)
  }
}

extension TaskListViewController {
  @objc func updateTimer() {
    if let fireDateDescription = timer?.fireDate.description { print(fireDateDescription) }
    
    // 1 check if there is any visible rows containing tasks
    guard let visibleRowsIndexPaths = tableView.indexPathsForVisibleRows else { return }
    
    for indexPath in visibleRowsIndexPaths {
      // 2 Calls updateTime for every visible cell
      if let cell = tableView.cellForRow(at: indexPath) as? TaskTableViewCell {
        cell.updateTime()
      }
    }
  }

  func createTimer() {
    // 1 check if timer contain an instance of timer
    if timer == nil {
      // 2 if not set timer to a repeating timer which call updateTimer
      let timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
      // Timer use the main thread when his busy the UI became unresponsive !!
      RunLoop.current.add(timer, forMode: .common)
      timer.tolerance = 0.1
      
      self.timer = timer
    }
  }
}


extension TaskListViewController {
  func showCongratulationAnimation() {
    // Calculate right height base on device screen height
    height = UIScreen.main.bounds.height + balloon.frame.size.height
    // 2 center ballon outside of screen for set its visibility
    balloon.center = CGPoint(x: UIScreen.main.bounds.width / 2, y: height + balloon.frame.size.height / 2)
    balloon.isHidden = false
    
    //3 set startTime and calculatre his endTime by addind the animation duration
    startTime = Date().timeIntervalSince1970
    endTime = animationDuration + startTime!
    
    // 4 Start animation Timer and have it update the progress of the animation so 60 time per second
    animationTimer = Timer.scheduledTimer(withTimeInterval: 1 / 60, repeats: true) { timer in
      // TODO: - Animation here
      self.updateAnimation()

    }
  }
  
  func updateAnimation() {
    // 1 check if endTime and start time is not nil
    guard let endTime = endTime, let startTime = startTime else { return }
    
    // 2 save current time to a constant
    let now = Date().timeIntervalSince1970
    
    // 3 Ensure current time has not passed the end time or invalidate  and hide balloon
    if now >= endTime {
      animationTimer?.invalidate()
      balloon.isHidden = true
    }
    
    // 4 calculate animation percentage and desired y coordinate
    let percentage = (now - startTime) * 100 / animationDuration
    let y = height - ((height + balloon.frame.height / 2) / 100 * CGFloat(percentage))
    
    // 5 Set ballon center position 
    balloon.center = CGPoint(x: balloon.center.x + CGFloat.random(in:  -0.5...0.5), y: y)
    
  }
   
   
}
