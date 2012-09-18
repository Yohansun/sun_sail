json.array!(@sellers) do |json, seller|
  json.id               seller.id
  json.name             seller.name
  json.fullname         seller.fullname
  json.address          seller.address
  json.mobile           seller.mobile
  json.created_at       seller.created_at
  json.updated_at       seller.updated_at
  json.parent_id        seller.parent_id
  json.lft              seller.lft
  json.rgt              seller.rgt
  json.children_count   seller.children_count
  json.email            seller.email
  json.active           seller.active
  json.has_stock        seller.has_stock
end