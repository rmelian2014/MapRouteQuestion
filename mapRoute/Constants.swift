//
//  Constants.swift
//  mapRoute
//
//  Created by AJ on 3/14/18.
//  Copyright © 2018 AJ. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit


//Update the library every this value step
let UPDATE_RESTURANT_RATE = CGFloat(100)

let GOOGLE_API_KEY = "AIzaSyCp7hrsSePGkvwnWmJ4OA3UAAMzE7JoHss"       //google api key
let SHEARCH_DISTANCE = CGFloat(5000)                                  //radius of search
let FIND_PLCAE_URL = "https://maps.googleapis.com/maps/api/place/nearbysearch/json"   //google places api url
let MAP_ZOOM_LEVEL = 0.07                                              //camera zoom
let SHARE_MESSAGE = "Hey Checkout this awesome book!"                  //message of share button



//get the google places api url for coordinate
func getUrlForGas_station(coord:CLLocationCoordinate2D)->String
{
    return "\(FIND_PLCAE_URL)?location=\(coord.latitude),\(coord.longitude)&radius=\(SHEARCH_DISTANCE)&type=gas_station&key=\(GOOGLE_API_KEY)"
}
