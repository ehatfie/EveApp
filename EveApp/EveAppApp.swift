//
//  EveAppApp.swift
//  EveApp
//
//  Created by Erik Hatfield on 5/24/23.
//

import SwiftUI
import OAuthSwift

@main
struct EveAppApp: App {
    @State private var model = AppModel()
    
    init() {
       //NSAppleEventManager.shared().setEventHandler(self, andSelector:#selector(handleGetURL(event:withReplyEvent:)), forEventClass: AEEventClass(kInternetEventClass), andEventID: AEEventID(kAEGetURL))
        
    }
    
    
    @State var accessKey: String?
    
    func handleGetURL(event: NSAppleEventDescriptor!, withReplyEvent: NSAppleEventDescriptor!) {
        if let urlString = event.paramDescriptor(forKeyword: AEKeyword(keyDirectObject))?.stringValue, let url = URL(string: urlString) {
            OAuthSwift.handle(url: url)
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .handlesExternalEvents(preferring: ["eveauth-app"], allowing: ["eveauth-app"])
                .onOpenURL { (url) in
                    // Handle url here
                    print("url \(url)")
                    //OAuthSwift.handle(url: url)
                    let deeplinker = Deeplinker()
                    guard let deeplink = deeplinker.manage(url: url) else { return }
                    switch deeplink {
                    case .accessKey(let accessKey):
                        DataManager.shared.useAccessKey(accessKey)
                    default: return
                    }
                    self.accessKey = accessKey
                    print("deeplink \(deeplink)")
                }
                .environment(model)
                
        }
    }
}
