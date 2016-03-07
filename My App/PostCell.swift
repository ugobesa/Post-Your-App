//
//  PostCell.swift
//  My App
//
//  Created by Ugo Besa on 15/02/2016.
//  Copyright © 2016 Ugo Besa. All rights reserved.
//

import UIKit
import Alamofire
import Firebase

class PostCell: UITableViewCell {
    
    @IBOutlet weak var profileImage:UIImageView!
    @IBOutlet weak var showcaseImg:UIImageView!
    @IBOutlet weak var descriptionTextView:UITextView!
    @IBOutlet weak var likesLabel:UILabel!
    @IBOutlet weak var likeImageView:UIImageView!
    
    private var post:Post!
    var request:Request? // Alamofire
    var likeRef:Firebase!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Can't use IBAction for repeatble UI like cells. Use gesture recognizer
        let tap = UITapGestureRecognizer(target: self, action: "likeTapped:")
        tap.numberOfTapsRequired = 1
        likeImageView.addGestureRecognizer(tap)
        likeImageView.userInteractionEnabled = true
    }
    
    override func drawRect(rect: CGRect) {
        profileImage.layer.cornerRadius = profileImage.layer.cornerRadius/2
        profileImage.clipsToBounds = true
        showcaseImg.clipsToBounds = true // very important !!!
        descriptionTextView.scrollRangeToVisible(NSRange(location:0, length:0))
    }

    
    func configurecell(post:Post, image:UIImage?){
        self.post = post
        self.descriptionTextView.text = post.postDescription
        
        self.likesLabel.text = "\(post.likes)"
        
        if self.post.imageUrl != nil && self.post.imageUrl != "" { // if there is an image
            if image != nil { // use cached image
                self.showcaseImg.hidden = false
                self.showcaseImg.image = image
            }
            else{ // We donwload it and cache it
                request = Alamofire.request(.GET, post.imageUrl!).validate(contentType: ["image/*"])
                .response(completionHandler: { request, response, data, error in
                    if error == nil {
                        self.showcaseImg.hidden = false
                        let image = UIImage(data: data!)!
                        self.showcaseImg.image = image
                        self.showcaseImg.hidden = false
                        FeedVC.imageCache.setObject(image, forKey: self.post.imageUrl!)
                    }
                })
            }
        }
        else{
            self.showcaseImg.hidden = true
        }
        
        // did the user like this post ?
        likeRef = DataService.ds.REF_USER_CURRENT.childByAppendingPath("likes").childByAppendingPath(post.postKey)
        likeRef.observeSingleEventOfType(.Value, withBlock: { snapshot in // Observe once
            if let _ = snapshot.value as? NSNull { // Firebase gives a NSNull if there is no data
                // We didn't like this post
                self.likeImageView.image = UIImage(named: "heart-empty")
                self.post.likedByCurrentUser = false
            }
            else{
                self.likeImageView.image = UIImage(named: "heart-full")
                self.post.likedByCurrentUser = true
            }
        })
        
    }
    
    func likeTapped(sender:UITapGestureRecognizer){
        
        likeRef.observeSingleEventOfType(.Value, withBlock: { snapshot in // like ref is already define in configureCell
            if let _ = snapshot.value as? NSNull { // Firebase gives a NSNull if there is no data
                // We didn't like this post
                self.likeImageView.image = UIImage(named: "heart-full")
                self.post.adjustLikes(true)
                // Store the like in the user's total likes
                self.likeRef.setValue(true)
            }
            else{
                self.likeImageView.image = UIImage(named: "heart-empty")
                self.post.adjustLikes(false)
                self.likeRef.removeValue() // we remove the entire reference, not setting it to false !!
            }
        })
    }
    
    func configureWhenWillAppear(){
        if post.likedByCurrentUser {
            self.likeImageView.image = UIImage(named: "heart-full")
        }
        else{
            self.likeImageView.image = UIImage(named: "heart-empty")
        }
    }

}
