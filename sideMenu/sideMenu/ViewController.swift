





import UIKit
class ViewController: UIViewController,FVTSideMenuDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        FVTSideMenu.delegate = self
    }
    override func viewDidAppear(_ animated: Bool) {
        showSideMenu()
    }
        FVTSideMenu.show()
    }
    func hideSideMenu(){
        FVTSideMenu.hide()
    }
    func didOpenSideMenu() {
        print("Sidemenu opened")
    }
    func didCloseSideMenu() {
        print("Sidemenu closed")
    }
    func didSelectSideMenuItem(item: SidemenuItem) {
        print("Sidemenu item selected with id \(item.id)")
    }
}

