
import UIKit
import CoreLocation

class ARPOIStore {
    
    static fileprivate var _pois: Set<ARGooglePlace>?
    fileprivate var networkSession: ARNetworkSession?
    var poiSet = Set<String>()
    static var mapsVC: MapsVC?
    
    init(networkSession: ARNetworkSession? = ARNetworkSession.shared) {
        self.networkSession = networkSession
    }
    
    func fetchPOIs(lat: CLLocationDegrees, lng: CLLocationDegrees, radius: Int, forceRefresh: Bool = false, completion: @escaping ([ARGooglePlace]?) -> Void) {
        if forceRefresh == false, let pois = ARPOIStore._pois {
            completion(Array(pois))
            return
        }
        ARPOIStore._pois = Set<ARGooglePlace>()
        
        for type in ARGooglePlaceType.allValues {
            refreshPOI(lat: lat, lng: lng,radius: radius,type: type) { success in
                if success {
                    if let pois = ARPOIStore._pois {
                        completion(Array(pois))
                    } else {
                        completion(nil)
                    }
                }
            }
        }
    }
    
    func searchWithKeyword(_ keyword: String, lat: CLLocationDegrees, lng: CLLocationDegrees, radius: Int, rankBy: ARGooglePlaceRank?, openNow: Bool?, minPrice: Int?, maxPrice: Int?, forceRefresh: Bool, completion: @escaping ([ARGooglePlace]?) -> Void) {
        if forceRefresh == false, let pois = ARPOIStore._pois {
            completion(Array(pois))
            return
        }
        
        ARPOIStore._pois = Set<ARGooglePlace>()
        
        ARPOIStore.getNearPOIsList(networkSession: networkSession, lat: lat, lng: lng, radius: radius, keyword: keyword, rankBy: rankBy, openNow: openNow, minPrice: minPrice, maxPrice: maxPrice) { places, nextPageToken, error in
            if let error = error {
                print("Error searching POIs: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            ARPOIStore._pois?.formUnion(places)
            if let pois = ARPOIStore._pois {
                completion(Array(pois))
            } else {
                completion(nil)
            }
        }
        
    }
    
    fileprivate func refreshPOI(lat: CLLocationDegrees, lng: CLLocationDegrees, radius: Int, type: ARGooglePlaceType, completion: @escaping (_ success: Bool) -> Void) {
        
        ARPOIStore.getNearPOIsList(networkSession: networkSession, lat: lat, lng: lng, radius: radius, type: type) { pois, nextPageToken, error in
            if let error = error {
                print("Error loading pois from google: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            ARPOIStore._pois?.formUnion(pois)
            completion(true)
        }
    }
    
}

extension ARPOIStore {
    
    static func getNearPOIsList(networkSession: ARNetworkSession?,
        lat: CLLocationDegrees?, lng: CLLocationDegrees?, radius: Int? = nil,
        type: ARGooglePlaceType? = nil, keyword: String? = nil, rankBy: ARGooglePlaceRank? = nil,
        openNow: Bool? = nil, minPrice: Int? = nil, maxPrice: Int? = nil,
        callback: (([ARGooglePlace], String?, NSError?) -> Void)?) {
        
        let request = ARGooglePlaceRequest(lat: lat, lng: lng, radius: radius, type: type, keyword: keyword, rankBy: rankBy, openNow: openNow, minPrice: minPrice, maxPrice: maxPrice)
        
        let _ = networkSession?.send(request) { result in
            switch result {
            case .success(let results):
                callback?(results.places, results.nextPageToken, nil)
            case .failure(let error):
                callback?([], nil, error as NSError)
            }
        }
    }
    
    static func getNextPOIListPage(networkSession: ARNetworkSession?,
        nextPageToken: String, callback: (([ARGooglePlace], String?, NSError?) -> Void)?) {
        let request = ARGooglePlaceRequest(nextPageToken: nextPageToken)
        let _ = networkSession?.send(request) { result in
            switch result {
            case .success(let results):
                callback?(results.places, results.nextPageToken, nil)
            case .failure(let error):
                callback?([], nil, error as NSError)
            }
        }
    }
    
    static func getArrowPOIData()
    {
        for place in ARPOIStore._pois!
        {
            // if we've got nothing for litMeter, it means we haven't gotten Arrow Data yet and if it's true, we need the latest data
            if(place.litMeterEnabled == nil || place.litMeterEnabled == true)
            {
                let request = GetPlaceRequest(platform: ARPlatform.shared, placeId: place.placeId)
                let _ = ARNetworkSession.shared.send(request) { result in
                    switch result {
                    case .success(let placeUpdated):
                        UpdatePOI(argpOLD: place, argpNEW: placeUpdated)
                    case .failure(let error):
                        print("getArrowPOIData ERROR: \(error)")
                    }
                }
            }
        }
    }
    
    fileprivate static func UpdatePOI(argpOLD: ARGooglePlace, argpNEW: ARGooglePlace)
    {
        ARPOIStore._pois!.remove(argpOLD)
        ARPOIStore._pois!.insert(argpNEW)
        
        ARPOIStore.mapsVC?.updateLitMeter(place: argpNEW)
    }
}
