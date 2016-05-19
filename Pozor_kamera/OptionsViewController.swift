//
//  OptionsViewController.swift
//  
//
//  Created by Adam Sekeres on 5.2.2016.


import UIKit


protocol SettingsDelegate {
    func userChangedSwitchValue(value: Bool)
    func userChangedStepperValue(value: Double)
}

class OptionsViewController: UITableViewController {

    var MySwitch : UISwitch?
    var MyStepper: UIStepper?
    var delegate: SettingsDelegate? = nil
    var MyButton: UIButton?
 
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let customSwitch = UISwitch()
        customSwitch.addTarget(self, action: "switchChanged:", forControlEvents: UIControlEvents.ValueChanged)
        
        let Defaults = NSUserDefaults(suiteName: "SettingsDefaults")
        
        if let switchSetting = Defaults?.objectForKey("SwitchValue") as? Bool {
            customSwitch.setOn(switchSetting, animated: false)
        }   else {
                customSwitch.setOn(true, animated: false)
            }
        self.MySwitch = customSwitch
        
        
        let customStepper = UIStepper()
        customStepper.addTarget(self, action: "stepperChanged:", forControlEvents: UIControlEvents.ValueChanged)
        customStepper.maximumValue = 500
        customStepper.minimumValue = 100
        customStepper.stepValue = 50
        
        if let stepperSetting = Defaults?.objectForKey("StepperValue") as? Double {
            customStepper.value = stepperSetting
        }   else {
                customStepper.value = 100.0
            }
        
        self.MyStepper = customStepper
        
        let customButton = UIButton(type: UIButtonType.RoundedRect)
        customButton.setTitle("Send feedback", forState: UIControlState.Normal)
        customButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        customButton.layer.borderColor = UIColor.blackColor().CGColor
        customButton.layer.borderWidth = 0.5
        customButton.frame = CGRect(x: 0, y: 0, width: 110, height: 40)
        customButton.layer.cornerRadius = 10
        
        //customButton.backgroundColor = UIColor.lightGrayColor()
        customButton.addTarget(self, action: "ButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(customButton)
        self.MyButton = customButton
        
        let table = UITableView(frame: self.view.frame)
        table.delegate = self
        table.dataSource = self
        table.tableFooterView = UIView()
        table.tableHeaderView = UIView()
        
        let label = UILabel(frame: CGRectMake(0,0,self.view.frame.size.width,60))
        label.text = "Settings"
        label.font = UIFont(descriptor: UIFontDescriptor(), size: 28)
        label.textAlignment = NSTextAlignment.Center
        label.backgroundColor =  UIColor(colorLiteralRed: 0.18, green: 0.50, blue: 0.82, alpha: 0.6)
        
        table.tableHeaderView = label
        table.tableHeaderView?.setNeedsLayout()
        
        table.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.view.addSubview(table)
        self.tableView = table
    }
   
    
    
    func ButtonTapped(sender: UIButton){
        print("button Tapped")
        MQALogger.feedback("User Feedback", placeholder:"Provide your feedback here.")
     //   MQALogger.f
    }
    
    
    

    
     func stepperChanged(sender: UIStepper){
        if(delegate != nil){
            delegate!.userChangedStepperValue((self.MyStepper?.value)!)
        }
        
        let defaults = NSUserDefaults(suiteName: "SettingsDefaults")
        defaults?.setDouble(sender.value, forKey: "StepperValue")
        defaults?.synchronize()
        
        tableView.reloadData()
    }
    
    func switchChanged(sender: UISwitch){
       if (delegate != nil) {
             delegate!.userChangedSwitchValue(sender.on)
        }
        
        let defaults = NSUserDefaults(suiteName: "SettingsDefaults")
        defaults?.setBool(sender.on, forKey: "SwitchValue")
        defaults?.synchronize()
        tableView.reloadData()
        if(sender.on){
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch (section) {
        case 0:     return "Sounds"
        case 1:     return "Distance notification"
        case 2 :    return "Mobile Quality Assurance"
        default:    return nil
        }
     }
    
   override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
       
        let cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "Cell")
        
        switch (indexPath.section) {
            case 0:     cell.textLabel?.text = "Enable sounds"
                        cell.accessoryView = self.MySwitch
                        break
            
            case 1:     cell.textLabel?.text = "Distance filter"
                        cell.accessoryView = self.MyStepper
                        cell.detailTextLabel!.text = "Actual distance filter = \(self.MyStepper!.value) metres"
                        break
            case 2:         cell.textLabel?.text = "Share your opinions easly"
                          //  cell.accessoryView.
                            cell.accessoryView = self.MyButton
                            //cell.accessoryView?.addSubview(self.MyButton!)
            
            default: break
        }
        
     return cell
    }


    
    
    
    
}
