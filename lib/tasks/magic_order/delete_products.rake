#encoding: utf-8
desc "删除本地达利账户下的无用商品"
namespace :magic_order do
  task :delete_products => :environment do
    Product.where("account_id = 26 and outer_id not in (?)",frozen_product_outer_ids).map(&:destroy)
  end
end

def frozen_product_outer_ids
  %w(
  TK9WJ4WD01
  TK9WJ3WP01
  TK9WJ1WC02
  TK9WJ1WC01
  TK9WF8WT02
  TK9WF8WT01
  TK9WF6WK01
  TK9WF6WB01
  TK9W05WP01
  TK9K65KJ02
  TK9K65KJ01
  TK8WH8WD03
  TH6WH0WB01
  TH6WB9WJ02
  TH6WB9WC01
  TH6K74KD01
  TF6WX2WB01
  TF6WB5WB01
  TF6WB4WJ01
  TF6WA8WK02
  TF6S16SD01
  TF6S15SE01
  TF6K59KD01
  TEUW46WJ02
  TEUW46WC03
  TEUW01WP04
  TEUW01WP03
  TEUK16KE02
  TE2WE7WJ02
  TE2WE7WC01
  TE2WE6WC02
  TE2S04SE03
  TE2S04SE01
  TDUWH3QC01
  TDUWF1WC03
  TDRS57SB01
  TD9W69WK21
  TD9W69WC20
  TD9K09KE21
  TD2WM9WH03
  TD2WM9WC01
  TD2WE7WC02
  TD2WA2WC01
  TD2K67KJ02
  TD2K67KC03
  TD1WK8WD02
  TD1S03SD02
  TD1K28KE01
  TCYWK7WD04
  TCUWC7WH03
  TCUWA7WC03
  TCUWA7WC02
  TCUS09SE02
  TCUS09SE01
  TCAWY0WT20
  TCAW94WK20
  TCAW58WT20
  TCAW32WJ20
  TC9W81WK21
  TC9W33WP20
  TC2WL1DC02
  TC2WJ9DC01
  TC2WJ2WC02
  TC2WF1WC01
  TC2S01SE01
  TC2K67KH01
  TC2K58KJ01
  TC2K58KC02
  TC2K50KJ01
  TC1WM9DJ01
  TC1W68WC02
  TC1W68WC01
  TBWWF9WB01
  TBWWC9WC01
  TBUWH1QC01
  TBUWG9DC01
  TBUWG4DC01
  TBAW58WT21
  TBAK07KE20
  TBAK03KG20
  TB9W79WH21
  TB9W65WT20
  TB3S02SE03
  TB3K55KB02
  TB3K55KB01
  TB2WK0DJ02
  TB2WJ9DJ01
  TB2WC5WC01
  TB2S04SE01
  TAYWD1WB01
  TAWWF9WC03
  TAAW95WH21
  TAAW82WC20
  TA5S15SE01
  TA3WB8WJ02
  TA3WA8WJ03
  TA3WA8WC02
  TA3WA8WC01
  TA3WA6WB02
  TA3WA6WB01
  TA3S04SE02
  TA3S03SE02
  TA3S03SE01
  TA3S02SB01
  TA3K59KB01
  TA2WJ6DJ01
  TA2WH5WD01
  TA2WG0WC01
  TA2S02SD01
  TA2K73KG02
  TA2K08KE01
  TA2K08KD02
  TA1S03SB01
  T69W86WD20
  T69K15KD20
  T2WWC3WD03
  T2WW16WB01
  T29W33WB20
  T22WH6WB01
  T22W45WK04
  T22W45WB05
  T22W45WB01
  T1WW96WB01
  T1WW17WB06
  T1AWY7WP21
  T1AWY7WK22
  T1AWY7WB20
  T1AW29WT20
  T1AW28WT21
  T1AW25WP21
  T1AW25WB20
  T13WA2WB02
  T13WA2WB01
  T13WA0WB02
  T13WA0WB01
  T12WG6WB01
  CKAWD8WC01
  CKAWB6WJ02
  CKAWB6WD03
  CKAWB3WD01
  CKAWA9WC02
  CKAS11SE01
  CKAKA8KD01
  CK9WB0WJ01
  CK9W99WD01 
  CK9W92WD01
  CK9W85WC02
  CK9S78SE01
  CK9K87KD01
  CK9K21KJ01
  CF6WD9WJ01
  CF6KE4KD01
  CF2KE4KD02
  CF2K21KD01
  CE2W62WB01
  CE2W53WJ01
  CE2W51WJ03
  CE1WD4WD01
  CE1W41WC02
  CE1W41WC01
  CE1W37WJ02
  CE1S67SE01
  CE1S63SE01
  CE1KE2KE01
  CE1KC4KE01
  CD5W93WC01
  CD5S51SE03
  CD2WE1WJ01
  CD2WE1WD02
  CD2WE1WB03
  CD2W62WC01
  CD2KD3KD02
  CD2KD3KD01
  CD1WC8WD01
  CD1WB4WD02
  CD1K42KD02
  CD1K20KJ01
  CC5W10WJ03
  CC5W10WB01
  CC5K15KD02
  CC2W13WC01
  CC2KC6KD05
  CC2K01KE02
  CC1W08WB01
  CB5WB7WD02
  CB5KC7KD01
  CB4W09WJ01
  CB3W50WD01
  CB2W15WC01
  CB2W05WJ03
  CB2W05WC02
  CB2W05WC01
  CB2L96DC01
  CB2L86DC03
  CB2K69KD04
  CB2K69KD03
  CB1K07KD03
  CA5WE7WD02
  CA4W72WJ01
  CA2W13WC03
  C38K58KD01
  C28WD8WD01
  )
end