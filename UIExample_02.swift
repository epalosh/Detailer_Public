/* 

Code by Ethan Palosh for the iOS App "Detailer"

UIExample_02 - Message Detail View

This file defines the detailed view of a received message.
    - Here the user can view the entire contents of the message in a visually appealing way, and leave comments!

Published for portfolio purposes only.

*/


import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct MessageDetailView: View {
    
    var message: UserMessage                // Passed as a parameter to this view
    
    @State private var animate = false      // State for prompt background animation
    @State private var newComment = ""      // Stores user text input if typing a comment
    
    @ObservedObject var viewModel: ConnectionViewModel  // Uses values from ConnectionViewModel
    
    var body: some View {
        
        // encapsulating scrollview
        ScrollView {
            
            VStack(alignment: .leading) {
                
                Text("From: \(viewModel.getNickname(forUID: message.fromUID) ?? "Unknown")")
                    .font(.headline)

                Text("Received: \(message.timestamp.dateValue(), formatter: DateFormatter.shortTime)")
                    .font(.footnote)
                    .foregroundColor(.gray)
                
                Divider()
                
                HStack {
                    Text("Noted Activities:")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                }
                .padding(.vertical, 8)
                
                VStack(alignment: .leading) {
                    ForEach(Array(message.notedActivities.enumerated()), id: \.offset) { index, item in
                        Text("\(index + 1): \(item)")
                            .padding(.vertical, 0)
                    }
                }
                .padding([.bottom, .trailing])
                
                // if there's a prompt, then display it
                if(message.prompt != ""){
                    HStack {
                        Text("Prompt:")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Spacer()
                    }
                    
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.clear)
                            .modifier(AnimatableGradientModifier2(fromColor: .purple, toColor: appColors.lavender, percentage: animate ? 1.0 : 0.0))
                            .onAppear {
                                withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                                    animate.toggle()
                                }
                            }
                        
                        
                        Text(message.prompt)
                            .padding()
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .fixedSize(horizontal: false, vertical: true) // Ensures dynamic height
                            .bold()
                            .font(.headline)
                    }
                    .cornerRadius(10)
                    .shadow(radius: 5)
                }
               
                HStack {
                    Text("Message:")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                }
                .padding(.vertical, 10)
                
                Text(message.response)
                    .font(.body)
                
                HStack {
                    Text("Comments:")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
                .padding(.vertical, 10)
                
                // displays comments
                if !message.comments.isEmpty {
                    
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(message.comments) { comment in
                            
                            // This ends up returning nil if the commment is not from a connection of the current user. In that case, it is filtered for privacy
                            
                            let nickname = viewModel.getNickname(forUID: comment.authorUID)
                            if (nickname != nil) || (comment.authorUID == Auth.auth().currentUser?.uid) {
                                VStack(alignment: .leading) {
                                    if(comment.authorUID == Auth.auth().currentUser?.uid){
                                        Text("You")
                                            .font(.headline)
                                    } else {
                                        Text(viewModel.getNickname(forUID: comment.authorUID) ?? "Unknown")
                                            .font(.headline)
                                    }
                                    Text(comment.comment)
                                        .font(.body)
                                        .padding(.bottom, 5)
                                }
                                .padding()
                                .background(Color(.secondarySystemBackground))
                                .cornerRadius(8)
                            } else {
                                EmptyView()
                            }
                        }
                    }
                }
                else {
                    HStack {
                        Spacer()
                        
                        Text("No comments yet.")
                            .foregroundColor(.primary)
                        
                        Spacer()
                    }
                    .padding(.vertical, 10)
                }
                
                // place for adding new comments
                TextField("Type your comment here", text: $newComment)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .padding(.top, 20)
                    .onChange(of: newComment) {
                        if newComment.count > 100 {
                            newComment = String(newComment.prefix(100))
                        }
                    }
                
                HStack {
                    Spacer()
                    
                    Button(action: {
                        viewModel.addComment(to: message, comment: newComment, senderUID: Auth.auth().currentUser?.uid ?? "")
                        newComment = ""
                        
                    }) {
                        Text("Add Comment")
                            .padding(.vertical, 8)
                            .padding(.horizontal, 20)
                            .background(appColors.lavender)
                            .foregroundColor(.white)
                            .cornerRadius(5)
                    }
                    .padding(.bottom, 20)
                .disabled(newComment == "")
                }
                
                Spacer()
                
            }
            .padding()
            .fixedSize(horizontal: false, vertical: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
        }
    }
}

#Preview {
    MessageDetailView(
        message: UserMessage(
            id: "exampleMessageID",
            fromUID: "exampleFromUID",
            toUIDs: ["exampleToUID1", "exampleToUID2"],
            response: "This is an example message.",
            timestamp: Timestamp(date: Date()),
            prompt: "This is a lovely prompt that prompted this message",
            notedActivities: ["Activity that I did", "Another activity", "and...another one!"],
            comments: [Comment(comment: "Wow, looks great!", authorEmail: "test@test.com", authorUID: "123567890", timestamp: Date().formatted())],
            messageVersion: 1.0,
            read: false,
            timestampRead: "",
            newCommentForSender: false, 
            newCommentForRecipient: false
        ),
        viewModel: ConnectionViewModel.shared
    )
}
