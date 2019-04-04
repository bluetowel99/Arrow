
import Contacts
import UIKit

class ARContactStore {
    
    typealias PhoneNumber = (label: String?, number: String)
    typealias LocalContactInfo = (person: ARPerson, phoneNumbers: [PhoneNumber])
    
    let contactStore = CNContactStore()
    let contactKeysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactEmailAddressesKey, CNContactImageDataKey, CNContactPhoneNumbersKey]
    
    fileprivate var _localContacts: [LocalContactInfo]?
    fileprivate var _arrowContacts: [ARPerson]?
    
}

// MARK: - Public Local Contacts

extension ARContactStore {
    
    func fetchLocalContacts(forceRefresh: Bool = false, completion: @escaping ([LocalContactInfo]?) -> Void) {
        if forceRefresh == false, let contacts = _localContacts {
            completion(contacts)
            return
        }
        
        DispatchQueue.global().async {
            self.refreshLocalContacts { _ in
                DispatchQueue.main.async {
                    completion(self._localContacts)
                }
            }
        }
        
    }
    
    func checkContactsAccess(requestAccessIfNeeded: Bool, completion: @escaping (_ accessGranted: Bool) -> Void) {
        let authorizationStatus = CNContactStore.authorizationStatus(for: .contacts)
        switch authorizationStatus {
        case .authorized:
            completion(true)
        case .denied, .notDetermined, .restricted:
            if requestAccessIfNeeded == false {
                completion(false)
                return
            }
            
            DispatchQueue.global().async {
                self.contactStore.requestAccess(for: .contacts) { access, error in
                    if let error = error {
                        print("Error requesting contacts access: \(error.localizedDescription)")
                    }
                    DispatchQueue.main.async {
                        completion(access)
                    }
                }
            }
            
        }
    }
    
}

// MARK: - Public Arrow Contacts

extension ARContactStore {
    
    func fetchArrowContacts(forceRefresh: Bool = false, platform: ARPlatform, networkSession: ARNetworkSession?, completion: @escaping ([ARPerson]?) -> Void) {
        if forceRefresh == false, let contacts = _arrowContacts {
            completion(contacts)
            return
        }
        
        ARContactStore.getAllMyContacts(platform: platform, networkSession: networkSession) { contacts, error in
            if let error = error {
                print("Failed loading Arrow contacts: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            self._arrowContacts = contacts
            completion(contacts)
        }
    }
}

// MARK: - Local Contacts Helpers

extension ARContactStore {
    
    fileprivate func refreshLocalContacts(completion: @escaping (_ success: Bool) -> Void) {
        // Reset cached variable.
        _localContacts = nil
        
        checkContactsAccess(requestAccessIfNeeded: true) { accessGranted in
            if accessGranted == true {
                self.fetchContacts { contacts in
                    if let contacts = contacts {
                        self._localContacts = self.parse(contacts: contacts)
                    }
                    completion(true)
                }
            } else {
                print("Do not have access to user's contacts.")
                completion(false)
            }
        }
    }
    
    fileprivate func fetchContacts(completion: @escaping ([CNContact]?) -> Void) {
        do {
            let fetchRequest = CNContactFetchRequest(keysToFetch: contactKeysToFetch as [CNKeyDescriptor])
            fetchRequest.predicate = nil
            var fetchedContacts = [CNContact]()
            try contactStore.enumerateContacts(with: fetchRequest) { contact, _ in
                fetchedContacts.append(contact)
            }
            completion(fetchedContacts)
        } catch let error {
            print("Error fetching contacts: \(error.localizedDescription)")
            completion(nil)
        }
    }
    
    fileprivate func parse(contact: CNContact) -> LocalContactInfo {
        var person = ARPerson(identifier: contact.identifier, firstName: contact.givenName, lastName: contact.familyName, email: nil, phone: nil, pictureUrl: nil)
        
        let phoneNumbers = contact.phoneNumbers.map {
            PhoneNumber(
                label: CNLabeledValue<CNPhoneNumber>.localizedString(forLabel: $0.label ?? "").capitalized(with: Locale.current),
                number: $0.value.stringValue
            )
        }
        
        if let imageData = contact.imageData {
            person.thumbnail = UIImage(data: imageData)
        }
        
        return (person, phoneNumbers)
    }
    
    fileprivate func parse(contacts: [CNContact]) -> [LocalContactInfo] {
        return contacts.map { self.parse(contact: $0) }
    }
    
}

// MARK: - Networking

extension ARContactStore {
    
    static func getAllMyContacts(platform: ARPlatform, networkSession: ARNetworkSession?, callback: (([ARPerson]?, NSError?) -> Void)?) {
        let request = GetMyContactsRequest(platform: platform)
        let _ = networkSession?.send(request) { result in
            switch result {
            case .success(let list):
                callback?(list, nil)
            case .failure(let error):
                callback?(nil, error as NSError)
            }
        }
    }
    
}
