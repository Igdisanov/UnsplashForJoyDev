//
//  DetailInfoViewController.swift
//  UnsplashForJoyDev
//
//  Created by Vadim Igdisanov on 09.10.2022.
//

import UIKit
import UnsplashPhotoPicker
import SDWebImage
import CoreData
import SimpleImageViewer


class DetailInfoViewController: UIViewController {
    
    var savedPhotos: [SavePhoto] = []
    
    var photo: ShortInfoImage! {
        didSet {
            guard let url = URL(string: photo.imageURL) else {return}
            imageView.sd_setImage(with: url, completed: nil)
            nameLabel.text = "Автор: \(photo.name)"
            locationLabel.text = "Местоположение: \(photo.location)"
            downloadsCountLabel.text = "♥ \(photo.likeCount)"
        }
    }
    
    
    var unsplashPhoto: UnsplashPhoto! {
        didSet {
            guard let imageURL = unsplashPhoto.urls[.regular] else {return}
            
            photo = ShortInfoImage(name: "\(unsplashPhoto.user.firstName ?? "") \(unsplashPhoto.user.lastName ?? "")",
                                  imageURL: "\(imageURL)",
                                  likeCount: "\(unsplashPhoto.likesCount)",
                                  location: unsplashPhoto.user.location ?? "",
                                  identifier: unsplashPhoto.identifier)
            
        }
    }
    
    // MARK: View object
    
    private let favoriteButtom: UIButton = {
       let button = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        button.setImage(UIImage(systemName: "suit.heart"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(favoriteButtonAction), for: .touchUpInside)
       return button
   }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        return label
    }()
    
    private let locationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        return label
    }()
    
    private let downloadsCountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        return label
    }()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        getData()
        setupUI()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer){
        openImageFullScreen(image: imageView)
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        view.backgroundColor = .systemGray6
        
        setupImageView()
        setupNameLabel()
        setupFavoriteButtom()
        setuplocationLabel()
        setupDownloadsCountLabel()
    }
    
    private func setupFavoriteButtom() {
        self.view.addSubview(favoriteButtom)
        favoriteButtom.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16).isActive = true
        favoriteButtom.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        for photo in savedPhotos {
            if photo.identifier == self.photo.identifier {
                favoriteButtom.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                return
            }
        }
    }
    
    private func setupImageView() {
        self.view.addSubview(imageView)
        imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80).isActive = true
        imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -(view.frame.size.height/2)).isActive = true
        
    }
    
    private func setupNameLabel() {
        self.view.addSubview(nameLabel)
        
        nameLabel.widthAnchor.constraint(equalToConstant:  400).isActive = true
        nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16).isActive = true
        
    }
    
    private func setuplocationLabel() {
        self.view.addSubview(locationLabel)
        
        locationLabel.widthAnchor.constraint(equalToConstant:  400).isActive = true
        locationLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 16).isActive = true
        locationLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
    }
    
    private func setupDownloadsCountLabel() {
        self.view.addSubview(downloadsCountLabel)
        
        downloadsCountLabel.widthAnchor.constraint(equalToConstant:  400).isActive = true
        downloadsCountLabel.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 16).isActive = true
        downloadsCountLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
    }
    
    // MARK: - Action Button
    
    @objc private func cancelButtonAction() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func favoriteButtonAction() {
        for photo in savedPhotos {
            if photo.identifier == self.photo.identifier {
                favoriteButtom.setImage(UIImage(systemName: "suit.heart"), for: .normal)
                showAlert(photo: photo)
                return
            }
        }
        
        savePhoto(photo: self.photo)
        favoriteButtom.setImage(UIImage(systemName: "heart.fill"), for: .normal)
    }
    
    private func openImageFullScreen(image: UIImageView) {
        let configuration = ImageViewerConfiguration { config in
            config.imageView = image
        }
        
        let imageViewerController = ImageViewerController(configuration: configuration)
        
        present(imageViewerController, animated: true)
    }
    
    // MARK: - CoreData
    
    private func getContext() -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    private func savePhoto(photo: ShortInfoImage) {
        let context = getContext()
        guard let entity = NSEntityDescription.entity(forEntityName: "SavePhoto", in: context) else {return}
        let photoObject = SavePhoto(entity: entity, insertInto: context)
        photoObject.name = photo.name
        photoObject.location = photo.location
        photoObject.likeCount = photo.likeCount
        photoObject.imageURL = photo.imageURL
        photoObject.identifier = photo.identifier
        
        do {
            try context.save()
            self.savedPhotos.append(photoObject)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
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
    
    private func deleteData(photo: SavePhoto) {
        let context = getContext()
        let fetchRequest: NSFetchRequest<SavePhoto> = SavePhoto.fetchRequest()
        if let objects = try? context.fetch(fetchRequest) {
            for object in objects {
                if object.identifier == photo.identifier {
                context.delete(object)
                }
            }
        }
        do {
            try context.save()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    private func showAlert(photo: SavePhoto) {
        let alertController = UIAlertController(title: "", message: "Удалить из избранного?", preferredStyle: .alert)
        let add = UIAlertAction(title: "Удалить", style: .default) { (action) in
            self.deleteData(photo: photo)
        }
        let cancel = UIAlertAction(title: "Отменить", style: .cancel) { (action) in
        }
        add.setValue(UIColor.red, forKey: "titleTextColor")
        alertController.addAction(add)
        alertController.addAction(cancel)
        present(alertController, animated: true)
    }
    
}
