//
//  RouteViewController.swift
//  RouteTestTask
//
//  Created by Bakhtiyarov Fozilkhon on 19.06.2023.
//

import UIKit
import SnapKit
import MapKit
import CoreLocation

class RouteViewController: UIViewController {
    
    private lazy var mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        
        return mapView
    }()
    
    var annotationsArray = [MKPointAnnotation]()
    
    private lazy var addAddressButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let origImage = UIImage(named: "location")
        button.setImage(origImage, for: .normal)
        button.widthAnchor.constraint(equalToConstant: 60).isActive = true
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        return button
    }()
    
    private lazy var routeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "route"), for: .normal)
        button.isHidden = true
        button.setTitleColor(UIColor.orange, for: .normal)
        button.widthAnchor.constraint(equalToConstant: 75).isActive = true
        button.heightAnchor.constraint(equalToConstant: 75).isActive = true
        
        return button
    }()
    
    private lazy var resetButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let origImage = UIImage(named: "circle")
        button.setImage(origImage, for: .normal)
        button.isHidden = true
        button.widthAnchor.constraint(equalToConstant: 55).isActive = true
        button.heightAnchor.constraint(equalToConstant: 55).isActive = true
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        addAllSubViews()
        setConstraints()
        addTargets()
    }
}

extension RouteViewController {
    
    private func addAllSubViews() {
        view.addSubview(mapView)
        mapView.addSubview(addAddressButton)
        mapView.addSubview(routeButton)
        mapView.addSubview(resetButton)
    }
    
    private func addTargets() {
        addAddressButton.addTarget(self, action: #selector(addAddressFunction), for: .touchUpInside)
        routeButton.addTarget(self, action: #selector(routeFunction), for: .touchUpInside)
        resetButton.addTarget(self, action: #selector(resetFunction), for: .touchUpInside)
    }
    
    @objc private func addAddressFunction() {
        presentAlert(title: "Route", placeholder: "Enter place") { text in
            self.setupPlacemark(addressPlace: text)
        }
    }
    
    @objc private func routeFunction() {
        
        for index in 0...annotationsArray.count - 2 {
            createDirectionRequest(startCoordinate: annotationsArray[index].coordinate, destinationCoordinate: annotationsArray[index + 1].coordinate)
        }
        
        mapView.showAnnotations(annotationsArray, animated: true)
    }
    
    @objc private func resetFunction() {
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)
        annotationsArray = [MKPointAnnotation]()
        routeButton.isHidden = true
        resetButton.isHidden = true
    }
    
    private func setConstraints() {
        mapView.snp.makeConstraints { make in
            make.top.bottom.left.right.equalToSuperview()
        }
        
        addAddressButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(35)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        routeButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-30)
            make.leading.equalToSuperview().offset(20)
        }
        
        resetButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-30)
            make.trailing.equalToSuperview().offset(-20)
        }
    }
    
    private func setupPlacemark(addressPlace: String) {
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(addressPlace) { [self] placemarks, error in
            if let error = error {
                print(error.localizedDescription)
                alertError(title: "Error", message: "Server")
                return
            }
            
            guard let placemarks = placemarks else { return }
            let placemark = placemarks.first
            
            let annotation = MKPointAnnotation()
            annotation.title = "\(addressPlace)"
            guard let coordination = placemark?.location else { return }
            annotation.coordinate = coordination.coordinate
            
            annotationsArray.append(annotation)
            
            if annotationsArray.count > 2 {
                routeButton.isHidden = false
                resetButton.isHidden = false
            }
            
            mapView.showAnnotations(annotationsArray, animated: true)
        }
    }
    
    private func createDirectionRequest(startCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D) {
        
        let startLocation = MKPlacemark (coordinate: startCoordinate)
        let destinationLocation = MKPlacemark (coordinate: destinationCoordinate)
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startLocation)
        request.destination = MKMapItem(placemark: destinationLocation)
        request.transportType = .walking
        request.requestsAlternateRoutes = true
        
        let direction = MKDirections(request: request)
        
        direction.calculate { response, error in
            
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let response = response else {
                self.alertError(title: "Error", message: "Server")
                return
            }
            
            var minRoute = response.routes[0]
            
            for route in response.routes {
                minRoute = route.distance < minRoute.distance ? route : minRoute
            }
            
            self.mapView.addOverlay(minRoute.polyline)
        }
    }
}

extension RouteViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .red
        return renderer
    }
}
