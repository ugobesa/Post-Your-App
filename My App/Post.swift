//
//  Post.swift
//  My App
//
//  Created by Ugo Besa on 16/02/2016.
//  Copyright © 2016 Ugo Besa. All rights reserved.
//

import Foundation
import Firebase

class Post {
    private var _postDescription:String!
    private var _imageUrl:String?
    private var _likes:Int!
    private var _username:String!
    private var _postKey:String!
    private var _postRef:Firebase!
    private var _likedByCurrentUser = false
    
    var postDescription:String {
        return _postDescription
    }
    
    var imageUrl:String? {
        return _imageUrl
    }
    
    var likes:Int {
        return _likes
    }
    
    var username:String {
        return _username
    }
    
    var postKey:String {
        return _postKey
    }
    
    var likedByCurrentUser:Bool {
        get {
            return _likedByCurrentUser
        }
        set (liked) {
            _likedByCurrentUser = liked
        }
    }
    
    init(description:String, imageUrl:String?, username:String) {
        _postDescription = description
        _imageUrl = imageUrl
        _username = username
    }
    
    init(postKey:String, dictionary:Dictionary<String,AnyObject>){
        _postKey = postKey
        if let likes = dictionary["likes"] as?Int {
            _likes = likes
        }
        if let description = dictionary["description"] as?String {
            _postDescription = description
        }
        if let imageUrl = dictionary["imageUrl"] as?String {
            _imageUrl = imageUrl
        }
        
        _postRef = DataService.ds.REF_POSTS.childByAppendingPath(_postKey)
    }
    
    func adjustLikes(addLike: Bool){
        if addLike {
            _likes = _likes + 1
            _likedByCurrentUser = true
        }else{
            _likes = _likes - 1
            _likedByCurrentUser = false
        }
        
        _postRef.childByAppendingPath("likes").setValue(_likes)
        
    }
    
}
