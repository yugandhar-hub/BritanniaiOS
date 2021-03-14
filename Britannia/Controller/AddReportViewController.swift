//
//  AddReportViewController.swift
//  Britannia
//
//  Created by Admin on 20/02/21.
//

import UIKit

protocol AddReportDelegate: AnyObject {
    func reload()
}

class AddReportViewController: UIViewController {

    @IBOutlet weak var drDepartments: DropDown!
    @IBOutlet weak var txtReportName: UITextField!
    @IBOutlet weak var txtWebURL: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var delegate:AddReportDelegate?
    
    var arrDepartments = [String]()
    var arrReportAndURL = [Dictionary<String,Any>]()
    var longestWidth:CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.estimatedItemSize = CGSize(width: 100, height: 100)
        collectionView.collectionViewLayout = layout
        
        
        collectionView.dataSource = self
        self.drDepartments.delegate = self
        txtReportName.delegate = self
        txtWebURL.delegate = self
        activityIndicator.startAnimating()
        APIService().connect(name: "Departments", parameters: [String](), completion: { (data,response) in
            do {
                let jsonData = try JSONSerialization.jsonObject(with: data!, options: []) as? [String:Any]
                self.arrDepartments = (jsonData?["departments"] as? [String])!
                DispatchQueue.main.async {
                    self.drDepartments.reloadData()
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                }
                
            } catch let error {
                print("Error",error)
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
            }
        })
    }
    

    @IBAction func btnAddURLAction(_ sender: Any) {
        if verifyUrl(urlString: txtWebURL.text) && !txtReportName.text!.isEmpty {
            let dict = Dictionary(dictionaryLiteral: ("report_name",txtReportName.text!),("report_url",txtWebURL.text!))
            arrReportAndURL.append(dict as [String : Any])
            let indexPath = IndexPath(item: arrReportAndURL.count - 1, section: 0)
            collectionView.insertItems(at: [indexPath])
            collectionView.scrollToItem(at: indexPath, at: .right, animated: true)
            txtReportName.text = ""
            txtWebURL.text = ""
        } else if !verifyUrl(urlString: txtWebURL.text) && txtReportName.text!.isEmpty {
            let alert = UIAlertController(title: "Alert", message: "Report Name is empty and Web URL is not valid", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else if txtReportName.text!.isEmpty {
            let alert = UIAlertController(title: "Alert", message: "Report Name is empty", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Alert", message: "Web URL is not valid", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnAddReportAction(_ sender: Any) {
        APIService().connect(name: "ReportsAdd", parameters: [drDepartments.getSelectedName()!,self.arrReportAndURL] , completion: { (data,response) in
            if response?.statusCode == 200 || response?.statusCode == 201 {
                DispatchQueue.main.async {
                    self.delegate?.reload()
                    self.txtReportName.resignFirstResponder()
                    self.txtWebURL.resignFirstResponder()
                    self.showToast(message: "Report added successfully", font: .boldSystemFont(ofSize: 14))
                    DispatchQueue.main.asyncAfter(deadline: .now()
                                                    + 2.0 , execute: {
                                                        self.navigationController?.popViewController(animated: true)
                                                    })
                }
            }
        })
    }
    
    func verifyUrl (urlString: String?) -> Bool {
       if let urlString = urlString {
           if let url = NSURL(string: urlString) {
               return UIApplication.shared.canOpenURL(url as URL)
           }
       }
       return false
   }
}

extension AddReportViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrReportAndURL.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellID", for: indexPath) as! ReportCollectionViewCell
        cell.lblNameAndURL.text = "\(arrReportAndURL[indexPath.item]["report_name"] as! String)\n\(arrReportAndURL[indexPath.item]["report_url"] as! String)"
        cell.lblNameAndURL.sizeToFit()
        return cell
    }
}

extension AddReportViewController: DropDownDelegate {
    func dropDown(_ dropDown: DropDown!, dataForSection section: Int) -> [Any]! {
        let arr = NSMutableArray()
        for index in 0..<arrDepartments.count {
            let dict = NSMutableDictionary.init(dictionaryLiteral:("field_id","\(index)"),("field_name", arrDepartments[index]))
            arr.add(dict)
        }
        print("arr",arr)
        return arr as? [Any]
    }
    
    
}

extension AddReportViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}

class ReportCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var lblNameAndURL: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}

extension UIViewController {
    
    func showToast(message : String, font: UIFont) {
        
        let toastLabel = UILabel(frame: CGRect(x: 16, y: self.view.frame.size.height - 60, width: self.view.frame.size.width - 32, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.font = font
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}
