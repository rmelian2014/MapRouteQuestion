//
//  ViewController.swift
//  mapRoute
//
//  Created by AJ on 3/14/18.
//  Copyright © 2018 AJ. All rights reserved.
//

import UIKit

import MapKit
import CoreLocation
import Alamofire

class GasViewControoler: BaseViewController {
    
    
    @IBOutlet weak var mapview: MKMapView!
    //locationManager
    private var locationManager:CLLocationManager!
    //save last location for limit the Google places api request
    private var lastLocation:CLLocation?
    //save reference of current pins
    private var pins = [MKPointAnnotation]()
	
	//MARK: Route Overlay
	internal var currentRouteOverlay : MKOverlay?
	
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.topItem?.title = " "

        locationManager = CLLocationManager()
        locationManager.delegate = self
        
        //set my location accurcy to best
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        //start the location service
        locationManager.startUpdatingLocation()
        
        //show my location
        mapview.showsUserLocation = true
        
        mapview.delegate = self
    }
    
    

    //Remove all last pins if there and setup new pins
    func setUpPins(locations:[Location])
    {
        for pin in pins{
            mapview.removeAnnotation(pin)
        }
        
        pins.removeAll()
        
        for loction in locations
        {
            let annotaion = MKPointAnnotation()
            annotaion.coordinate = loction.coord
            annotaion.title = loction.title
            annotaion.subtitle = loction.desc
            
            mapview.addAnnotation(annotaion)
            pins.append(annotaion)
        }
        
    }
    
    
    //Find the nearest Food from this location via google places javascript api
    // You can find other things by typing the following...
    // https://developers.google.com/places/supported_types
    func findNearestMos(coord:CLLocationCoordinate2D)
    {
        let url = getUrlForGas_station(coord: coord)        //get the google places javascript url for the location
        var locations = [Location]()
        request(url).responseJSON { (response) in
            
            if let dict = response.result.value as? Dictionary<String,AnyObject>{
                //print(dict["results"])
                if let results = dict["results"] as? [Dictionary<String,AnyObject>]
                {
                    for result in results
                    {
                        if let geometry = result["geometry"] as? Dictionary<String,AnyObject>,let name = result["name"] as? String,let descr = result["vicinity"] as? String
                        {
                            if let coord = geometry["location"] as? Dictionary<String,CGFloat>
                            {
                                locations.append(Location(title: name,coord: CLLocationCoordinate2D(latitude: CLLocationDegrees(CGFloat(coord["lat"]!)),longitude: CLLocationDegrees(CGFloat(coord["lng"]!))), desc: descr))
                            }
                        }
                    }
                }
                self.setUpPins(locations: locations)
            }
        }
    }
	
	func createRouteTo(fromMapItem: MKMapItem,selectedMapItem: MKMapItem) {
		
		if(CLLocationCoordinate2DIsValid(self.mapview.userLocation.coordinate) && CLLocationCoordinate2DIsValid(selectedMapItem.placemark.coordinate))
		{
			self.showLoading(message: "Creando Ruta...")
			let directionRequest = MKDirectionsRequest()
			directionRequest.source = MKMapItem(placemark: MKPlacemark(coordinate: fromMapItem.placemark.coordinate, addressDictionary: nil))
			directionRequest.destination = MKMapItem(placemark: MKPlacemark(coordinate: selectedMapItem.placemark.coordinate, addressDictionary: nil))
			directionRequest.transportType = .automobile
			directionRequest.requestsAlternateRoutes = false
			
			// Calculate the direction
			let directions = MKDirections(request: directionRequest)
			
			directions.calculate { [unowned self] (directionResponse, error) in
				self.hideLoading(withDelay: 0.1)
				guard let response = directionResponse else {
					if let error = error {
						print("Error: \(error)")
						let alert = UIAlertController.init(title:"Error Creando Ruta",
														   message:error.localizedDescription, preferredStyle: .alert)
						alert.addAction(UIAlertAction.init(title: "Aceptar", style: .destructive, handler:nil))
						self.present(alert, animated:true , completion:nil)
					}
					
					return
				}
				
				if(self.currentRouteOverlay != nil)
				{
					self.mapview.remove(self.currentRouteOverlay!)
				}
				
				let route = response.routes[0]
				self.currentRouteOverlay = route.polyline
				self.mapview.add(route.polyline, level: .aboveRoads)
				
				let rect =  route.polyline.boundingMapRect
				self.mapview.setVisibleMapRect(rect, edgePadding: UIEdgeInsetsMake(15, 15, 15, 15), animated: true)
			}
		}
		
	}
}

extension GasViewControoler : CLLocationManagerDelegate {
	//This will call when user location changed
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		if locations.count==0
		{
			return
		}
		if let last = lastLocation
			//if last location is there then calculate the distance from last position to new postion if value is greater than certain then update the nearest libraries
		{
			print(CGFloat(last.distance(from: locations[0])))
			
			if CGFloat(last.distance(from: locations[0])) > UPDATE_RESTURANT_RATE          //calculate distance
			{
				lastLocation = locations[0]
				setupForCurrentLocation(location: (locations[0]))                       //set up the camera ,pins
			}
			
		}
		else{
			setupForCurrentLocation(location: (locations[0]))
			lastLocation = locations[0]
		}
		
		
		
	}
	
	
	//Set the coordinates to the location and update the pins
	func setupForCurrentLocation(location:CLLocation)
	{
		
		let region = MKCoordinateRegionMake(location.coordinate, MKCoordinateSpanMake(MAP_ZOOM_LEVEL, MAP_ZOOM_LEVEL))
		mapview.setRegion(region, animated: true)
		
		findNearestMos(coord: (location.coordinate))
		// find the nearest mosque from google places javascript api request
	}
}

extension GasViewControoler : MKMapViewDelegate {
	
	func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
		let renderer = MKPolylineRenderer(overlay: overlay)
		renderer.strokeColor = UIColor.red
		renderer.lineWidth = 4.0
		
		return renderer
	}
	
	// this method shows the pin and details view in AccessoryView
	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		
		if annotation is MKUserLocation {
			return nil
		}
		
		let reuseId = "pin"
		
		var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
		if pinView == nil {
			pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
			pinView!.canShowCallout = true
			pinView!.pinTintColor  = .purple
			
			//next line sets a button for the right side of the callout...
			
			pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure) as UIView
		}
		else {
			pinView!.annotation = annotation
		}
		
		return pinView
	}
	
	// This method will be called when we will tap on the annotation for Details.Then it will open in new View and make a route from current location to selected location.
	func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
				 calloutAccessoryControlTapped control: UIControl) {
		
		let selectedLoc = view.annotation
		
		print("Annotation '\(String(describing: selectedLoc?.title!))' has been selected")
		
		let currentLocMapItem = MKMapItem(placemark: MKPlacemark(coordinate: mapView.userLocation.coordinate))
		
		let selectedPlacemark = MKPlacemark(coordinate: (selectedLoc?.coordinate)!, addressDictionary: nil)
		let selectedMapItem = MKMapItem(placemark: selectedPlacemark)
	
		self.createRouteTo(fromMapItem:currentLocMapItem, selectedMapItem: selectedMapItem)
	}
	
}
