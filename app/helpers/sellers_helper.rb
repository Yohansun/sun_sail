module SellersHelper
  def find_parent(leave)
    tds = [leave]
    if leave.parent.present?
      tds.insert(0, find_parent(leave.parent))
    end
    tds.flatten
  end
end
