import UIKit
import MapKit
import CoreLocation
import WatchConnectivity

class DistanceTableViewController: UIViewController,UITableViewDelegate, UITableViewDataSource,WCSessionDelegate {
    
    var session : WCSession!
    weak var tableView : UITableView!
    var records : [Kamera]!
    var NotificationCenter: NSNotificationCenter!
    var userIsNearTheCameraArea : Bool!
    
     var userLocation : CLLocation? {
        didSet{
            if let tableView = self.tableView {
                if self.records != nil {
                    if (self.records.count > 0 ) {
                        self.records = sortRecords(dataToSort: self.records)
                        
                        //MARK: Data to WATCH
                        sendDataToAppleWatch(dataToSend: records)
                     }
                   tableView.reloadData()
                }
            } else {
                    if self.records != nil {
                        if (self.records.count > 0 ) {
                            self.records = sortRecords(dataToSort: self.records)
                            //MARK: Data to WATCH
                            sendDataToAppleWatch(dataToSend: records)
                        }
                    }
                }
        }
    }
    
    //Send data to app extension
    func sendDataToAppleWatch(dataToSend data: [Kamera]) -> Bool {
        var dataToWatch = [NSDictionary]()
        
        if(WCSession.isSupported()){
            print("WCsession supported on Iphone")
            
            if let userLocation = self.userLocation {
            
                    for index in 0..<9 {
                        if let longitude = records[index].longitude  {
                            if let latitude = records[index].latitude{
                                    // Creating camera CLLocation
                                    let cameraLocation = CLLocation(latitude: latitude.doubleValue,     longitude: longitude.doubleValue)
                                    let distance =  userLocation.distanceFromLocation(cameraLocation)
                                let dictionary = NSDictionary(dictionary: ["meno":records[index].meno, "distance" : distance])
                                dataToWatch.append(dictionary)
                            }
                        }
                    }
                
                self.session = WCSession.defaultSession()
                self.session.delegate = self
                self.session.activateSession()
                self.session.sendMessage(["cameraRecords": dataToWatch ], replyHandler: nil, errorHandler: { (error) -> Void in
                    print(error)
                })
             }
        } else {
            return false
        }
        return true
    }
    
    
     override func viewDidLoad() {
        super.viewDidLoad()
        let table = UITableView(frame: self.view.frame)
        table.delegate = self
        table.dataSource = self
        table.tableFooterView = UIView()
        table.tableHeaderView = UIView()
        
        let label = UILabel(frame: CGRectMake(0,0,self.view.frame.size.width,60))
        label.text = "Cameras around me"
        label.font = UIFont(descriptor: UIFontDescriptor(), size: 28)
        label.textAlignment = NSTextAlignment.Center
        label.backgroundColor =  UIColor(colorLiteralRed: 0.18, green: 0.50, blue: 0.82, alpha: 0.6)
        
        table.tableHeaderView = label
        table.tableHeaderView?.setNeedsLayout()
        
        table.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.view.addSubview(table)
        tableView = table
        
        self.view.updateConstraints()
     }

    //MARK: tablestuff
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("nastavujem pocet poloziek tabulky")
        if let records = self.records {
            return records.count
        }
        return 0
    }
    
    //Configure table cell
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "Cell")
        
        if let name = records[indexPath.row].meno {
        cell.textLabel?.text = name
        }
        
        if let location = self.userLocation {
                let userLocation = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                if let longitude = records[indexPath.row].longitude  {
                        if let latitude = records[indexPath.row].latitude{
                            // Creating camera CLLocation
                            let cameraLocation = CLLocation(latitude: latitude.doubleValue,     longitude: longitude.doubleValue)
                            // Method calculate distance from two CLLocations return in metres
                                let distance =  userLocation.distanceFromLocation(cameraLocation)
                            if distance < 1000 {
                               cell.detailTextLabel?.text = String.localizedStringWithFormat("Camera distance is %.1f m.", distance)
                            } else {
                                 cell.detailTextLabel?.text = String.localizedStringWithFormat("Camera distance is %.2f km.", distance/1000)
                            }
                         }
                }
         }
            else {
                cell.detailTextLabel?.text = "Loading camera distance..."
            }
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
    
     func sortRecords(var dataToSort  records: [Kamera]) -> [Kamera]{
        records.sortInPlace({ (k1:Kamera, k2:Kamera) -> Bool in
            
            let cameraLocation1 = CLLocation(latitude: k1.latitude!.doubleValue,     longitude: k1.longitude!.doubleValue)
            let cameraLocation2 = CLLocation(latitude: k2.latitude!.doubleValue,     longitude: k2.longitude!.doubleValue)
            
            let distance1 = self.userLocation!.distanceFromLocation(cameraLocation1)
            let distance2 = self.userLocation!.distanceFromLocation(cameraLocation2)
            
            return distance1 < distance2
        })
        
        return records
    }
}

