//
//  NotificationService.swift
//  NotificationService - for handling push notification before show it
//
//  Created by David on 09.01.2025.
//

import UserNotifications
import UIKit
import AVFoundation

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        NSLog("didReceive:\(request.content)")
        if let bestAttemptContent = bestAttemptContent {
            
// fix - params needs to pass push data to flutter_local_notifications library
            bestAttemptContent.userInfo["NotificationId"] = request.identifier
            bestAttemptContent.userInfo["presentAlert"] = false
            bestAttemptContent.userInfo["presentSound"] = false
            bestAttemptContent.userInfo["presentBadge"] = false
            bestAttemptContent.userInfo["presentBanner"] = false
            
// download and create push attachment to display
            if let url = request.content.userInfo["firstAttachmentUrl"] as? String {

                do {
                    let identifier = ProcessInfo.processInfo.globallyUniqueString
                    
                    let data = try Data(contentsOf: URL(string: url)!)
                    let isImage = UIImage(data: data) != nil ? true : false

                    guard let attachment = UNNotificationAttachment.create(identifier: identifier, data: data, url: url, isImage: isImage, options: nil) else {
                        contentHandler(bestAttemptContent)
                        return
                    }
                    bestAttemptContent.body = isImage ? "Image" : "Video" + " attachment"
                    bestAttemptContent.attachments = [attachment]
                } catch {
                    print("Unable to load data: \(error)")
                }
            }
            contentHandler(bestAttemptContent)
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent = bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
}

extension UNNotificationAttachment {
    
    static func getThumbnailData(forUrl url: URL) -> Data? {
        let asset: AVAsset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)

        do {
            let thumbnailImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 60), actualTime: nil)
            let uiImage = UIImage(cgImage: thumbnailImage)
            return uiImage.jpegData(compressionQuality: 1.0)
        } catch let error {
            print(error)
        }

        return nil
    }
    
    static func create(identifier: String, data: Data, url: String, isImage: Bool, options: [NSObject : AnyObject]?) -> UNNotificationAttachment? {
        let fileManager = FileManager.default
        let tmpSubFolderName = ProcessInfo.processInfo.globallyUniqueString
        let tmpSubFolderURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(tmpSubFolderName, isDirectory: true)
        do {
            try fileManager.createDirectory(at: tmpSubFolderURL, withIntermediateDirectories: true, attributes: nil)
            let imageFileIdentifier = identifier+".png"
            let fileURL = tmpSubFolderURL.appendingPathComponent(imageFileIdentifier)
            do {
                if(isImage) {
                    try data.write(to: fileURL, options: [])
                } else {
                    try getThumbnailData(forUrl: URL(string: url)!)?.write(to: fileURL, options: [])
                }

             } catch {
                 print("Unable to load data: \(error)")
             }
            let imageAttachment = try UNNotificationAttachment.init(identifier: imageFileIdentifier, url: fileURL, options: options)
            return imageAttachment
        } catch {
            print("error " + error.localizedDescription)
        }
        return nil
    }
}
