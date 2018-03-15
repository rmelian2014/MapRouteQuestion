//
//  Location.swift
//  mapRoute
//
//  Created by AJ on 3/14/18.
//  Copyright © 2018 AJ. All rights reserved.
//

import Foundation
import CoreLocation

public class Location
{
    private var _coord:CLLocationCoordinate2D!
    private var _title:String!
    private var _desc:String!
    
    var coord:CLLocationCoordinate2D
    {
        return _coord
    }
    
    var title:String{
        return _title
    }
    var desc:String{
        return _desc
    }
    
    init(title:String,coord:CLLocationCoordinate2D,desc:String) {
        _title = title
        _coord = coord
        _desc = desc
    }
    
}



