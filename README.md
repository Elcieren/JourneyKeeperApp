<details>
<summary><h2>Uygulama İçeriği</h2></summary>

  <details>
    <summary><h2>Uygulma Amacı</h2></summary>
    Bu uygulama, kullanıcıların harita üzerinde istedikleri konumları kolayca kaydetmelerine ve bu konumlara ait notlar eklemelerine olanak tanımaktadır. Kullanıcılar, harita üzerinde uzun basarak istedikleri lokasyonu seçebilir, bu lokasyonun adı ve açıklamasını girerek kaydedebilirler. Kaydedilen konumlar, uygulamanın içindeki bir liste (TableView) aracılığıyla görüntülenebilir. Kullanıcı, bir konuma tıkladığında, Apple Haritaları uygulamasını açarak o konuma nasıl gidileceğini öğrenebilir. Uygulama, Core Data ile entegrasyonu sayesinde, kaydedilen konumları kalıcı olarak depolayarak kullanıcıların verilerini güvenli bir şekilde saklar. Bu özellikler, kullanıcıların harita üzerinde hızlı ve etkili bir şekilde gezinmelerine yardımcı olur.
  </details> 

  <details>
    <summary><h2>Konum Yöneticisi</h2></summary>
    Kullanıcının mevcut konumunu alabilmek için CLLocationManager kullanılır. Bu sayede kullanıcı haritada yerini görebilir.
    
    ```
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
    super.viewDidLoad()
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.requestWhenInUseAuthorization()
    locationManager.startUpdatingLocation()
    }
    ```
  </details> 

  <details>
    <summary><h2>Kullanıcıdan Konum Seçme</h2></summary>
    Kullanıcı, haritada uzun basarak konum seçebilir. Bu işlem, haritada yeni bir anotasyon eklemeyi sağlar.

    
    ```
    @objc func chooseLocation(gestureRecognizer: UILongPressGestureRecognizer) {
    if gestureRecognizer.state == .began {
        let touchPoint = gestureRecognizer.location(in: self.mapView)
        let touchCoordinate = self.mapView.convert(touchPoint, toCoordinateFrom: self.mapView)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = touchCoordinate
        annotation.title = nameText.text
        annotation.subtitle = commentText.text
        
        self.mapView.addAnnotation(annotation)
        saveButton.isHidden = false
    }
    }
    ```
  </details> 

  <details>
    <summary><h2>Harita Delegesi</h2></summary>
    Haritanın görünümünü ve anotasyonların etkileşimini yönetmek için MKMapViewDelegate protokolü uygulanır. Bu sayede anotasyonlara tıklanıldığında detayları gösterilir.
    
    ```
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    // Kullanıcı konumu için özel bir görünüm döndürmüyoruz
    if annotation is MKUserLocation {
        return nil
    }

    let reuseId = "myAnnotation"
    var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKMarkerAnnotationView

    if pinView == nil {
        pinView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        pinView?.canShowCallout = true
    } else {
        pinView?.annotation = annotation
    }
    return pinView
    }


    ```
  </details> 


  <details>
    <summary><h2>Core Data ile Veriyi Kaydetme</h2></summary>
    Kullanıcının eklediği konum bilgileri, Core Data kullanılarak kalıcı hale getirilir. Bu işlem, uygulama kapatıldığında bile verilerin kaybolmamasını sağlar.
    
    ```
    @IBAction func saveButtonTapped(_ sender: Any) {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let context = appDelegate.persistentContainer.viewContext
    
    let newPlace = NSEntityDescription.insertNewObject(forEntityName: "Konum", into: context)
    newPlace.setValue(UUID(), forKey: "id")
    newPlace.setValue(choosenLatitude, forKey: "latitude")
    newPlace.setValue(choosenLongtitude, forKey: "longtitude")
    newPlace.setValue(commentText.text, forKey: "subtitle")
    newPlace.setValue(nameText.text, forKey: "title")
    
    do {
        try context.save()
    } catch {
        print("Kaydetme işleminde hata verdi")
    }
    }



    ```
  </details> 

  <details>
    <summary><h2>Uygulama Görselleri </h2></summary>
  </details> 



   
</details>
