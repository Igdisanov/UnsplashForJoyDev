//
//  LikeImageViewController.swift
//  UnsplashForJoyDev
//
//  Created by Vadim Igdisanov on 08.10.2022.
//

import UIKit
import CoreData
import SDWebImage

class LikeImageTableViewController: UIViewController {
    
    
    let tableVC = UITableView()
    private var savedPhotos: [SavePhoto] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getData()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getData()
        tableVC.reloadData()
    }
    
    private func setupTableView() {
        view.addSubview(tableVC)
        tableVC.dataSource = self
        tableVC.delegate = self
        
        tableVC.register(UITableViewCell.self, forCellReuseIdentifier: "likeCell")
        
        tableVC.translatesAutoresizingMaskIntoConstraints = false
        tableVC.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableVC.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableVC.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tableVC.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        tableVC.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }
    
    private func getContext() -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    private func getData() {
        let context = getContext()
        let fetchRequest: NSFetchRequest<SavePhoto> = SavePhoto.fetchRequest()
        do {
            savedPhotos = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
}

// MARK: - Table view data source
extension LikeImageTableViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection: Int) -> Int {
        savedPhotos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "likeCell", for: indexPath)
        
        let url = URL(string: savedPhotos[indexPath.row].imageURL ?? "")
        cell.imageView?.sd_setImage(with: url)
        cell.textLabel?.text = self.savedPhotos[indexPath.row].name ?? ""
        cell.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailInfoVC = DetailInfoViewController()
        let savedPhoto = savedPhotos[indexPath.row]
        let photo = TestPhoto(name: savedPhoto.name ?? "",
                              imageURL: savedPhoto.imageURL ?? "",
                              likeCount: savedPhoto.likeCount ?? "",
                              location: savedPhoto.location ?? "",
                              identifier: savedPhoto.identifier ?? "")
        detailInfoVC.photo = photo
        navigationController?.pushViewController(detailInfoVC, animated: true)
    }
}



