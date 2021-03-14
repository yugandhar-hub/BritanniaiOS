//
//  ReportViewController.swift
//  Britannia
//
//  Created by Admin on 16/02/21.
//

import UIKit



class ReportViewController: UIViewController, AddReportDelegate, DeleteReportDelegate {
    func reload() {
        let api = APIService()
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        api.connect(name: "Departments", parameters: [String](), completion: { (data,response) in
            do {
                let jsonData = try JSONSerialization.jsonObject(with: data!, options: []) as? [String:Any]
                self.arrDepartments = (jsonData?["departments"] as? [String])!
                DispatchQueue.main.async {
                    self.drDepartment.reloadData()
                }
                api.connect(name: "Reports", parameters: [self.arrDepartments[0]], completion: { (data1,response) in
                    do {
                        let jsonData1 = try JSONSerialization.jsonObject(with: data1!, options: [])
                        self.arrReportName = jsonData1 as! [Dictionary<String, Any>]
                        
                        DispatchQueue.main.async {
                            self.drReportName.reloadData()
                            self.activityIndicator.stopAnimating()
                            self.activityIndicator.isHidden = true
                        }
                    } catch let error {
                        print("Error",error)
                        self.activityIndicator.stopAnimating()
                        self.activityIndicator.isHidden = true
                    }
                })
                
            } catch let error {
                print("Error",error)
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
            }
        })
    }
    
    func reloadData() {
        let api = APIService()
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        api.connect(name: "Departments", parameters: [String](), completion: { (data,response) in
            do {
                let jsonData = try JSONSerialization.jsonObject(with: data!, options: []) as? [String:Any]
                self.arrDepartments = (jsonData?["departments"] as? [String])!
                DispatchQueue.main.async {
                    self.drDepartment.reloadData()
                }
                api.connect(name: "Reports", parameters: [self.arrDepartments[0]], completion: { (data1,response) in
                    do {
                        let jsonData1 = try JSONSerialization.jsonObject(with: data1!, options: [])
                        self.arrReportName = jsonData1 as! [Dictionary<String, Any>]
                        
                        DispatchQueue.main.async {
                            self.drReportName.reloadData()
                            self.activityIndicator.stopAnimating()
                            self.activityIndicator.isHidden = true
                        }
                    } catch let error {
                        print("Error",error)
                        self.activityIndicator.stopAnimating()
                        self.activityIndicator.isHidden = true
                    }
                })
                
            } catch let error {
                print("Error",error)
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
            }
        })
    }
    

    @IBOutlet weak var drDepartment: DropDown!
    @IBOutlet weak var drReportName: DropDown!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var arrDepartments = [String]()
    var arrReportName = [Dictionary<String,Any>]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let logoItem = self.navigationItem.leftBarButtonItems![1]
        logoItem.image = UIImage(named: "CompanyLogo")?.withRenderingMode(.alwaysOriginal)
        
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer());
        if let reveal = self.revealViewController() {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(reveal.panGestureRecognizer())
        }
        self.drDepartment.delegate = self
        self.drReportName.delegate = self
        let api = APIService()
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        api.connect(name: "Departments", parameters: [String](), completion: { (data,response) in
            do {
                let jsonData = try JSONSerialization.jsonObject(with: data!, options: []) as? [String:Any]
                self.arrDepartments = (jsonData?["departments"] as? [String])!
                DispatchQueue.main.async {
                    self.drDepartment.reloadData()
                }
                api.connect(name: "Reports", parameters: [self.arrDepartments[0]], completion: { (data1,response) in
                    do {
                        let jsonData1 = try JSONSerialization.jsonObject(with: data1!, options: [])
                        self.arrReportName = jsonData1 as! [Dictionary<String, Any>]
                        
                        DispatchQueue.main.async {
                            self.drReportName.reloadData()
                            self.activityIndicator.stopAnimating()
                            self.activityIndicator.isHidden = true
                        }
                    } catch let error {
                        print("Error",error)
                        self.activityIndicator.stopAnimating()
                        self.activityIndicator.isHidden = true
                    }
                })
                
            } catch let error {
                print("Error",error)
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
            }
        })
    }
    
    @IBAction func btnDeleteReportAction(_ sender: Any) {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DeleteReportViewController") as? DeleteReportViewController
        controller?.arrReportName = arrReportName
        controller?.delegate = self
        self.present(controller!, animated: true, completion: nil)
    }
    
    @IBAction func btnGetReportAction(_ sender: Any) {
        if let id = drReportName.getSelectedId() {
            let controller = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ReportWebViewController") as! ReportWebViewController
            if let delegate = UIApplication.shared.delegate as? AppDelegate {
                controller.webView = delegate.webView
            }
            controller.urlString = arrReportName[Int(id)!]["report_url"]! as! String
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    @IBAction func btnAddAction(_ sender: Any) {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddReportViewController") as! AddReportViewController
        controller.delegate = self
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
}

extension ReportViewController: DropDownDelegate {
    func dropDown(_ dropDown: DropDown!, dataForSection section: Int) -> [Any]! {
        if dropDown == drDepartment {
            let arr = NSMutableArray()
            for index in 0..<arrDepartments.count {
                let dict = NSMutableDictionary.init(dictionaryLiteral:("field_id","\(index)"),("field_name", arrDepartments[index]))
                arr.add(dict)
            }
            print("arr",arr)
            return arr as? [Any]
        } else if dropDown == drReportName {
            let arr = NSMutableArray()
            for index in 0..<arrReportName.count {
                let dict = NSMutableDictionary.init(dictionaryLiteral:("field_id","\(index)"),("field_name", arrReportName[index]["report_name"]!))
                arr.add(dict)
            }
            print("arr",arr)
            return arr as? [Any]
        } else {
            let arr = NSMutableArray()
            print("arr",arr)
            return arr as? [Any]
        }
    }
    
    func dropDown(_ dropDown: DropDown!, didSelectRowAt indexPath: IndexPath!, selectedId: String!, andName name: String!) {
        if dropDown == drDepartment {
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
            APIService().connect(name: "Reports", parameters: [self.arrDepartments[indexPath.row]], completion: { (data1,response) in
                do {
                    let jsonData1 = try JSONSerialization.jsonObject(with: data1!, options: [])
                    self.arrReportName = jsonData1 as! [Dictionary<String, Any>]
                    
                    DispatchQueue.main.async {
                        self.drReportName.reloadData()
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
    }
}

