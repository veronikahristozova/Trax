//
//  ViewController.swift
//  Trax
//
//  Created by Veronika Hristozova on 10/11/16.
//  Copyright © 2016 Veronika Hristozova. All rights reserved.
//

import UIKit
import MapKit
import GooglePlaces

class GPXViewController: UIViewController, MKMapViewDelegate {
    
    
    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            mapView.mapType = .satellite
            mapView.delegate = self
        }
    }
    var gpxURL: URL? {
        didSet {
            clearWaypoints()
            if let url = gpxURL {
                GPX.parse(url: url as NSURL) { gpx in
                    if gpx != nil {
                        self.addWaypoints(waypoints: gpx!.waypoints)
                    }
                }
            }
        }
    }
    //let searchController = UISearchController(searchResultsController: nil)
    
    private func clearWaypoints() {
        mapView?.removeAnnotation(mapView.annotations as! MKAnnotation)
    }
    
    private func addWaypoints(waypoints: [GPX.Waypoint]) {
        mapView?.addAnnotations(waypoints)
        mapView?.showAnnotations(waypoints, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //gpxURL = URL(string: "http://cs193p.stanford.edu/Vacations.gpx")
        
        addWaypoints(waypoints: [
            GPX.Waypoint(latitude: 42.650826, longitude: 23.341334),
            GPX.Waypoint(latitude: 42.651192, longitude: 23.342702),
            GPX.Waypoint(latitude: 42.651926, longitude: 23.341543)
            ])
        
        //searchController.searchResultsUpdater = self
        //definesPresentationContext = true
        // smth.smth = searchController.searchBar
        
    }
    
    // TODO:
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var view: MKAnnotationView! = mapView.dequeueReusableAnnotationView(withIdentifier: "waypoint")
        if view == nil {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "")
            view.canShowCallout = true
        } else {
            view.annotation = annotation
        }
        view.isDraggable = true
        view.rightCalloutAccessoryView = nil
        if let waypoint = annotation as? GPX.Waypoint {
            if waypoint is EditableWaypoint {
                view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            }
        }
        return view
    }
    
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            mapView.deselectAnnotation(view.annotation, animated: true)
            performSegue(withIdentifier: "Edit Waypoint", sender: view)
        }
    }
    
    @IBAction func addWaypoint(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            let coordinate = mapView.convert(sender.location(in: mapView), toCoordinateFrom: mapView)
            let waypoint = EditableWaypoint(latitude: coordinate.latitude, longitude: coordinate.longitude)
            waypoint.name = "Dropped"
            mapView.addAnnotation(waypoint)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination.contentViewController
        let annotationView = sender as? MKAnnotationView
        let waypoint = annotationView?.annotation as? GPX.Waypoint
        if segue.identifier == "Edit Waypoint" {
            if let editableWaypoint = waypoint as? EditableWaypoint,
                let ewvc = destination as? EditWaypointViewController {
                ewvc.wayPointToEdit = editableWaypoint
            }
        }
    }
    
    @IBAction func updatedUserWaypoint(segue: UIStoryboardSegue) {
        selectWaypoint(waypoint: (segue.source.contentViewController as? EditWaypointViewController)?.wayPointToEdit)
    }
    
    private func selectWaypoint(waypoint: GPX.Waypoint?) {
        if waypoint != nil {
            mapView.selectAnnotation(waypoint!, animated: true)
        }
    }
}

extension GPX.Waypoint : MKAnnotation {
    var coordinate: CLLocationCoordinate2D { return CLLocationCoordinate2D(latitude: latitude, longitude: longitude) }
    var title: String? { return name }
    var subtitle: String? { return info }
    var thumbnailURL: URL? { return getImageURLofType(type: "thumbnail") }
    var imageURL: URL? {return getImageURLofType(type: "large") }
    
    private func getImageURLofType(type: String?) -> URL? {
        for link in links {
            if link.type == type {
                return link.url as URL?
            }
        }
        return nil
    }
}

extension UIViewController {
    var contentViewController: UIViewController {
        if let navcon = self as? UINavigationController {
            return navcon.visibleViewController ?? navcon
        } else {
            return self
        }
    }
}

class EditableWaypoint: GPX.Waypoint {
    override var coordinate: CLLocationCoordinate2D {
        get {
            return super.coordinate
        }
        set {
            latitude = newValue.latitude
            longitude = newValue.longitude
        }
    }
}
