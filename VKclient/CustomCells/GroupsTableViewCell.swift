//
//  GroupsTableViewCell.swift
//  VKclient
//
//  Created by Alexander Grigoryev on 16.01.2022.
//

import UIKit

class GroupsTableViewCell: UITableViewCell {
    

    @IBOutlet var avatarView: UIImageView!
    @IBOutlet var labelGroup: UILabel!
    static let reusedIdentifier = "myGroupsCells"

    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(groups: GroupsRealm) {
        let url = URL(string: groups.photo)
        avatarView.sd_setImage(with: url)
        labelGroup.text = groups.name
    }
    
}
