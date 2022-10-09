//
//  TabBarViewController.swift
//  UnsplashForJoyDev
//
//  Created by Vadim Igdisanov on 09.10.2022.
//

import UIKit
import UnsplashPhotoPicker

class TabBarViewController: UITabBarController {
    
    let configuration = UnsplashPhotoPickerConfiguration(
      accessKey: "Lq2wodGaVuEEkpF9UTUmhb4uiutHsPJJYx8uVT2vpRY",
      secretKey: "sOHfeneAqlYbBDOAg2pg6i8yuQwlCFJgsgM_qYPelZs"
    )
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let photoPicker = UnsplashPhotoPicker(configuration: configuration)
        photoPicker.photoPickerDelegate = self
        photoPicker.tabBarItem.image = UIImage(systemName: "photo.on.rectangle")
        
        let likeVC = UINavigationController(rootViewController: LikeImageTableViewController()) 
        likeVC.tabBarItem.title = "Like"
        likeVC.tabBarItem.image = UIImage(systemName: "heart")
        
        viewControllers = [photoPicker, likeVC]

    }
}

extension TabBarViewController: UnsplashPhotoPickerDelegate {
    
    func unsplashPhotoPicker(_ photoPicker: UnsplashPhotoPicker, didSelectPhotos photos: [UnsplashPhoto]) {
        let detailInfoVC = DetailInfoViewController()
        detailInfoVC.unsplashPhoto = photos[0]
        photoPicker.pushViewController(detailInfoVC, animated: true)
    }
    
    func unsplashPhotoPickerDidCancel(_ photoPicker: UnsplashPhotoPicker) {
        
    }
    
    
}
