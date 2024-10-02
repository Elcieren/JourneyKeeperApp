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

  



   
</details>

<details>
    <summary><h2>Uygulama Görselleri </h2></summary>
    
    
 <table style="width: 100%;">
    <tr>
        <td style="text-align: center; width: 16.67%;">
            <h4 style="font-size: 14px;">Konumların Listelenmesi</h4>
            <img src="https://github.com/user-attachments/assets/3705b73b-1e48-4200-8dd7-bb7832483cc5" style="width: 100%; height: auto;">
        </td>
        <td style="text-align: center; width: 16.67%;">
            <h4 style="font-size: 14px;">İşaretlenen Konum Detaylı Gösterim</h4>
            <img src="https://github.com/user-attachments/assets/c56bcc2b-45a5-43f8-bd82-e8968828c1bc" style="width: 100%; height: auto;">
        </td>
        <td style="text-align: center; width: 16.67%;">
            <h4 style="font-size: 14px;">Kaydedilen Konum Gösterimi</h4>
            <img src="https://github.com/user-attachments/assets/7a474c52-eb5c-4043-bf36-bbae8c03d565" style="width: 100%; height: auto;">
        </td>
        <td style="text-align: center; width: 16.67%;">
            <h4 style="font-size: 14px;">Uyarı Mesajı</h4>
            <img src="https://github.com/user-attachments/assets/c911d5db-32ab-4eee-9815-d1140a7be7be" style="width: 100%; height: auto;">
        </td>
        <td style="text-align: center; width: 16.67%;">
            <h4 style="font-size: 14px;">Kaydedilen Konumu Silme</h4>
            <img src="https://github.com/user-attachments/assets/099300c1-39c4-49c8-bcb5-a23b37b16509" style="width: 100%; height: auto;">
        </td>
        <td style="text-align: center; width: 16.67%;">
            <h4 style="font-size: 14px;">Konuma Detayına Tıklandığı Harita Hesaplaması</h4>
            <img src="https://github.com/user-attachments/assets/225bd0c9-7d89-485c-a94f-6f0246276c6a" style="width: 100%; height: auto;">
        </td>
    </tr>
</table>




  
  </details> 
