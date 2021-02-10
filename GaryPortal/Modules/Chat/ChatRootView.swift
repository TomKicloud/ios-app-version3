//
//  ChatListView.swift
//  GaryPortal
//
//  Created by Tom Knighton on 31/01/2021.
//

import SwiftUI
import Combine
import Introspect
import ActionClosurable

struct ChatRootView: View {
    
    var body: some View {
        ChatListView()
    }
}

struct ChatListView: View {
    
    @ObservedObject var dataSource: ChatListDataSource = ChatListDataSource()
    
    @State var isShowingNameAlert = false
    @State var isShowingAlert = false
    @State var alertContent: [String] = []
    @State var selectedChat: Chat?
    @State var newName: String = ""
    
    var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                LazyVStack {
                    ForEach(dataSource.chats, id: \.chatUUID) { chat in
                        NavigationLink(destination: NavigationLazyView(ChatView(chat: chat))) {
                            ChatListItem(chat: chat)
                        }
                        .contextMenu(menuItems: {
                            if chat.chatIsProtected == false {
                                Button(action: { self.beginEditChat(chat: chat) }, label: {
                                    Text("Rename chat")
                                    Image(systemName: "pencil")
                                })
                                Button(action: { }, label: {
                                    Text("Leave chat")
                                    Image(systemName: "hand.wave.fill")
                                })
                            }
                        })
                    }
                    .animation(Animation.spring())
                }
                .introspectScrollView { (scrollView) in
                    scrollView.refreshControl = UIRefreshControl { refreshControl in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            self.dataSource.loadChats()
                            refreshControl.endRefreshing()
                        }
                    }
                    
                }
            }
            .onAppear {
                self.dataSource.loadChats()
            }
            .background(Color.clear)
            
            AZAlert(title: "New Chat Name", message: "Enter a new chat name for: \(self.selectedChat?.getTitleToDisplay(for: GaryPortal.shared.currentUser?.userUUID ?? "") ?? "")", isShown: $isShowingNameAlert, text: $newName) { (newName) in
                let newName = newName.trim()
                if !newName.isEmptyOrWhitespace() {
                    guard let selectedChat = self.selectedChat else { return }
                    
                    self.dataSource.changeChatName(chat: selectedChat, newName: newName)
                    GaryPortal.shared.chatConnection?.editChatName(selectedChat.chatUUID ?? "", to: newName)
                } else {
                    self.alertContent = ["Error", "Please enter a valid chat name"]
                    self.isShowingAlert = true
                }
            }

        }
        
    }
    
    func beginEditChat(chat: Chat) {
        self.selectedChat = chat
        self.isShowingNameAlert = true
    }
}


struct ChatListItem: View {
    
    var chat: Chat
    let unreadGradient = [Color(UIColor(hexString: "#5f2c82")), Color(UIColor(hexString: "#49a09d"))]
    
    var body: some View {
        HStack {
            Spacer().frame(width: 16)
            VStack {
                HStack {
                    Spacer().frame(width: 16)
                    
                    chat.profilePicToDisplay(for: GaryPortal.shared.currentUser?.userUUID ?? "")
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                    
                    Spacer().frame(width: 16)
                    Text(chat.getTitleToDisplay(for: GaryPortal.shared.currentUser?.userUUID ?? ""))
                        .font(.custom("Montserrat-SemiBold", size: 19))
                        .foregroundColor(.primary)
                    Spacer()
                
                    Spacer().frame(width: 16)
                }
                Spacer().frame(height: 8)
                HStack {
                    Spacer().frame(width: 82)
                    Text(chat.getLastMessageToDisplay(for: GaryPortal.shared.currentUser?.userUUID ?? ""))
                        .font(.custom("Montserrat-Light", size: 14))
                        .multilineTextAlignment(.leading)
                        .frame(maxHeight: 80)
                        .foregroundColor(.secondary)
                    Spacer()
                    
                    if chat.hasUnreadMessages(for: GaryPortal.shared.currentUser?.userUUID ?? "") {
                        LinearGradient(gradient: Gradient(colors: self.unreadGradient), startPoint: .topLeading, endPoint: .bottomTrailing)
                            .frame(width: 16, height: 16)
                            .clipShape(Circle())
                            .shadow(radius: 2)
                    }
                    
                    Spacer().frame(width: 16)
                }
                
                
            }
            .padding(.top, 16)
            .padding(.bottom, 16)
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .cornerRadius(20)
            .shadow(radius: 10)
            
            Spacer().frame(width: 16)
        }
        
    }
}
