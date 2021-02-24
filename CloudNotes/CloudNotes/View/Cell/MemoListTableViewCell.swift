import UIKit

class MemoListTableViewCell: UITableViewCell {
    let listTitleLabel: UILabel = makeLabel(textStyle: .body)
    let listShortBodyLabel: UILabel = makeLabel(textStyle: .body, textColor: .gray)
    let listLastModifiedDateLabel: UILabel = makeLabel(textStyle: .caption2)
    let contentsContainerView = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.accessoryType = .disclosureIndicator
        
        configureContentsContainerView()
        configureAutoLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class private func makeLabel(textStyle: UIFont.TextStyle, textColor: UIColor = .black) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontForContentSizeCategory = true
        label.font = .preferredFont(forTextStyle: textStyle)
        label.textColor = textColor
        return label
    }

    private func configureContentsContainerView() {
        contentsContainerView.translatesAutoresizingMaskIntoConstraints = false
        contentsContainerView.addSubview(listTitleLabel)
        contentsContainerView.addSubview(listShortBodyLabel)
        contentsContainerView.addSubview(listLastModifiedDateLabel)
        contentView.addSubview(contentsContainerView)
    }
    
    private func configureAutoLayout() {
        NSLayoutConstraint.activate([
            contentsContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            contentsContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            contentsContainerView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            contentsContainerView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.9),
            
            listTitleLabel.leadingAnchor.constraint(equalTo: contentsContainerView.leadingAnchor),
            listTitleLabel.trailingAnchor.constraint(equalTo: contentsContainerView.trailingAnchor),
            listTitleLabel.topAnchor.constraint(equalTo: contentsContainerView.topAnchor),
            
            listLastModifiedDateLabel.leadingAnchor.constraint(equalTo: listTitleLabel.leadingAnchor),
            listLastModifiedDateLabel.topAnchor.constraint(equalTo: listTitleLabel.bottomAnchor),
            listLastModifiedDateLabel.bottomAnchor.constraint(equalTo: contentsContainerView.bottomAnchor),
            
            listShortBodyLabel.leadingAnchor.constraint(greaterThanOrEqualTo: listLastModifiedDateLabel.trailingAnchor, constant: 40),
            listShortBodyLabel.trailingAnchor.constraint(equalTo: contentsContainerView.trailingAnchor),
            listShortBodyLabel.bottomAnchor.constraint(equalTo: contentsContainerView.bottomAnchor),
            listShortBodyLabel.topAnchor.constraint(equalTo: listTitleLabel.bottomAnchor)
        ])
    }
    
//    func receiveLabelsText(memo: Memo) {
//        listTitleLabel.text = memo.title
//        listShortBodyLabel.text = memo.body
//        listLastModifiedDateLabel.text = memo.lastModifiedDateString
//    }
}
