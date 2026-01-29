//
//  LocationManager.swift
//  baseapp-ios-core-v1
//
//  Created by Pat Sluth on 2018-01-24.
//  Copyright © 2018 SilverLogic. All rights reserved.
//

import CoreLocation
import Foundation
import PromiseKit
import RxCocoa
import RxSwift
import RxSwiftExt

public enum LocationManagerErrors: Error {
    case unauthorized
}

/// A singleton that provides access the the device location.
public final class LocationManager: NSObject {
    public static let shared = LocationManager()
    
    let coreLocationManager: CLLocationManager
    
    private let _authorizationStatus: BehaviorRelay<CLAuthorizationStatus>
    public var onAuthorizationStatus: Observable<CLAuthorizationStatus> {
        return _authorizationStatus
            .asObservable()
            .distinct()
    }
    
    private let _currentLocation = BehaviorRelay<CLLocation?>(value: nil)
    public var currentLocation: CLLocation? {
        return _currentLocation.value
    }
    public var onCurrentLocation: Observable<CLLocation> {
        return _currentLocation
            .asObservable()
            .startWith(currentLocation)
            .unwrap()
    }
    private let _currentHeading = BehaviorRelay<CLHeading?>(value: nil)
    public var currentHeading: CLHeading? {
        return _currentHeading.value
    }
    public var onCurrentHeading: Observable<CLHeading> {
        return _currentHeading
            .asObservable()
            .startWith(currentHeading)
            .unwrap()
    }
    public var onUpdate: Observable<(CLLocation, CLHeading)> {
        return Observable.combineLatest(onCurrentLocation, onCurrentHeading)
    }
    private let _currentError = BehaviorRelay<Error?>(value: nil)
    public var onError: Observable<Error> {
        return _currentError
            .asObservable()
            .unwrap()
    }
    
    private override init() {
        
        coreLocationManager = CLLocationManager.make({
            $0.pausesLocationUpdatesAutomatically = false
            $0.distanceFilter = kCLDistanceFilterNone
            $0.headingFilter = kCLHeadingFilterNone
            $0.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        })
        _authorizationStatus = BehaviorRelay<CLAuthorizationStatus>(
            value: CLLocationManager.authorizationStatus()
        )
        
        super.init()
        
        defer {
            coreLocationManager.delegate = self
            locationManager(coreLocationManager,
                            didChangeAuthorization: CLLocationManager.authorizationStatus())
        }
    }
    
    public func requestLocation() -> Promise<CLLocation> {
        defer {
            _currentError.accept(nil)
            coreLocationManager.requestLocation()
        }
        return onCurrentLocation.or(LocationManager.shared.onError)
            .asPromise()
            .map({ locationResult -> CLLocation in
                switch locationResult {
                case .A(let location):
                    return location
                case .B(let error):
                    throw error
                }
            })
    }
    
    public func start() {
        coreLocationManager.startUpdatingLocation()
        coreLocationManager.startUpdatingHeading()
    }
    
    public func stop() {
        coreLocationManager.stopUpdatingLocation()
        coreLocationManager.stopUpdatingHeading()
    }
}


// MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager,
                                didChangeAuthorization status: CLAuthorizationStatus) {
        _authorizationStatus.accept(status)
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            start()
        case .notDetermined, .restricted:
            coreLocationManager.requestWhenInUseAuthorization()
        case .denied:
            locationManager(coreLocationManager, didFailWithError: LocationManagerErrors.unauthorized)
        @unknown default:
            coreLocationManager.requestWhenInUseAuthorization()
        //            locationManager(coreLocationManager, didFailWithError: LocationManagerErrors.unauthorized)
        }
    }
    
    public func locationManager(_ manager: CLLocationManager,
                                didUpdateLocations locations: [CLLocation]) {
        _currentLocation.accept(manager.location)
    }
    
    public func locationManager(_ manager: CLLocationManager,
                                didUpdateHeading newHeading: CLHeading) {
        _currentHeading.accept(newHeading)
    }
    
    public func locationManager(_ manager: CLLocationManager,
                                didFailWithError error: Error) {
        _currentError.accept(error)
    }
}
