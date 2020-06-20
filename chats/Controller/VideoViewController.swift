//
//  HomeViewController.swift
//  chats
//
//  Created by Andy Fang on 6/4/20.
//  Copyright © 2020 Andy Fang. All rights reserved.
//

import UIKit


class VideoViewController: UIViewController, UINavigationControllerDelegate {

    let canvas = Canvas()
    
    var canvasHidden: Bool = true
    
    var tools: UIStackView?
    
    var gradientSlider: GradientSlider = {
        
        
        
        let slider = GradientSlider()
        
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.thumbTintColor = UIColor(hue: CGFloat(Float64(slider.value)), saturation: 1, brightness: 1, alpha: 1)
        slider.minimumTrackTintColor = slider.thumbTintColor
        slider.maximumTrackTintColor = .white
        slider.addTarget(self, action: #selector(handleColor), for: .valueChanged)
        slider.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.size.width * 0.5).isActive = true
        
        return slider
    }()
    
    
    @objc func handleColor() {
        gradientSlider.thumbTintColor = UIColor(hue: CGFloat(Float64(gradientSlider.value) * 0.75), saturation: 1, brightness: 1, alpha: 1)
        gradientSlider.minimumTrackTintColor = gradientSlider.thumbTintColor
        canvas.setColor(color: gradientSlider.thumbTintColor!.cgColor)
    }
    
    let undoButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(named: "undo")?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.imageView?.contentMode = .scaleAspectFit
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 30).isActive = true
        button.widthAnchor.constraint(equalToConstant: 30).isActive = true
        button.addTarget(self, action: #selector(handleUndo), for: .touchUpInside)
        return button
    }()
    
    @objc func handleUndo() {
        canvas.undo()
    }
    
    
    let clearButton: UIButton = {
           let button = UIButton(type: .system)
            let image = UIImage(named: "broom")?.withRenderingMode(.alwaysTemplate)
            button.setImage(image, for: .normal)
            button.tintColor = .white
            button.imageView?.contentMode = .scaleAspectFit
            button.imageView?.tintColor = .white
            button.translatesAutoresizingMaskIntoConstraints = false
            button.heightAnchor.constraint(equalToConstant: 30).isActive = true
            button.widthAnchor.constraint(equalToConstant: 30).isActive = true
        button.addTarget(self, action: #selector(handleClear), for: .touchUpInside)
           return button
       }()
    
    @objc func handleClear() {
        canvas.clear()
    }
    
    let compareButton: UIButton = {
        let button = UIButton(type: .system)
         let image = UIImage(named: "compare")?.withRenderingMode(.alwaysTemplate)
         button.setImage(image, for: .normal)
         button.tintColor = .white
         button.imageView?.contentMode = .scaleAspectFit
         button.imageView?.tintColor = .white
         button.translatesAutoresizingMaskIntoConstraints = false
         button.heightAnchor.constraint(equalToConstant: 30).isActive = true
         button.widthAnchor.constraint(equalToConstant: 30).isActive = true
     button.addTarget(self, action: #selector(handleCompare), for: .touchUpInside)
        return button
    }()
    
    @objc func handleCompare() {
        let navController = UINavigationController(rootViewController: self)
        present(navController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let url = self.urlString,
            let name = vidName{

            
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(handleEdit))
            
            
            let bounds = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
            let videoView = VideoPlayerView(frame: bounds, urlString: url)
            view.addSubview(videoView)

            tools = UIStackView(arrangedSubviews: [
                self.undoButton,
                self.clearButton,
                self.compareButton,
                self.gradientSlider
            ])
            
            tools?.translatesAutoresizingMaskIntoConstraints = false
            tools?.distribution = .equalSpacing
            tools?.spacing = UIStackView.spacingUseSystem
            tools?.isLayoutMarginsRelativeArrangement = true
            tools?.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
            tools?.isHidden = canvasHidden
            
            view.addSubview(tools!)
            tools?.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8).isActive = true
            tools?.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
            tools?.bottomAnchor.constraint(equalTo: videoView.bottomAnchor, constant: -45).isActive = true
            tools?.heightAnchor.constraint(equalToConstant: 38).isActive = true
            
            
            view.addSubview(canvas)
            canvas.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0)
            canvas.translatesAutoresizingMaskIntoConstraints = false
            canvas.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            canvas.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
            canvas.bottomAnchor.constraint(equalTo: tools!.topAnchor).isActive = true
            canvas.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            canvas.isHidden = canvasHidden
        }
        
        

        // Do any additional setup after loading the view.
    }
    
    @objc func handleCancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func handleEdit(videoView: VideoPlayerView) {
        print("EDITING")
        canvas.isHidden = !canvasHidden
        tools?.isHidden = !canvasHidden
        
        if canvasHidden {
            canvas.clear()
        }
        canvasHidden = !canvasHidden
    }
    
    var urlString: String?
    var vidName: String?
    
    init(urlString: String, vidName: String) {
        super.init(nibName: nil, bundle: nil)
        self.urlString = urlString
        self.vidName = vidName
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
}


