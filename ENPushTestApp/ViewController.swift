//
//  ViewController.swift
//  ENPushTestApp
//
//  Created by Anantha Krishnan K G on 16/02/22.
//

import UIKit
import ENPushDestination

class ViewController: UIViewController {
    
    var push: ENPush?
    @IBOutlet weak var textView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let guid = "<Event-notifications-instance-guid>"
        let apikey = "<Event-notifications-apikey>"
        let destId = "<Event-notifications-ios-destinationid>"
        
        push = ENPush.sharedInstance
        push?.setCloudRegion(region: .usSouth)
        push?.initialize(guid, destId, apikey)
        
        let name:NSNotification.Name = NSNotification.Name("tokenRecieved")
        NotificationCenter.default.addObserver(forName: name, object: nil, queue: .main) { [weak self] notifiction in
            self?.registerAction(UIButton())
        }
    }
    
    @IBAction func registerAction(_ sender: UIButton) {
        textView.insertText("\nStart registering device\n")

        let appdelgare = UIApplication.shared.delegate as! AppDelegate
        
        ENPush.sharedInstance.registerWithDeviceToken(deviceToken: appdelgare.devicetoken!, withUserId: "userId") { response, statusCode, error in
            
            guard error.isEmpty else {
                self.addText("Error: \(error)")

                return
            }
            print(response?.id ?? "")
            self.addText("deviceid: \(response?.id ?? "")")

        }
    }
    
    @IBAction func subscribeToTags(_ sender: UIButton) {
        
        addText("Start subscribe to tag")
        
        ENPush.sharedInstance.subscribeToTags(tagName: "Tech_IBM") { response, statusCode, error in
            guard error.isEmpty else {
                self.addText("Error: \(error)")
                return
            }
            print(response?.deviceId ?? "")
            self.addText("tag: \(response?.tagName ?? "")")
        }

    }
    
    
    @IBAction func unRegisterAction(_ sender: Any) {
        
        addText("Start unRegistering device")
        ENPush.sharedInstance.unregisterDevice { response, statusCode, error in
            
        }
    }
    
    @IBAction func unSubscribeToTags(_ sender: UIButton) {
        addText("Start unsubscribe from tag")
        ENPush.sharedInstance.unsubscribeFromTags(tagName: "Tech_IBM") { response, statusCode, error in
        }

    }
    @IBAction func clearAction(_ sender: Any) {
        textView.text = ""
    }
    
    func addText(_ string: String) {
        DispatchQueue.main.async { [self] in
            textView.insertText("\(string)\n")
        }
    }

}

