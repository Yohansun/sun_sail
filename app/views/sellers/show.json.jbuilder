json.id                 @seller.id
json.name               @seller.name
json.fullname 	        @seller.fullname
json.mobile             @seller.mobile
json.address            @seller.address
json.email              @seller.email
json.performance_score  @seller.performance_score
json.interface          @seller.interface

json.self_and_descendants @seller.self_and_descendants do |json, child|
  json.id               child.id
  json.fullname         child.fullname
  json.level            child.level
end