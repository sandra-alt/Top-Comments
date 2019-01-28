//
//  CommentCell.swift
//  TopComments
//
//  Created by  Oleksandra on 1/27/19.
//  Copyright © 2019 sandra-alt. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell {
    
    @IBOutlet weak var bgView: UIView!
    
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var commentLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        bgView.layer.borderWidth = 1.0
        bgView.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    func configureCellFor(comment: Comment) {
        idLabel.text = "\(comment.id)"
        nameLabel.text = "\(comment.name)".capitalized
        emailLabel.text = comment.email

        commentLabel.text = comment.body
    }
    
}
