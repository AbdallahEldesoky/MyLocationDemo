//
//  Helper.swift
//  MyLocationsDemo
//
//  Created by Abdallah on 9/9/19.
//  Copyright © 2019 Abdallah Eldesoky. All rights reserved.
//

import Foundation


let appDocumentsDirectory: URL = {
    
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}()

let coreDataSaveFailedNotification = Notification.Name(rawValue: "CoreDataSaveFailed")

func fatalCoreDataError (_ error: Error) {
    print("Fatal error: \(error)")
    NotificationCenter.default.post(name: coreDataSaveFailedNotification, object: nil)
}

func after(delay seconds: Double, run: @escaping ()-> Void) {
    
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: run)
}


