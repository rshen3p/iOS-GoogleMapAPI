//
//  FinalIteration2ViewController.swift
//  GoogleMapsAPI-4900
//
//  Created by Jan Ycasas on 2016-04-29.
//  Copyright © 2016 Jan Ycasas. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import GoogleMaps
import MBProgressHUD

class FinalIteration2ViewController: UIViewController,
                                     UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var filterType: UILabel!
    @IBOutlet weak var myTable: UITableView!
    
    var long            : Double!
    var lat             : Double!
    var locationList    : Array<Location>    = Array<Location>()
    var filter          : String             = "All"
    var currentLocation : CLLocation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentLocation = CLLocation(latitude: lat,longitude: long)
        filterType.text = filter + " Types"
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "ReachabilityStatusChanged", name: "ReachStatusChanged", object: nil)
        currentLocation = CLLocation(latitude: lat,longitude: long)
    }
    
    override func viewDidAppear(animated: Bool) {
        
    }
    
    func ReachabilityStatusChanged(){
        if(reachabilityStatus == kNOTREACHABLE ){
            let alertController = UIAlertController(title: "Lost Internet Connection", message:
                "Please connect to internet to use the app", preferredStyle: .ActionSheet)
            self.presentViewController(alertController, animated: true, completion: nil)
        }else if reachabilityStatus == kREACHABLE {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "ReachStatusChanged", object: nil)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    func initialSetUp(){
        
        let util : Utility?
        
        util = Utility()
        
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), {
            // Do something...
            util!.getAllLocations(self.lat,long: self.long, name : "",
                                  type: "doctor|hospital|pharmacy|physiotherapist") {
                choiceList in
                
                self.locationList = choiceList
                self.myTable.reloadData()
            }
        });
    }
    
    func filterResults(type : String, name : String){
        let util        : Utility?
        var resultType  : String!
        
        util = Utility()
        
        if(type == "All"){
            resultType = "doctor|hospital|pharmacy|physiotherapist"
        } else {
            resultType = type.lowercaseString
        }
        
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), {
            // Do something...
            util!.getAllLocations(self.lat,long: self.long, name: name,
                                  type: resultType) {
                choiceList in
                
                self.locationList = choiceList
                self.myTable.reloadData()
            }
        });
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if(segue.identifier == "goToFinalIteration2MapViewController") {
            let yourNextViewController = (segue.destinationViewController as! FinalIteration2MapViewController)
            
            yourNextViewController.lat          = lat!
            yourNextViewController.long         = long!
            yourNextViewController.locationList = locationList
            yourNextViewController.filter       = filter
        }
        
        if(segue.identifier == "goToFinalIteration2DetailViewController"){
            if let indexPath = myTable.indexPathForSelectedRow {
                
                let viewController = segue.destinationViewController as! FinalIteration2DetailViewController
                viewController.lat          = lat!
                viewController.long         = long!
                viewController.locationList = locationList
                viewController.location     = locationList[indexPath.row]
                viewController.filter       = filter
                
                viewController.initialSetUp()
            }
        }
        
        if(segue.identifier == "goToFilterViewController") {
            let yourNextViewController = (segue.destinationViewController as! FinalIteration2FilterViewController)
            
            yourNextViewController.lat          = lat!
            yourNextViewController.long         = long!
            yourNextViewController.locationList = locationList
            yourNextViewController.filter       = filter
        }
        
        
    }
    
    // MARK: -- TableView
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locationList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let util = Utility()
        
        var cell             : CustomeCell2?
        let placeLocation    : CLLocation    = CLLocation(latitude: locationList[indexPath.row].lat,
                                                         longitude: locationList[indexPath.row].long)
        var type             : String        = locationList[indexPath.row].type
        
        let distanceInMeters  = currentLocation.distanceFromLocation(placeLocation)/1000
        
        type = util.formatString(type)
        
        cell = self.myTable.dequeueReusableCellWithIdentifier("mycell2",forIndexPath: indexPath) as?
        CustomeCell2
        
        
        cell?.name.text     = locationList[indexPath.row].name
        cell?.address.text  = locationList[indexPath.row].vicinity
        cell?.category.text = type
        
        cell?.distance.text = String(format: "%.2f", distanceInMeters) + " M"
        
        return cell!
    }
    
}

