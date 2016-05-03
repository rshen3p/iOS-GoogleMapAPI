//
//  UtilityClass.swift
//  GoogleMapsAPI-4900
//
//  Created by Jan Ycasas on 2016-05-02.
//  Copyright © 2016 Jan Ycasas. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

public class Utility{
    
    func doHttpRequest(lat : Double, long : Double,completion: (locationList: Array<Location>) -> Void) {

        var locationList : Array<Location> = Array<Location>()
        let coord = String(lat) + "," + String(long)
        print(coord)
        
        print("http request")
        
        Alamofire.request(.GET, "https://maps.googleapis.com/maps/api/place/nearbysearch/json", parameters: [   "location"  :   coord,
                            "radius"    :   "10000",
                            "type"      :   "hospital",
                            //"name"      :   "harbour",
                            "key"       :   "AIzaSyBWQyWLKeu_VGL2RgXeyM-_TgBSTDP9-Fs",
            ]).responseJSON { response in

                switch response.result {
                    case .Success:
                        if let responseJSON = response.result.value {
                            
                            let mainJSON    = JSON(responseJSON)
                            
                            for (_, subJson) in mainJSON["results"] {
                                
                                var name            : String    = ""
                                var lat             : Double    = 0.0
                                var long            : Double    = 0.0
                                var vicinity        : String    = ""
                                var rating          : Int       = 0
                                var currentlyOpen   : String    = "Unknown"
                                
                                if let resultName = subJson["name"].string {
                                    name = resultName
                                }
                                
                                if let resultLat = subJson["geometry"]["location"]["lat"].double {
                                    lat = resultLat
                                }
                                
                                if let resultLong = subJson["geometry"]["location"]["lng"].double {
                                    long = resultLong
                                }
                                
                                if let resultVicinity = subJson["vicinity"].string {
                                    vicinity = resultVicinity
                                }
                                
                                if let resultRating = subJson["rating"].int {
                                    rating = resultRating
                                }
                                
                                if let resultCurrentlyOpen = subJson["opening_hours"]["open_now"].bool {
                                    if(resultCurrentlyOpen){
                                        currentlyOpen = "Open"
                                    } else {
                                        currentlyOpen = "Closed"
                                    }
                                }
                                
                                let location = Location(name : name, lat : lat, long: long, vicinity: vicinity, rating: rating, currentlyOpen: currentlyOpen)
                                
                                locationList.append(location)
                                
                            }
                            completion(locationList: locationList)
                    }

                    case .Failure(let error):
                        print(error)
                }
        }
    }
    
}