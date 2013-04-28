require 'magic_search/search'
module MagicSearch
  
  DEFALUT_WHERE = {
    "_like"   => {:to => "$regex"     ,:alias => "_contains" ,:convert => proc {|v| %r/#{v}/ } },    
    "_eq"     => {:to => ""           ,:alias => "_equals"                },
    "_gt"     => {:to => "$gt"        ,:alias => "_greater_than"          },
    "_gte"    => {:to => "$gte"       ,:alias => "_greater_than_or_equal" },
    "_lt"     => {:to => "$lt"        ,:alias => "_less_than"             },
    "_lte"    => {:to => "$lte"       ,:alias => "_less_than_or_equal"    },
    "_not_eq" => {:to => "$ne"        ,:alias => "_does_not_equal"        },
    "_in"     => {:to => "$in"        ,:alias => "_in"          ,:convert => proc {|v| v.is_a?(Array) ? v : v.to_s.split(',') }                    },
    "_nu"     => {:to => "$exists"    ,:alias => "_is_not_null" ,:convert => proc {|v| !["false",0,"0","",false,nil].include?(v) } }
  }
end