//
//  AlertController.swift
//  RouteTestTask
//
//  Created by Bakhtiyarov Fozilkhon on 19.06.2023.
//

import UIKit

extension RouteViewController {
    
    func presentAlert(title: String, placeholder: String, completionHandler: @escaping (String) -> Void) {
        
        let alertVC = UIAlertController(title: title, message: "", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default) { action in
            let getText = alertVC.textFields?.first?.text
            guard let text = getText else { return }
            completionHandler(text)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { action in }
        
        alertVC.addTextField { tf in
            tf.placeholder = placeholder
        }
        
        alertVC.addAction(okAction)
        alertVC.addAction(cancelAction)
        
        present(alertVC, animated: true)
    }
    
    func alertError(title: String, message: String) {
        let alertVC = UIAlertController()
        let okAction = UIAlertAction(title: "OK", style: .default)
        
        alertVC.addAction(okAction)
        
        present(alertVC, animated: true)
    }
}
