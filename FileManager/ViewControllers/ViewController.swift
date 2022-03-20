import UIKit
import KeychainSwift


enum PresentationMode: String {
    case tableView
    case collectionView
    
    var imageName: String {
        switch self {
        case .tableView:
            return "stop.fill"
            
        case .collectionView:
            return "list.dash"
        }
    }
}

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    var url: URL?
    
    private var modeButton: UIBarButtonItem?
    
    private var fileSystemElements: [FileSystemElement] = []
    private var selectedElements: [FileSystemElement] = []
    
    private var isEditMode = false
    
    private var photoSelected = false
    
    private let keychain = KeychainSwift()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpTableView()
        setUpCollectionView()
        
        updateNavigationButtons()
        
        updateViewMode()
        updateFileSystemElements()
        
    }
    
    private func setUpTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.allowsMultipleSelection = true
        
        tableView.register(UINib(nibName: "DirectoryTableViewCell", bundle: nil),
                           forCellReuseIdentifier: DirectoryTableViewCell.id)
        tableView.register(UINib(nibName: "ImageTableViewCell", bundle: nil),
                           forCellReuseIdentifier: ImageTableViewCell.id)
    }
    
    private func setUpCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
//        collectionView.allowsMultipleSelection = true
        
        collectionView.register(UINib(nibName: "DirectoryCollectionViewCell", bundle: nil),
                                forCellWithReuseIdentifier: DirectoryCollectionViewCell.id)
        collectionView.register(UINib(nibName: "ImageCollectionViewCell", bundle: nil),
                                forCellWithReuseIdentifier: ImageCollectionViewCell.id)
    }
    
    @objc private func changeEditMode() {
        isEditMode.toggle()
        
        if !isEditMode {
            selectedElements.removeAll()
            
            tableView.reloadData()
            collectionView.reloadData()
        }
        
        updateNavigationButtons()
    }
    
    private func updateNavigationButtons() {
        if isEditMode {
            addEditModeRightButtons()
        }
        else {
            addNonEditModeRightButtons()
        }
    }
    
    private func addNonEditModeRightButtons() {
        let selectButton = UIBarButtonItem(title: "Select",
                                           style: .plain,
                                           target: self,
                                           action: #selector(changeEditMode))
        
        let plusButton = UIBarButtonItem(barButtonSystemItem: .add,
                                         target: self,
                                         action: #selector(handlePlusButtonTap))
        
        let modeButtonImage = UIImage(systemName: UserDefaultsManager.shared.presentationMode.imageName)
        let modeButton = UIBarButtonItem(image: modeButtonImage,
                                         style: .done,
                                         target: self,
                                         action: #selector(changeViewMode))
        self.modeButton = modeButton
        
        navigationItem.rightBarButtonItems = [plusButton, modeButton, selectButton]
    }
    
    private func addEditModeRightButtons() {
        let selectButton = UIBarButtonItem(title: "Cancel",
                                           style: .plain,
                                           target: self,
                                           action: #selector(changeEditMode))
        
        let deleteButton = UIBarButtonItem(barButtonSystemItem: .trash,
                                           target: self,
                                           action: #selector(deleteSelectedElements))
        
        navigationItem.rightBarButtonItems = [selectButton, deleteButton]
    }
    
    @objc private func handlePlusButtonTap() {
        let alert = UIAlertController(title: "Choose Action", message: nil, preferredStyle: .actionSheet)
        
        let createDirectoryAction = UIAlertAction(title: "Create Directory",
                                               style: .default) { [weak self] _ in
            self?.createDirectory()
        }
        let uploadImageAction = UIAlertAction(title: "Upload Image",
                                               style: .default) { [weak self] _ in
            self?.uploadImage()
        }
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .cancel,
                                         handler: nil)
        
        alert.addAction(createDirectoryAction)
        alert.addAction(uploadImageAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    @objc private func changeViewMode() {
        let selectedMode = UserDefaultsManager.shared.presentationMode
        
        let newMode: PresentationMode = selectedMode == .tableView ? .collectionView : .tableView
        UserDefaultsManager.shared.presentationMode = newMode
        
        modeButton?.image = UIImage(systemName: newMode.imageName)
        
        updateViewMode()
    }
    
    @objc private func deleteSelectedElements() {
        selectedElements.forEach { try? FileManager.default.removeItem(at: $0.url) }
        
        updateFileSystemElements()
        changeEditMode()
    }
    
    private func updateFileSystemElements() {
        guard let currentDirectory = url ?? FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            else { return }
        
        fileSystemElements.removeAll()
        
        try? FileManager.default.contentsOfDirectory(at: currentDirectory,
                                                     includingPropertiesForKeys: nil,
                                                     options: [])
            .forEach {
                let elementType: FileSystemElementType =
                    $0.lastPathComponent.contains(".jpeg") || $0.lastPathComponent.contains(".png") ? .image : .directory
                
                let fileSystemElement = FileSystemElement(type: elementType,
                                                          url: $0)
                
                fileSystemElements.append(fileSystemElement)
            }
        
        tableView.reloadData()
        collectionView.reloadData()
    }
    
    private func updateViewMode() {
        switch UserDefaultsManager.shared.presentationMode {
        case .tableView:
            tableView.isHidden = false
            collectionView.isHidden = true
            
        case .collectionView:
            tableView.isHidden = true
            collectionView.isHidden = false
        }
    }
    
    // MARK: Common functions
    
    private func handleItemSelect(indexPath: IndexPath) {
        let element = fileSystemElements[indexPath.row]
        
        guard !isEditMode else {
            handleItemSelect(element: element)
            
            return
        }
        
        switch element.type {
        case .directory:
            navigateToFolder(url: element.url)
            
        case .image:
            openImage(url: element.url)
        }
    }
    
    private func handleItemSelect(element: FileSystemElement) {
        if let index = selectedElements.firstIndex(of: element) {
            selectedElements.remove(at: index)
        }
        else {
            selectedElements.append(element)
        }
        
//        tableView.reloadData()
        collectionView.reloadData()
    }
    
    // MARK: Directory functions
    
    private func createDirectory() {
        let alert = UIAlertController(title: "Add Directory", message: nil, preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Directory Name"
        }
        
        let createDirectoryAction = UIAlertAction(title: "Create",
                                                  style: .default) { [weak self] _ in
            guard let directoryName = alert.textFields?.first?.text else { return }
            
            self?.createDirectory(name: directoryName)
            self?.updateFileSystemElements()
        }
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .cancel,
                                         handler: nil)
        
        alert.addAction(createDirectoryAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func createDirectory(name: String) {
        guard let folderParentDirectory = url ?? FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            else { return }
        
        let newDirectoryPath = folderParentDirectory.appendingPathComponent(name)
        
        try? FileManager.default.createDirectory(at: newDirectoryPath,
                                                 withIntermediateDirectories: false,
                                                 attributes: nil)
    }

    private func navigateToFolder(url: URL) {
        guard let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "ViewController") as? ViewController else { return }
        viewController.url = url
        
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    // MARK: Image functions
    
    private func uploadImage() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        
        imagePickerController.delegate = self
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    private func saveImage(_ image: UIImage, name: String) {
        guard let parentDirectory = url ?? FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            else { return }
        
        let newImagePath = parentDirectory.appendingPathComponent(name)
        
        try? image.jpegData(compressionQuality: 1.0)?.write(to: newImagePath)
        
        updateFileSystemElements()
    }
    
    private func openImage(url: URL) {
        guard let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "ImagePreviewVC") as? ImagePreviewViewController else { return }
        viewController.imagePath = url
        
        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let element = fileSystemElements[indexPath.row]
        
        switch element.type {
        case .directory:
            return 40
            
        case .image:
            return 80
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        handleItemSelect(indexPath: indexPath)
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        fileSystemElements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let element = fileSystemElements[indexPath.row]
        
        let cell: UITableViewCell
        switch element.type {
        case .directory:
            guard let directoryTableViewCell = tableView.dequeueReusableCell(withIdentifier: DirectoryTableViewCell.id,
                                                                             for: indexPath)
                as? DirectoryTableViewCell else { return UITableViewCell() }
            directoryTableViewCell.directoryName = element.url.lastPathComponent
            
            cell = directoryTableViewCell
            
        case .image:
            guard let imageTableViewCell = tableView.dequeueReusableCell(withIdentifier: ImageTableViewCell.id,
                                                                         for: indexPath)
                as? ImageTableViewCell else { return UITableViewCell() }
            imageTableViewCell.imagePath = element.url
            
            cell = imageTableViewCell
        }
        cell.setSelected(tableView.indexPathsForSelectedRows?.contains(indexPath) == true, animated: true)
        
        return cell
    }
}

// MARK: UIImagePickerControllerDelegate, UINavigationControllerDelegate

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard !photoSelected,
              let image = info[.originalImage] as? UIImage,
              let imageUrl = info[.imageURL] as? URL
        else { return }
        
        photoSelected = true
        saveImage(image, name: imageUrl.lastPathComponent)
        
        picker.dismiss(animated: true) {
            self.photoSelected = false
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20,
                            left: 0,
                            bottom: 0,
                            right: 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        handleItemSelect(indexPath: indexPath)
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        fileSystemElements.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let element = fileSystemElements[indexPath.row]

        let cell: UICollectionViewCell
        switch element.type {
        case .directory:
            guard let directoryCollectionViewCell = collectionView
                    .dequeueReusableCell(withReuseIdentifier: DirectoryCollectionViewCell.id,
                                         for: indexPath) as? DirectoryCollectionViewCell
                else { return UICollectionViewCell() }
            directoryCollectionViewCell.directoryName = element.url.lastPathComponent
            
            cell = directoryCollectionViewCell
            
        case .image:
            guard let imageCollectionViewCell = collectionView
                    .dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCell.id,
                                         for: indexPath) as? ImageCollectionViewCell
                else { return UICollectionViewCell() }

            imageCollectionViewCell.imagePath = element.url
            
            cell = imageCollectionViewCell
        }
        
        cell.isSelected = selectedElements.contains(where: { $0 == element })
        
        return cell
    }
    
}
