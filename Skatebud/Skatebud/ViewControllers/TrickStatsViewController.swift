//
//  TrickStatsViewController.swift
//  Skatebud
//
//  Created by Thursheyco Arreguin on 1/9/21.
//

import UIKit
// Import MobileCoreServices to help share a captured image or video of Trick
import MobileCoreServices
import Photos

class TrickStatsViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    // Properties
    @IBOutlet weak var trickName: UILabel!
    @IBOutlet weak var amountLanded: UILabel!
    @IBOutlet weak var amountFailed: UILabel!
    @IBOutlet weak var attempts: UILabel!
    @IBOutlet weak var percentageLanded: UILabel!
    
    // Variable to hold a selected Trick from Stats View Controller
    var selectedTrick: Trick?
    
    // Instace variable to hold image or video to share
    var controller = UIImagePickerController()
    let videoFileName = "/video.mp4"
    
    // MARK: Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set trick sent here from stats vc
        if let t = selectedTrick {
            
            // DEBUG: print sent in Trick
            print(t.trickInfo)
            
            // Calculate percentage landed by dividing amount landed by attempts, and multiply by 100
            let lands: Double = Double(t.countLanded)
            let totalAttempts: Double = Double(t.countFailed + t.countLanded)
            let successPercentage = lands / totalAttempts * 100.0
            
            // DEBUG: print successPercentage
            print(lands)
            print(totalAttempts)
            print(successPercentage)
            
            // Populate the labels for passed in Trick
            trickName.text = t.name
            amountLanded.text = t.countLanded.description
            amountFailed.text = t.countFailed.description
            attempts.text = totalAttempts.description
            percentageLanded.text = String(format:"%.2f", successPercentage) + " %"
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: Actions
    @IBAction func deleteTrickTapped(_ sender: UIButton) {
        
        // DEBUG: print delete trick tap
        print("delete trick tap")
    }
    
    @IBAction func shareTrickTapped(_ sender: UIButton) {
        
        // DEBUG: print share trick tap
        print("share trick tap")
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            
            // Present controller to take a video
            controller.sourceType = .camera
            //controller.mediaTypes = [kUTTypeMovie as String]
            controller.delegate = self
            
            present(controller, animated: true, completion: nil)
        } else {
            // DEBUG: device does not have camera
            print("No camera")
        }
    }
    
    @IBAction func backTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    // Method to help save video to device's photo album
    @objc func videoSaved(_ video: String, didFinishSavingWithError error: NSError!, context: UnsafeMutableRawPointer){
        if let theError = error {
            print("error saving the video = \(theError)")
        } else {
           DispatchQueue.main.async(execute: { () -> Void in
           })
        }
    }
    
    // MARK: imagePicker delegates
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // Extract the URL for video
//        if let selectedVideo:URL = (info[UIImagePickerController.InfoKey.mediaURL] as? URL) {
//
//            // Save video to the main photo album
//            let selectorToCall = #selector(TrickStatsViewController.videoSaved(_:didFinishSavingWithError:context:))
//
//            // Save the video into the photo album on device
//            UISaveVideoAtPathToSavedPhotosAlbum(selectedVideo.relativePath, self, selectorToCall, nil)
//
//            // Save the video to the app directory
//            let videoData = try? Data(contentsOf: selectedVideo)
//            let paths = NSSearchPathForDirectoriesInDomains(
//            FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
//            let documentsDirectory: URL = URL(fileURLWithPath: paths[0])
//            let dataPath = documentsDirectory.appendingPathComponent(videoFileName)
//            try! videoData?.write(to: dataPath, options: [])
//
//            // Dismiss camera interface controller
//            picker.dismiss(animated: true, completion: nil)
//
//            // Create a URL with Instagram scheme
//            if let urlScheme = URL(string: "instagram-stories://share") {
//
//                // Check if Instagram is on the device
//                if UIApplication.shared.canOpenURL(urlScheme) {
//
//                    // Create paste board
//                    let items = [["com.instagram.sharedSticker.backgroundVideo": selectedVideo]]
//
//                    // Options for paste board expires in 5 minutes
//                    let pasteboardOptions = [UIPasteboard.OptionsKey.expirationDate: Date().addingTimeInterval(60*5)]
//
//                    // Set the items to paste board
//                    UIPasteboard.general.setItems(items, options: pasteboardOptions)
//
//                    // Share video to instagram
//                    UIApplication.shared.open(urlScheme, options: [:], completionHandler: nil)
//                }
//            }
//        }
        
        // Extract the URL for picture
        let pictureToShare = info[.originalImage] as? UIImage
        
        // Compress image to share to instagram
        let imageCompressed = pictureToShare?.resized(withPercentage: 0.8)
        
        // Get image of SkateBud app icon to share along with image
        let appStickerData = UIImage(named: "AppIconSplash")
        
        // Create a URL with Instagram scheme
        if let urlScheme = URL(string: "instagram-stories://share") {
            
            // Check if Instagram is on the device
            if UIApplication.shared.canOpenURL(urlScheme) {
                
                // Create paste board
                let items = [["com.instagram.sharedSticker.backgroundImage": imageCompressed, "com.instagram.sharedSticker.stickerImage" : appStickerData]]
                
                // Options for paste board expires in 5 minutes
                let pasteboardOptions = [UIPasteboard.OptionsKey.expirationDate: Date().addingTimeInterval(60*5)]
                
                // Set the items to paste board
                UIPasteboard.general.setItems(items, options: pasteboardOptions)
                
                // Share video to instagram
                UIApplication.shared.open(urlScheme, options: [:], completionHandler: nil)
            }
        }
        
        // Dismiss picker view
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
