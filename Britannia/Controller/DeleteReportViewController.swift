//
//  DeleteReportViewController.swift
//  Britannia
//
//  Created by Admin on 21/02/21.
//

import UIKit

protocol DeleteReportDelegate: AnyObject {
    func reloadData()
}
class DeleteReportViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tblReports: UITableView!
    
    var arrReportName = [Dictionary<String,Any>]()
    var arrFilteredReport = [Dictionary<String,Any>]()
    var arrSelectedReportIndex = [IndexPath]()
    
    var delegate:DeleteReportDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        arrFilteredReport = arrReportName
        tblReports.dataSource = self
        tblReports.delegate = self
        tblReports.reloadData()
        
    }
    
    @IBAction func btnDeleteReportAction(_ sender: Any) {
        if arrSelectedReportIndex.count > 0 {
            let alert = UIAlertController(title: "CONFIRM!", message: "Are you sure you want to delete the reports selected?", preferredStyle: .actionSheet)
            
            alert.addAction(UIAlertAction(title: "YES", style: .default, handler: { (_) in
                var arrIDs = [Int]()
                for index in 0..<self.arrReportName.count {
                    let dict = self.arrReportName[index]
                    if self.arrSelectedReportIndex.contains(IndexPath(row: index, section: 0)) {
                        arrIDs.append(dict["id"] as! Int)
                    }
                }
                APIService().connect(name: "DeleteReports", parameters: arrIDs, completion: {
                    (data,response) in
                    if response?.statusCode == 200 || response?.statusCode == 201 {
                        DispatchQueue.main.async {
                            self.delegate?.reload()
                            self.showToast(message: "Report deleted successfully", font: .boldSystemFont(ofSize: 14))
                            DispatchQueue.main.asyncAfter(deadline: .now()
                                                            + 2.0 , execute: {
                                                                self.dismiss(animated: true, completion: nil)
                                                            })
                        }
                    }
                })
            }))
            
            alert.addAction(UIAlertAction(title: "NO", style: .cancel, handler: { (_) in
                
            }))
            
            self.present(alert, animated: true, completion: {
                
            })
        } else {
            let alert = UIAlertController(title: "Alert", message: "Select atleast one report to delete", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnCancelAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension DeleteReportViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return arrFilteredReport.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellID", for: indexPath) as! ReportTableViewCell
        if arrSelectedReportIndex.contains(indexPath) {
            cell.checkBox.image = UIImage(systemName: "checkmark.square.fill")
        } else {
            cell.checkBox.image = UIImage(named: "emptyBox")
        }
        cell.lblReportName.text = arrFilteredReport[indexPath.row]["report_name"]! as? String
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if arrSelectedReportIndex.contains(indexPath) {
            let index = arrSelectedReportIndex.firstIndex(of: indexPath)
            arrSelectedReportIndex.remove(at: index!)
        } else {
            arrSelectedReportIndex.append(indexPath)
        }
        tableView.reloadRows(at: [indexPath], with: .automatic)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension DeleteReportViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        arrFilteredReport.removeAll()
        if searchText.isEmpty {
            arrFilteredReport = arrReportName
        }
        for dict in arrReportName {
            if (dict["report_name"] as! String).contains(searchText) {
                arrFilteredReport.append(dict)
            }
        }
        tblReports.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
}

class ReportTableViewCell: UITableViewCell {
    
    @IBOutlet weak var checkBox: UIImageView!
    @IBOutlet weak var lblReportName: UILabel!
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
}
