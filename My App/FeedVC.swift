//
//  FeedVC.swift
//  My App
//
//  Created by Ugo Besa on 15/02/2016.
//  Copyright © 2016 Ugo Besa. All rights reserved.
//

import UIKit
import Firebase
import Alamofire
import SwiftSpinner

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var tableView:UITableView!
    @IBOutlet weak var postField: MaterialTextField!
    @IBOutlet weak var imageSelectorImageView: UIImageView!
    
    var posts = [Post]()
    var imagePicker:UIImagePickerController!
    static var imageCache = NSCache()
    var imageSelected = false
    

    override func viewDidLoad() {
        super.viewDidLoad()
        //self.automaticallyAdjustsScrollViewInsets = false // for deleting the space at the top of the scrollview
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 385
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        
        DataService.ds.REF_POSTS.observeEventType(.Value, withBlock: { snapshot in
            
            self.posts = []
            
            if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                for snap in snapshots {
                    
                    if let postDic = snap.value as?Dictionary<String,AnyObject> {
                        let key = snap.key
                        let post = Post(postKey: key, dictionary: postDic)
                        self.posts.append(post)
                    }
                }
            }
            self.tableView.reloadData()
        })
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.row]
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("PostCell") as?PostCell {
            cell.request?.cancel() // cancel the "previous" request of the cell that goes off the screen
            var img:UIImage?
            if let url = post.imageUrl {
                img = FeedVC.imageCache.objectForKey(url)as?UIImage // FeedVC and not self to grab the single instance
            }
            cell.configurecell(post,image: img)
            return cell
        }
        else{
            return PostCell()
        }
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if let postCell = cell as?PostCell {
            postCell.configureWhenWillAppear()
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let post = posts[indexPath.row]
        if post.imageUrl == nil || post.imageUrl == "" {
            return 150 // make it smaller
        }
        else{
            return tableView.estimatedRowHeight
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        imageSelectorImageView.image = image
        imageSelected = true
    }
    
    //MARK: IBActions
    @IBAction func selectImage(sender: UITapGestureRecognizer) { // tap gesture recognizer + user interaction enabled in interface builder
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func postPressed(sender: AnyObject) {
        
        if let txt = postField.text where txt != "" {
            if let img = imageSelectorImageView.image where imageSelected{
                SwiftSpinner.show("Uploading...")
                let urlStr = "https://post.imageshack.us/upload_api.php"
                let url = NSURL(string: urlStr)!
                let imgData = UIImageJPEGRepresentation(img, 0.2)! // 0 fully compressed, 1 compressed
                let keyData = "use your own key for imageshack".dataUsingEncoding(NSUTF8StringEncoding)!
                let keyJSON = "json".dataUsingEncoding(NSUTF8StringEncoding)!
                Alamofire.upload(.POST, url, multipartFormData: { multipartFormData in
                    
                    multipartFormData.appendBodyPart(data: imgData, name: "fileupload",fileName: "image", mimeType: "image/jpg")
                    multipartFormData.appendBodyPart(data: keyData, name: "key")
                    multipartFormData.appendBodyPart(data: keyJSON, name: "format")
                    
                    }){ encodingResult in
                        switch encodingResult {
                            
                        case .Success(let upload,_,_):
                            upload.responseJSON(completionHandler: { response in
                                if let info = response.result.value as? Dictionary<String,AnyObject>  {
                                    if let links = info["links"] as?Dictionary<String,AnyObject> {
                                        if let imageLink = links["image_link"] as?String {
                                            print("link: \(imageLink)")
                                            self.postToFirebase(imageLink)
                                        }
                                    }
                                }
                            })
                            
                        case .Failure(let error):
                            print(error)
                            SwiftSpinner.show("Sorry, an error occurend!",animated:false).addTapHandler({
                                SwiftSpinner.hide()
                                }, subtitle: "Tap to hide ")
                            
                        }
                }
            }
            else{
                self.postToFirebase(nil)
            }
        }
    }
    

    func postToFirebase(imgUrl:String?) {
        var post:Dictionary<String,AnyObject> = [
            "description" : postField.text!,
            "likes" : 0
        ]
        if imgUrl != nil {
            post["imageUrl"] = imgUrl!
        }
        
        let firebasePost = DataService.ds.REF_POSTS.childByAutoId()
        firebasePost.setValue(post)
        
        self.clearField()
        SwiftSpinner.hide()
    }
    
    func clearField() {
        postField.text = ""
        imageSelectorImageView.image = UIImage(named: "camera")
        imageSelected = false
        //tableView.reloadData()
    }


}
