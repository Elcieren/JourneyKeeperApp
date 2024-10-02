//
//  MapViewController.swift
//  JourneyKeeperApp
//
//  Created by Eren Elçi on 2.10.2024.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class MapViewController: UIViewController , MKMapViewDelegate , CLLocationManagerDelegate{

    @IBOutlet var saveButton: UIButton!
    @IBOutlet var mapView: MKMapView!
    
    @IBOutlet var commentText: UITextField!
    
    @IBOutlet var nameText: UITextField!
    
    var locationManager = CLLocationManager()
    
    var choosenLatitude = Double()
    var choosenLongtitude = Double()
    
    
    var choosedName: String = ""
    var chooseSubtitle: String = ""
    var choosedID : UUID?
    
    
    var ananotionTitle = ""
    var anananotionSubTitle = ""
    var ananotionTitleLatitude = Double()
    var ananotionTitleLongtitude = Double()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        mapView.delegate = self
        locationManager.delegate = self
        
        //kullanıcı lokasyonunu alma
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(chooseLocation(gestureRecognizer:)))
        gestureRecognizer.minimumPressDuration = 3
        mapView.addGestureRecognizer(gestureRecognizer)
        saveButton.isHidden = true
        
        
        
        if choosedName != "" {
            //CoreData çekicez
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Konum")
            let idString = choosedID!.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
            fetchRequest.returnsObjectsAsFaults = false
            
            
            do {
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                        if let latitude = result.value(forKey: "latitude") as? Double {
                            ananotionTitleLatitude = latitude
                            
                            if let longtitude = result.value(forKey: "longtitude") as? Double {
                                ananotionTitleLongtitude = longtitude
                                
                                if let subtitle  = result.value(forKey: "subtitle") as? String {
                                    anananotionSubTitle = subtitle
                                    
                                    if let title = result.value(forKey: "title") as? String {
                                        ananotionTitle = title
                                        
                                        let anonation = MKPointAnnotation()
                                        anonation.title = ananotionTitle
                                        anonation.subtitle = anananotionSubTitle
                                        let cordinate = CLLocationCoordinate2D(latitude: ananotionTitleLatitude, longitude: ananotionTitleLongtitude)
                                        anonation.coordinate = cordinate
                                        self.mapView.addAnnotation(anonation)
                                        nameText.text = ananotionTitle
                                        commentText.text = anananotionSubTitle
                                        
                                        // durdurduk
                                        locationManager.stopUpdatingLocation()
                                        // aldığımız lokasyona ve oluşturduğumuz spanı region veriyor ve mapview yolluyoruz
                                        let span  = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                                        let region = MKCoordinateRegion(center: cordinate, span: span)
                                        mapView.setRegion(region, animated: true)
                                    }
                                }
                            }
                        }
                    }
                }
            } catch {
                print("HATA")
            }
            
            
        } else {
            
        }

    }
    
    @objc func chooseLocation(gestureRecognizer: UILongPressGestureRecognizer ) {
        
        if gestureRecognizer.state == .began {
            
            
            if let text1 = nameText.text, !text1.isEmpty, let text2 = commentText.text, !text2.isEmpty {
                
                let touchPoint = gestureRecognizer.location(in: self.mapView)
                let touchCordinate = self.mapView.convert(touchPoint, toCoordinateFrom: self.mapView)
                choosenLatitude = touchCordinate.latitude
                choosenLongtitude = touchCordinate.longitude
                let annotation = MKPointAnnotation()
                annotation.coordinate = touchCordinate
                annotation.title = text1
                annotation.subtitle = text2
                self.mapView.addAnnotation(annotation)
                
                saveButton.isHidden  = false
                
            } else {
                let ac = UIAlertController(title: "Uyarı", message: "Konum adı veya Açıklaması boş bırakılmaz", preferredStyle: UIAlertController.Style.alert)
                
                let button = UIAlertAction(title: "Tamam", style: UIAlertAction.Style.cancel, handler: nil)
                ac.addAction(button)
                present(ac, animated: true)
            }
            
        }
        
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: any MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
        
        let reuseId = "myAnnotation"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKMarkerAnnotationView
        
        if pinView == nil {
            pinView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = true
            pinView?.tintColor = UIColor.black
            
            let button = UIButton(type: UIButton.ButtonType.detailDisclosure)
            pinView?.rightCalloutAccessoryView = button
        }  else {
            pinView?.annotation = annotation
        }
        
        return pinView
    }
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if choosedName != "" {
            var newrequestLocation = CLLocation(latitude: ananotionTitleLatitude, longitude: ananotionTitleLongtitude)
            
            CLGeocoder().reverseGeocodeLocation(newrequestLocation) { (placemarks , error ) in
                //closure
                if let placemark = placemarks {
                    if placemark.count > 0 {
                        let newPlaceMark = MKPlacemark(placemark: placemark[0])
                        let item = MKMapItem(placemark: newPlaceMark)
                        item.name = self.ananotionTitle
                        let launchOptions = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving]
                        item.openInMaps(launchOptions: launchOptions)
                    }
                }
                
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if choosedName == "" {
            guard let currentLocation = locations.last else { return }

            // bize verilen locations ilk indexi alıyoruz
            let location = CLLocationCoordinate2D(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
            // zoom seviyesini ayarlama
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            // region oluşturcaz
            let region = MKCoordinateRegion(center: location, span: span)
            // oluşturduğumuz kordinat ve zoom regina verdik bu region mapview iletiyoruz
            mapView.setRegion(region, animated: true)
            
            locationManager.stopUpdatingLocation()
        }
    }
        
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        
        let appDelegete = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegete.persistentContainer.viewContext
        
        let newPlace = NSEntityDescription.insertNewObject(forEntityName: "Konum", into: context)
        
        newPlace.setValue(UUID(), forKey: "id")
        newPlace.setValue(choosenLatitude, forKey: "latitude")
        newPlace.setValue(choosenLongtitude, forKey: "longtitude")
        newPlace.setValue(commentText.text, forKey: "subtitle")
        newPlace.setValue(nameText.text, forKey: "title")
        
        do{
            try context.save()
            print("Kaydetme işlemi başarılı")
        } catch {
            print("Kaydetme işleminde hata verdi")
        }
        
        
        NotificationCenter.default.post(name: NSNotification.Name("newPlace") , object: nil)
        navigationController?.popViewController(animated: true)
        
    }
    

}
