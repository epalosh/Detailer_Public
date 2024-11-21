/* 

Code by Ethan Palosh for the iOS App "Detailer"

UIExample_01 - Settings View

This file defines the setings menu, accessible from the dashboard.
    - Here the user can update their profile, change notification settings, log out, and delete their account.

Published for portfolio purposes only.

*/


import SwiftUI

struct SettingsView: View {
    
    @State private var editProfileView: Bool = false                // State logic to display the editProfileView popup
    @State private var notificationsView: Bool = false                // State logic to display the notificationsView popup
    
    
    @State private var showAlert = false
    @State private var showSuccessAlert = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    
    var body: some View {
        
        // encapsulating navigationview
        NavigationView{
            
            // encapsulating vstack of elements
            VStack{
                
                HStack {
                    Text("Settings")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .padding()
                    Spacer()
                }
                
                
                // vstack of buttons
                VStack (spacing: 8){
                    Spacer()
                    
                    Button(action: {
                        editProfileView = true
                    }) {
                        HStack {
                            Text("Edit Profile")
                                .bold()
                                .foregroundColor(.white)
                                .cornerRadius(8)
                                .padding()
                            Spacer()
                            Image(systemName: "person.fill")
                                .foregroundStyle(.white)
                                .padding(.horizontal)
                        }
                        .frame(maxWidth: .infinity)
                        .background(appColors.lavender)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    Button(action: {
                        notificationsView = true
                    }) {
                        HStack {
                            Text("Notification Settings")
                                .bold()
                                .foregroundColor(.white)
                                .cornerRadius(8)
                                .padding()
                            Spacer()
                            Image(systemName: "bell.fill")
                                .foregroundStyle(.white)
                                .padding(.horizontal)
                        }
                        .frame(maxWidth: .infinity)
                        .background(appColors.lavender)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                
                    Button(action: {
                        showAlert = true
                    }) {
                        HStack {
                            Text("Delete Your Account")
                                .bold()
                                .foregroundColor(.red)
                                .cornerRadius(8)
                                .padding()
                            Spacer()
                            Image(systemName: "person.slash.fill")
                                .foregroundStyle(.red)
                                .padding(.horizontal)
                        }
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    
                    Button(action: signOut) {
                        HStack {
                            Text("Sign Out")
                                .bold()
                                .foregroundColor(.primary)
                                .cornerRadius(8)
                                .padding()
                            Spacer()
                            Image(systemName: "door.left.hand.open")
                                .foregroundStyle(Color.primary)
                                .padding(.horizontal)
                        }
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .alert(isPresented: $showErrorAlert) {
                    Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
                }
                
                Spacer()
                    .alert(isPresented: $showSuccessAlert) {
                       Alert(title: Text("Success"), message: Text("Your account has been deleted successfully."), dismissButton: .default(Text("OK")) {
                           // Navigate to CreateAccountView after successful account deletion
                           UIApplication.shared.windows.first?.rootViewController = UIHostingController(rootView: CreateAccountView())
                       })
                   }
                
                // app disclaimer and contact info
                VStack {
                        
                    
                    Text("Detailer is a work in progress, and your feedback is highly valued. Feel free to suggest a new feature!....or report a bug!")
                        .multilineTextAlignment(.center)
                        .italic()
                        .padding(.horizontal)
                        .padding(.top, 10)
                    
                    Link("Contact me here", destination: URL(string: "mailto:thedetailerapp@gmail.com")!)
                        .padding()
                        .bold()
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .background(appColors.lavender)
                        .cornerRadius(10)
                        .padding(.horizontal)
                    
                }
                .padding(.bottom)
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("Are you sure?"),
                        message: Text("Do you really want to delete your account? This action cannot be undone."),
                        primaryButton: .destructive(Text("Delete")) {
                            deleteAccount()
                        },
                        secondaryButton: .cancel()
                    )
                }
                
            }
            .sheet(isPresented: $editProfileView, content: {
                UpdateProfileView(viewModel: UserViewModel())
            })
            .sheet(isPresented: $notificationsView, content: {
                NotificationSettingsView()
            })
            
        }
    }
    
    // locally defined function to sign the user out
    private func signOut() {
        AuthService.shared.signOut { result in
            switch result {
            case .success:
                print("Signed out successfully")
                DispatchQueue.main.async {
                    UIApplication.shared.windows.first?.rootViewController = UIHostingController(rootView: CreateAccountView())
                }
            case .failure(let error):
                print("Sign out error: \(error.localizedDescription)")
            }
        }
    }
    
    private func deleteAccount() {
        AuthService.shared.deleteAccount { result in
            switch result {
            case .success:
                showSuccessAlert = true
            case .failure(let error):
                errorMessage = error.localizedDescription
                showErrorAlert = true
            }
        }
    }
}

#Preview {
    SettingsView()
}
