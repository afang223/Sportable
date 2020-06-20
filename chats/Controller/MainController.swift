//
//  ViewController.swift
//  chats
//
//  Created by Andy Fang on 6/4/20.
//  Copyright © 2020 Andy Fang. All rights reserved.
//

import UIKit
import Firebase
import MobileCoreServices
import AVFoundation

class MainController: UIViewController {
    let cellID = "cellID"
    
    var videos = [Video]()
    var vidTitle: String? = "videoTitle"
    
    fileprivate let collectionView:UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 10
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.register(UserCell.self, forCellWithReuseIdentifier: "cellID")
        view.bounces = true
        view.alwaysBounceVertical = true
        return view
    }()
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        navigationController?.navigationBar.barTintColor = .clear
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout",
                                                           style: .plain, target: self, action: #selector(handleLogout))
        
        
        let image = UIImage(named: "camera")?.withRenderingMode(.alwaysTemplate)
        let iv = UIImageView(image: image)
        iv.tintColor = .white
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: iv)
        navigationItem.rightBarButtonItem?.action = #selector(handleVidRecord)
        navigationItem.rightBarButtonItem?.target = self
        navigationItem.rightBarButtonItem?.style = .plain
        
        let button = UIButton(type: .system)
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(handleVidRecord), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.widthAnchor.constraint(equalToConstant: 50).isActive = true
        button.tintColor = .white
        navigationItem.rightBarButtonItem?.customView = button
        
    
        view.addSubview(collectionView)
        view.backgroundColor = UIColor(r: 242, g: 242, b: 242)
        collectionView.backgroundColor = UIColor.clear
        collectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 10).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        collectionView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        collectionView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        checkLogin()
        fetchUser()
    
    }
    
    func fetchUser() {
        if let uid = FirebaseAuth.Auth.auth().currentUser?.uid {
            FirebaseDatabase.Database.database().reference().child("users").child(uid).child("videos").observe(.childAdded, with: { (snapshot) in
                
                print(snapshot)
                print("video found")
                
                if let dictionary = snapshot.value as? [String: Any] {
                    let video = Video()
                    video.name = dictionary["vidName"] as? String
                    print("DICTIONARY: ", dictionary)
                    video.thumbnail = dictionary["thumbnailURL"] as? String
                    video.video = dictionary["videoURL"] as? String
                    self.videos.insert(video, at: 0)
                }
                
                
                
            }, withCancel: nil)
        }
    }
    
    @objc func handleVidRecord() {
        VideoHelper.startMediaBrowser(delegate: self, sourceType: .camera)
        
    }
    
    func checkLogin() {
        if FirebaseAuth.Auth.auth().currentUser?.uid == nil {
                print("reached")
                perform(#selector(handleLogout), with: nil, afterDelay: 0)
        
        } else {
            let uid = FirebaseAuth.Auth.auth().currentUser?.uid
            FirebaseDatabase.Database.database().reference().child("users").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
                
                print(snapshot)
                
                if let dictionary = snapshot.value as? [String: Any] {
                    self.navigationItem.title = dictionary["name"] as? String
                    
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                }
                
    
                
            }, withCancel: nil)
        }
    }
    
     @objc func handleLogout() {
        
        do {
            try Firebase.Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError)
        }
        
        let loginController = LoginController()
        present(loginController, animated: true, completion: nil)
    }
}
    
    
    extension MainController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            print("VIDEOS", videos.count)
            print(videos)
            return videos.count
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize(width: collectionView.frame.width/2.1 , height: collectionView.frame.width/2.1)
        }
        
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            let video = videos[indexPath.item]
            if let urlString = video.video,
                let vidName = video.name{
                let vc = VideoViewController(urlString: urlString, vidName: vidName)
                vc.modalPresentationStyle = .fullScreen
//                self.present(vc, animated: true, completion: nil)
                self.navigationController?.pushViewController(vc, animated: true)
            }   
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            
            print("cellForItemAt")
            
              guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellID",
                                                                       for: indexPath) as? UserCell else {
                                                                               fatalError("Wrong cell class dequeued")
               }
                let video = videos[indexPath.item]
                cell.label?.text = video.name!

            if let thumbnail = video.thumbnail {
                    cell.bg.loadImageWithCache(urlString: thumbnail)
                }
                       return cell
                       
            }
        
        
        }

class UserCell: UICollectionViewCell {
    
    var title: String? = "title"
    var image: UIImage? = UIImage(named: "trophy")!
    var label: UILabel? = UILabel()

    var bg: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.image = UIImage(named: "trophy")
        view.layer.cornerRadius = 12
        view.backgroundColor = UIColor(r: 80, g: 101, b: 161)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        contentView.addSubview(bg)
        contentView.addSubview(label!)
        bg.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        bg.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        bg.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        bg.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        label?.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8).isActive = true
        label?.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        label?.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.15).isActive = true
        label?.widthAnchor.constraint(equalTo: contentView.widthAnchor).isActive = true
        label?.translatesAutoresizingMaskIntoConstraints = false
        label?.text = title
        label?.backgroundColor = UIColor(r: 80, g: 101, b: 161)
        label?.numberOfLines = 0
        label?.textAlignment = .center
        label?.lineBreakMode = NSLineBreakMode.byWordWrapping
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


extension MainController: UIImagePickerControllerDelegate {
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        dismiss(animated: true, completion: nil)
        guard
            let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String,
            mediaType == (kUTTypeMovie as String),
            let url = info[UIImagePickerController.InfoKey.mediaURL] as? URL,
            UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(url.path) else {
                return
        }
        
        let vidName = NSUUID().uuidString
        let storageRef = FirebaseStorage.Storage.storage().reference().child(vidName + ".mov")
        UISaveVideoAtPathToSavedPhotosAlbum(
        url.path,
        self,
        #selector(video(_:didFinishSavingWithError:contextInfo:)),
        nil)
        
        if let uid = FirebaseAuth.Auth.auth().currentUser?.uid {
        
        
        storageRef.putFile(from: url as URL, metadata: nil, completion: { (metadata, error) in

            if error == nil {
                print("Successful video upload")
            } else {
                print(error?.localizedDescription)
            }
            
            storageRef.downloadURL(completion: {(url, error) in
                       
                       
                       print("trying to download")
                       if error != nil {
                           print(error)
                           return
                       }
                       
                let thumbnail = NSUUID().uuidString
                let thumbnailRef = FirebaseStorage.Storage.storage().reference().child(thumbnail + ".png")
                self.generateThumbnail(url: url!) { (data) in
                    if let uploadData = data {
                        thumbnailRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                                            if error != nil {
                                                print(error)
                                                return
                                            }
                            
                            thumbnailRef.downloadURL(completion: {(thumbURL, error) in
                                
                                if error != nil {
                                    print(error)
                                    return
                                }
                                
                                if let thumbnailURL = thumbURL?.absoluteString,
                                    let vidURL = url?.absoluteString{
                                
                                    print("HERE WE ARE")
                                    
                                    let entryTitle = self.vidTitle!
                                    
                                    let values = ["videoURL": vidURL, "thumbnailURL": thumbnailURL, "vidName": entryTitle] as [String: Any]
                                    self.addVideo(uid: uid, values: values, videoName: vidName)
                                }
                            })
                        })
                    }
                }
            })
        })
        }
        
        
        print("URL: ", url)
        print("URLPATH: ", url.path)
        
          
        }

    @objc func video(_ videoPath: String, didFinishSavingWithError error: Error?, contextInfo info: AnyObject) {
      let title = (error == nil) ? "Success" : "Error"
      let message = (error == nil) ? "Video was saved" : "Video failed to save"
      
      let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "Enter video title"
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (alertAction) in
            let textField = alert.textFields![0] as UITextField
            self.vidTitle = textField.text
            print(self.vidTitle!)
        }))
        
        present(alert, animated: true, completion: nil)
        
    }
    
    func addVideo(uid: String, values: [String: Any], videoName: String) {
        let ref = Firebase.Database.database().reference()
        let userVidRef = ref.child("users").child(uid).child("videos").child(videoName)
          userVidRef.updateChildValues(values, withCompletionBlock: { (err, ref) in
        
              if err != nil {
                  print(err)
                  return
              }
              
              print("Video saved into database")
          })
        
        var insertion = Video()
        if let name = values["vidName"],
            let thumbnail = values["thumbnailURL"],
            let video = values["videoURL"]{
            insertion.name = name as? String
            insertion.thumbnail = thumbnail as? String
            insertion.video = video as? String
        }
        
        videos.insert(insertion, at: 0)
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
        
    }
    
    func generateThumbnail(url: URL, completion: @escaping ((_ image: Data?) -> Void)) {
        DispatchQueue.global().async {
            
            let asset = AVAsset(url: url)
            let imageGen = AVAssetImageGenerator(asset: asset)
            imageGen.appliesPreferredTrackTransform = true
            let thumbnailTime = CMTimeMake(value: 2, timescale: 1)
            do {
                let cgThumb = try imageGen.copyCGImage(at: thumbnailTime, actualTime: nil)
                let thumbImage = UIImage(cgImage: cgThumb)
                DispatchQueue.main.async {
                    completion(thumbImage.pngData())
                }
            } catch {
                print(error.localizedDescription)
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
    }





extension MainController: UINavigationControllerDelegate {
    
}
