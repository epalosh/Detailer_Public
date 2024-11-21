/* 

Code by Ethan Palosh for the iOS App "Detailer"

DatabaseAccessExample_01 - Firebase Firestore

This file contains some sample high-level database access functions. They are implemented in the app code.

    - This class specifically accesses data in the Firebase Firestore database.

Published for portfolio purposes only.

*/

class FirestoreService {
    static let shared = FirestoreService()
    
    private init() {}
    
    let db = Firestore.firestore()
    
    // function to save user data to the database. Used when creating a new account.
    func saveUserData(userId: String, data: [String: Any], completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection("user-data").document(userId).setData(data) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    // function to save the user's email to the usersByEmail dictionary in the database
    func saveUserWithEmailAsID(email: String, uid: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let data = ["email": email, "uid": uid]
        db.collection("usersByEmail").document(email).setData(data) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    // function to retrive user-data on the current user. Used in fetchUserData, which is called at launch
    func getUserData(userId: String, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        db.collection("user-data").document(userId).getDocument { document, error in
            if let document = document, document.exists {
                if let data = document.data() {
                    completion(.success(data))
                } else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data found"])))
                }
            } else {
                completion(.failure(error ?? NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Document does not exist"])))
            }
        }
    }
    
    // database call to update the user's data from the settings menu UI
    func updateUserData(userId: String, data: [String: Any], completion: @escaping (Result<Void, Error>) -> Void) {
        let userRef = db.collection("user-data").document(userId)
        
        // Update the document with the new data
        userRef.updateData(data) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    // Function to delete user data from Firestore
    func deleteUserData(userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let db = Firestore.firestore()
        
        // Reference to the user's document in "user-data" collection
        let userDocRef = db.collection("user-data").document(userId)
        
        // Delete all messages in the "messages" subcollection
        userDocRef.collection("messages").getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            let batch = db.batch()
            for document in querySnapshot?.documents ?? [] {
                batch.deleteDocument(document.reference)
            }
            
            batch.commit { error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                // Delete the user document itself
                userDocRef.delete { error in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    
                    // Delete from "emailToUID" collection
                    db.collection("emailToUID").whereField("uid", isEqualTo: userId).getDocuments { querySnapshot, error in
                        if let error = error {
                            completion(.failure(error))
                            return
                        }
                        
                        let batch = db.batch()
                        for document in querySnapshot?.documents ?? [] {
                            batch.deleteDocument(document.reference)
                        }
                        
                        batch.commit { error in
                            if let error = error {
                                completion(.failure(error))
                                return
                            }
                            
                            // Now delete from "usersByEmail" collection
                            db.collection("usersByEmail").whereField("uid", isEqualTo: userId).getDocuments { querySnapshot, error in
                                if let error = error {
                                    completion(.failure(error))
                                    return
                                }
                                
                                let batch = db.batch()
                                for document in querySnapshot?.documents ?? [] {
                                    batch.deleteDocument(document.reference)
                                }
                                
                                batch.commit { error in
                                    if let error = error {
                                        completion(.failure(error))
                                    } else {
                                        completion(.success(()))
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func getAPIKey(completion: @escaping (String?, Error?) -> Void) {
        let db = Firestore.firestore()
        let docRef = db.collection("config").document("apiKey")
        
        docRef.getDocument { document, error in
            if let error = error {
                print("Error getting document: \(error)")
                completion(nil, error)
            } else if let document = document, document.exists {
                if let apiKey = document.data()?["key"] as? String {
                    completion(apiKey, nil)
                } else {
                    completion(nil, NSError(domain: "AppErrorDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: "API key not found"]))
                }
            } else {
                completion(nil, NSError(domain: "AppErrorDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: "Document not found"]))
            }
        }
    }
} // End FireStoreService

