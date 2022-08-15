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
        if (!self.listDrawings().isEmpty) {
            
            var latestDocId = self.getDrawingId(drawingName:self.sortDocs(drawings:self.listDrawings())[0]);
            index = latestDocId + 1;
        } else {
            index = index + 1;
        }
    }
    
    func setCurrentIndex(_ newIndex: String) {
        index = Int(newIndex) ?? 1;
    }
    
    func setCurrentIndex(_ newIndex: Int) {
        index = newIndex;
    }
    
    func getMostRecentIndex() -> Int {
        if (!self.listDrawings().isEmpty) {
            return getDrawingId(drawingName:sortDocs(drawings:listDrawings())[0]);
        } else {
            return index;
        }
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
    
    
    func getTweetId(drawingId:String) -> String {
        var tweetId = "";
        let fileManager: FileManager = FileManager.default;
        var url = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first;
       
        do {
            
            var drawingUrl = url!.appendingPathComponent("drawing-" + drawingId)
            try tweetId = String(decoding:(drawingUrl.extendedAttribute(forName: "tweetId")), as: UTF8.self)
        
            NSLog("got tweet id " + tweetId + "  for " + "drawing-" + drawingId)
            NSLog("got tweet id " + tweetId + "  for url " + drawingUrl.absoluteString )

        } catch {
            NSLog("get tweet id  error");
        }
        return tweetId;
    }
    
    func addTweetId(tweetId:String, drawingId:String) {
        var id = Int(drawingId) ?? 0;
        let fileManager: FileManager = FileManager.default;
        var url = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first;
       
        do {
            
            var drawingUrl = url!.appendingPathComponent("drawing-" + drawingId)
            try drawingUrl.setExtendedAttribute(data: tweetId.data(using: .utf8)!, forName: "tweetId")
        
            NSLog("added tweetd id to " + "drawing-" + drawingId)
        } catch {
            NSLog("add tweet id  error");
        }
        
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
    
    func getPKDrawing(id:Int) -> PKDrawing {
        return getPKDrawing(id:(id as NSNumber).stringValue);
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

    
    func deletePKDrawing(id:Int) {
        deletePKDrawing(id:(id as NSNumber).stringValue);
    }

    
    func deletePKDrawing(id:String) {
        let fileManager: FileManager = FileManager.default;
        var url = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first;
        var file = url!.appendingPathComponent("drawing-" + id)
        do {
                 try FileManager.default.removeItem(at: file)
           } catch {
             print("File Deletion Failed: \(error.localizedDescription)")
           }

        
        
    }

}

