//
//  AppDelegate.swift
//  Twill
//
//  Created by Ian Brown on 5/27/22.
//

import UIKit
import PencilKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var index = 0;



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        index = getMostRecentIndex();
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    
    func getCurrentIndex() -> String {
        let x = index as NSNumber;
        return x.stringValue;
    }
    
    func incrementCurrentIndex() {
        index = index + 1;
    }
    
    func getMostRecentIndex() -> Int {
        return getDrawingId(drawingName:sortDocs(drawings:listDrawings())[0]);
    }
    
    func getDrawingId(drawingName:String)-> Int {
        let drawingId = drawingName.split(separator: "-")[1];
        return Int(drawingId) ?? 0;
    }
    
    func sortDocs(drawings:[String]) -> [String] {
        let sortedDrawings = drawings.sorted { (lhs: String, rhs: String) -> Bool in
            
            let lhsId = getDrawingId(drawingName: lhs);
            let rhsId = getDrawingId(drawingName: rhs);
           
            return lhsId > rhsId
        }
        
        return sortedDrawings;
    }
    
    func listDrawings() -> [String] {
        
        var docs = NSMutableArray();
        
        do {

        // Get the document directory url
            let documentDirectory = try FileManager.default.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )
            print("documentDirectory", documentDirectory.path)
            // Get the directory contents urls (including subfolders urls)
            let directoryContents = try FileManager.default.contentsOfDirectory(
                at: documentDirectory,
                includingPropertiesForKeys: nil
            )
            print("directoryContents:", directoryContents.map {  $0.lastPathComponent })
            for url in directoryContents {
                print( url.lastPathComponent)
                docs.add(url.lastPathComponent);
            }
        
        } catch {
            print(error)
        }
        
        return docs as! [String];
        
    }
    
    func getPKDrawing(id:String) -> PKDrawing {
        var pkDrawing = PKDrawing();
     
        
        let fileManager: FileManager = FileManager.default;
        var url = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first;
       
        do {
            
            let drawingData = try Data(contentsOf:  url!.appendingPathComponent("drawing-" + id))
        
            pkDrawing = try PKDrawing(data: drawingData)
            NSLog("file read worked??")
        } catch {
            NSLog("reading file error");
        }
        
        return pkDrawing;
    }


}

