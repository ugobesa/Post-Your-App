//
//  DataService.swift
//  My App
//
//  Created by Ugo Besa on 14/02/2016.
//  Copyright © 2016 Ugo Besa. All rights reserved.
//

import Foundation
import Firebase

let URL_BASE = "" // write your own firebase url

class DataService {
    static let ds = DataService()
    
    private var _REF_BASE = Firebase(url: "\(URL_BASE)")
    var REF_BASE : Firebase {
        return _REF_BASE
    }
    
    private var _REF_POSTS = Firebase(url: "\(URL_BASE)/posts")
    var REF_POSTS : Firebase {
        return _REF_POSTS
    }
    
    private var _REF_USERS = Firebase(url: "\(URL_BASE)/users")
    var REF_USERS : Firebase {
        return _REF_USERS
    }
    
    var REF_USER_CURRENT : Firebase {
        let uid = NSUserDefaults.standardUserDefaults().objectForKey(KEY_UID) as!String
        let user = Firebase(url: "\(URL_BASE)").childByAppendingPath("users").childByAppendingPath(uid) // same as Firebase(url: "\(URL_BASE)\users\uid")
        return user!
    }
    
    func createFireBaseUser(uid: String, user: Dictionary<String,String!>) {
        REF_USERS.childByAppendingPath(uid).setValue(user) // URL_BASE/users/ceh676efhe + setValue(user)
    }
    
    
}