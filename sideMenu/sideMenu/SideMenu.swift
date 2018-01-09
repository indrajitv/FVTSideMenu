

import UIKit

fileprivate let sideMenuColor = UIColor.black
fileprivate let titleColorNormal = UIColor.red
fileprivate let titleColorSelected = UIColor.blue

enum position {
    case rightToLeft
    case leftToRight
}

@objc protocol FVTSideMenuDelegate:class{
    @objc optional func didOpenSideMenu()
    @objc optional func didCloseSideMenu()
    @objc optional func didSelectSideMenuItem(item:SidemenuItem)
    
}

class FVTSideMenu:UIView,UIGestureRecognizerDelegate{
    
    static let shared = FVTSideMenu()
    static var openingPosition:position = .rightToLeft
    static var xPositionOfContainerView:NSLayoutConstraint?
    static let widthOfContainer = UIScreen.main.bounds.width / 1.8 // visible part of side menu
   
    static var delegate:FVTSideMenuDelegate?
    
    static func setSelectedItem(index:Int){
        ViewToShowOnSideMenu.selectedCell = index
    }
    
    static var disablerView:UIView={ // disables user interaction below the size menu
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let tap = UITapGestureRecognizer(target: FVTSideMenu.self, action:#selector(hide))
        tap.delegate = shared
        view.addGestureRecognizer(tap)
        
        let swip = UISwipeGestureRecognizer(target: FVTSideMenu.self, action: #selector(hide))
        swip.delegate = shared
        swip.direction = openingPosition == .rightToLeft ? .right : .left
        view.addGestureRecognizer(swip)
        
        return view
    }()
    
    
    static let viewToShowOnSideMenu = ViewToShowOnSideMenu()
    
    static var containerView:UIView={ // Container view which contains every object of the side menu such as collection view
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = sideMenuColor
        
        view.addSubview(viewToShowOnSideMenu)
        viewToShowOnSideMenu.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        viewToShowOnSideMenu.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        viewToShowOnSideMenu.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        viewToShowOnSideMenu.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        
        return view
    }()
    
    
    static func show(){
        
        
        if let app = UIApplication.shared.delegate as? AppDelegate , let keyWindow = app.window{ // Application winow which can be acces from anywhere
            
            disablerView.backgroundColor = UIColor.init(white: 0, alpha: 0) // Always will be clear to show animation
            
            keyWindow.addSubview(disablerView)
            
            
            disablerView.topAnchor.constraint(equalTo: keyWindow.topAnchor, constant: 0).isActive = true
            disablerView.bottomAnchor.constraint(equalTo: keyWindow.bottomAnchor, constant: 0).isActive = true
            disablerView.leftAnchor.constraint(equalTo: keyWindow.leftAnchor, constant: 0).isActive = true
            disablerView.rightAnchor.constraint(equalTo: keyWindow.rightAnchor, constant: 0).isActive = true
            
            if !disablerView.subviews.contains(containerView){
                
                disablerView.addSubview(containerView)
                containerView.topAnchor.constraint(equalTo: disablerView.topAnchor, constant: 0).isActive = true
                containerView.bottomAnchor.constraint(equalTo: disablerView.bottomAnchor, constant: 0).isActive = true
                containerView.widthAnchor.constraint(equalToConstant: widthOfContainer).isActive = true
                
                if xPositionOfContainerView == nil{
                    if openingPosition == .rightToLeft{
                        xPositionOfContainerView = containerView.leftAnchor.constraint(equalTo: disablerView.rightAnchor, constant: 0)
                    }else{
                        xPositionOfContainerView = containerView.rightAnchor.constraint(equalTo: disablerView.leftAnchor, constant: 0)
                    }
                    disablerView.addConstraint(xPositionOfContainerView!)
                }
                
                
            }
            
            keyWindow.layoutIfNeeded()
            xPositionOfContainerView?.constant = openingPosition == .rightToLeft ? -widthOfContainer : widthOfContainer
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                disablerView.backgroundColor = UIColor.init(white: 0.2, alpha: 0.9)
                keyWindow.layoutIfNeeded()
                
            }, completion: { (bool) in
                
                FVTSideMenu.delegate?.didOpenSideMenu!()
            })
            
            
            
            
        }
    }
    
    @objc static func hide(){
        
        
        xPositionOfContainerView?.constant = 0
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            disablerView.backgroundColor = UIColor.init(white: 0, alpha: 0)
            if let app = UIApplication.shared.delegate as? AppDelegate , let keyWindow = app.window{
                keyWindow.layoutIfNeeded()
            }
            
        }, completion: { (bool) in
            
            disablerView.removeFromSuperview() // removing to from keyWindow
             FVTSideMenu.delegate?.didCloseSideMenu!()
        })
    }
    
    
    //MARK: Gesture delegates
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view == FVTSideMenu.disablerView ? true : false
    }
    
    
}


class ViewToShowOnSideMenu:UIView,UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    var titleDataSouce = [SidemenuItem]() // must be eqaul to imageViewDataSource ,if has imagemode true
    let intialSpacing:CGFloat = 50
    static var selectedCell = 0{
        didSet{
            FVTSideMenu.viewToShowOnSideMenu.listingCollectionView.reloadData()
        }
    }
    
    let cellId = "cellId"
    lazy var listingCollectionView:UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.showsHorizontalScrollIndicator = false
        cv.showsVerticalScrollIndicator = false
        cv.bounces = true
        cv.backgroundColor = .clear
        cv.register(CellForSideMenu.self, forCellWithReuseIdentifier: self.cellId)
        cv.delegate = self
        cv.dataSource = self
        return cv
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .clear
        
        let home = SidemenuItem()
        home.title = "HOME"
        home.id = "home"
        home.image = #imageLiteral(resourceName: "home")
        home.colorOfImage = .red
        home.sizeOfImage = 25
        titleDataSouce.append(home)
        
        let profile = SidemenuItem()
        profile.title = "PROFILE"
        profile.id = "profile"
        profile.image = #imageLiteral(resourceName: "profile")
        profile.colorOfImage = .red
        profile.sizeOfImage = 25
        titleDataSouce.append(profile)
        
        let msg = SidemenuItem()
        msg.title = "MESSAGES"
        msg.id = "msg"
        msg.image = #imageLiteral(resourceName: "message")
        msg.colorOfImage = .red
        msg.sizeOfImage = 25
        titleDataSouce.append(msg)
        
        
        let group = SidemenuItem()
        group.title = "GROUP"
        group.id = "group"
        group.image = #imageLiteral(resourceName: "group")
        group.colorOfImage = .red
        group.sizeOfImage = 25
        titleDataSouce.append(group)
        
        let settings = SidemenuItem()
        settings.title = "SETTINGS"
        settings.id = "settings"
        settings.image = #imageLiteral(resourceName: "settings")
        settings.colorOfImage = .red
        settings.sizeOfImage = 25
        titleDataSouce.append(settings)
        
        
        let logout = SidemenuItem()
        logout.title = "LOGOUT"
        logout.id = "logout"
        logout.image = #imageLiteral(resourceName: "logout")
        logout.colorOfImage = .red
        logout.sizeOfImage = 25
        titleDataSouce.append(logout)
        
        
        self.addSubview(listingCollectionView)
        listingCollectionView.topAnchor.constraint(equalTo: self.topAnchor, constant: intialSpacing).isActive = true
        listingCollectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        listingCollectionView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0).isActive = true
        listingCollectionView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0).isActive = true
        
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    //MARK: CollectionView Delegates
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int  {
        return titleDataSouce.count
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: self.frame.width, height: 30)
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellId, for: indexPath) as! CellForSideMenu
        cell.cellAttributes = titleDataSouce[indexPath.item]
        if ViewToShowOnSideMenu.selectedCell == indexPath.row {
            cell.textLabel.textColor = titleColorSelected
            cell.textLabel.font = UIFont.boldSystemFont(ofSize: 16)
        }else{
            cell.textLabel.textColor = titleColorNormal
            cell.textLabel.font = UIFont.systemFont(ofSize: 16)
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        FVTSideMenu.hide()
        let selectedModel = titleDataSouce[indexPath.item]
        FVTSideMenu.delegate?.didSelectSideMenuItem!(item: selectedModel)
        
        if ViewToShowOnSideMenu.selectedCell == indexPath.item{
            return
        }
        
        
        
        ViewToShowOnSideMenu.selectedCell = indexPath.item
    }
}


class CellForSideMenu:UICollectionViewCell{
    var widthOfImage:NSLayoutConstraint!
    var heightOfImage:NSLayoutConstraint!
    var cellAttributes:SidemenuItem?{
        didSet{
            
            if let title = cellAttributes?.title{
                self.textLabel.text = title
            }else{
                self.textLabel.text = "Unknown"
            }
            
            if let image = cellAttributes?.image{
                
                if let size = cellAttributes?.sizeOfImage{
                    widthOfImage.constant = size
                    heightOfImage.constant = size
                }else{
                    widthOfImage.constant = frame.height
                    heightOfImage.constant = frame.height
                }
                
                if let colorOfImage = cellAttributes?.colorOfImage{
                    self.imageView.tintColor = colorOfImage
                    self.imageView.image = image.withRenderingMode(.alwaysTemplate)
                }else{
                    self.imageView.tintColor = nil
                    self.imageView.image = image
                }
                
                
                
            }else{
                self.imageView.image = nil
                widthOfImage.constant = 0
            }
            
            
           
            
        }
    }
    let textLabel:UILabel={
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = titleColorNormal
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    let imageView:UIImageView={
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints  = false
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.addSubview(textLabel)
        self.addSubview(imageView)
        widthOfImage = self.imageView.widthAnchor.constraint(equalToConstant: frame.height)
        heightOfImage = self.imageView.heightAnchor.constraint(equalToConstant: frame.height)
        self.addConstraints([widthOfImage,heightOfImage])
        self.imageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 5).isActive = true
        self.imageView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0).isActive = true
        textLabel.leftAnchor.constraint(equalTo: self.imageView.rightAnchor, constant: 5).isActive = true
        textLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        textLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        textLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 10).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class SidemenuItem:NSObject{
    var title:String?
    var id:String?
    var image:UIImage?
    var sizeOfImage:CGFloat?
    var colorOfImage:UIColor?
}




















