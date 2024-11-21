/* 

Code by Ethan Palosh for the iOS App "Detailer"

DatabaseAccessExample_02 - User authorization & account management

This file contains some sample high-level database access functions. They are implemented in the app code.

    - This class specifically handles authorization in the app. Signing users in/out, and handling user data.

Published for portfolio purposes only.

*/

import Foundation
import FirebaseAuth
import FirebaseFirestore

class AuthService {
    static let shared = AuthService()
    
    private init() {}
    
    // function to sign in from user input
    func signIn(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(.failure(error))
            } else if let user = authResult?.user {
                ConnectionViewModel.shared.reset()
                completion(.success(user))
            }
        }
    }
    
    // function to create a new user based on user input
    func signUp(email: String, password: String, firstName: String, lastName: String, schoolName: String?, phoneNumber: String, birthday: Date?, userType: String?, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(.failure(error))
            } else if let user = authResult?.user {
                // Construct user data to save to Firestore
                
                var userData: [String: Any]
                
                if let birthday = birthday {
                    userData = [
                        "email": email,
                        "uid": user.uid,
                        "firstName": firstName,
                        "lastName": lastName,
                        "phoneNumber": phoneNumber,
                        "birthday": birthday
                    ]
                }
                else {
                    userData = [
                        "email": email,
                        "uid": user.uid,
                        "firstName": firstName,
                        "lastName": lastName,
                        "phoneNumber": phoneNumber
                    ]
                }
                
                if let schoolName = schoolName {
                    userData["schoolName"] = schoolName
                }
                
                if let userType = userType {
                    userData["userType"] = userType
                }
                
                // Save user data to Firestore
                FirestoreService.shared.saveUserData(userId: user.uid, data: userData) { result in
                    switch result {
                    case .success:
                        // Optionally save additional user details to other collections if needed
                        FirestoreService.shared.saveUserWithEmailAsID(email: email, uid: user.uid) { result in
                            switch result {
                            case .success:
                                completion(.success(user))
                            case .failure(let error):
                                completion(.failure(error))
                            }
                        }
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            }
        }
    }
    
    
    // function to sign the current user out
    func signOut(completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try Auth.auth().signOut()
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
    
    // Function to delete the current user account
    func deleteAccount(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user is signed in."])))
            return
        }
        
        let userId = user.uid
        var retryCount = 0
        
        // Function to attempt user deletion
        func attemptUserDeletion() {
            user.delete { error in
                if let error = error {
                    // Retry on failure up to 3 times
                    if retryCount < 2 { // Retry 3 times (total attempts: 0, 1, 2)
                        retryCount += 1
                        attemptUserDeletion()
                    } else {
                        // Max retries reached
                        completion(.failure(error))
                    }
                } else {
                    // Success
                    completion(.success(()))
                }
            }
        }
        
        // Delete user data from Firestore
        FirestoreService.shared.deleteUserData(userId: userId) { result in
            switch result {
            case .success:
                // Once Firestore data is deleted, attempt to delete user
                attemptUserDeletion()
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func checkIfEmailRegistered(email: String, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        
        // Check if a document with the email exists in usersByEmail collection
        db.collection("usersByEmail").document(email).getDocument { (document, error) in
            if let error = error {
                print("Error fetching document: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            if let _ = document, document!.exists {
                // Document with the email exists
                completion(true)
            } else {
                // Document with the email does not exist
                completion(false)
            }
        }
    }
}
