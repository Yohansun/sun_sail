# encoding:utf-8
desc "更新特殊商品"
task :special_products_sync => :environment do
	a = [
		'上海-上海市-长宁区',
	 	'上海-上海市-卢湾区',
	 '上海-上海市-普陀区',
	 '上海-上海市-闸北区',
	 '上海-上海市-青浦区',
	 '上海-上海市-金山区',
	 '上海-上海市-嘉定区',
	 '上海-上海市-松江区',
	 '上海-上海市-虹口区',
	 '上海-上海市-崇明县',
	 '上海-上海市-静安区',
	 '上海-上海市-宝山区',
	 '上海-上海市-浦东新区',
	 '上海-上海市-杨浦区',
	 '上海-上海市-闵行区',
	 '上海-上海市-南汇区',
	 '上海-上海市-奉贤区',
	 '上海-上海市-黄浦区',
	 '上海-上海市-川沙区',
	 '上海-上海市-其他区',
	 '上海-上海市-徐汇区',
	 '北京-北京市-东城区',
	 '北京-北京市-西城区',
	 '北京-北京市-丰台区',
	 '北京-北京市-崇文区',
	 '北京-北京市-宣武区',
	 '北京-北京市-朝阳区',
	 '北京-北京市-顺义区',
	 '北京-北京市-房山区',
	 '北京-北京市-大兴区',
	 '北京-北京市-通州区',
	 '北京-北京市-海淀区',
	 '北京-北京市-石景山区',
	 '北京-北京市-昌平区',
	 '北京-北京市-门头沟区',
	 '北京-北京市-怀柔区',
	 '北京-北京市-平谷区',
	 '北京-北京市-延庆县',
	 '北京-北京市-密云县',
	 '北京-北京市-其他区',
	 '江苏省-南京市-秦淮区',
	 '江苏省-南京市-江宁区',
	 '江苏省-南京市-建邺区',
	 '江苏省-南京市-玄武区',
	 '江苏省-南京市-下关区',
	 '江苏省-南京市-六合区',
	 '江苏省-南京市-鼓楼区',
	 '江苏省-南京市-浦口区',
	 '江苏省-南京市-栖霞区',
	 '江苏省-南京市-雨花台区',
	 '江苏省-南京市-白下区',
	 '江苏省-南京市-其它区',
	 '江苏省-常州市-武进区',
	 '江苏省-常州市-钟楼区',
	 '江苏省-常州市-金坛区',
	 '江苏省-常州市-天宁区',
	 '江苏省-常州市-新北区',
	 '江苏省-常州市-溧阳市',
	 '江苏省-常州市-戚墅堰区',
	 '江苏省-常州市-其它区',
	 '江苏省-镇江市-丹阳市',
	 '江苏省-镇江市-句容市',
	 '江苏省-镇江市-润州区',
	 '江苏省-镇江市-扬中市',
	 '江苏省-镇江市-京口区',
	 '江苏省-镇江市-丹徒区',
	 '江苏省-镇江市-其它区',
	 '江苏省-南通市-海门市',
	 '江苏省-南通市-崇川区',
	 '江苏省-南通市-通州区',
	 '江苏省-南通市-海安县',
	 '江苏省-南通市-港闸区',
	 '江苏省-南通市-启东市',
	 '江苏省-南通市-如东县',
	 '江苏省-南通市-如皋市',
	 '江苏省-南通市-通州市',
	 '江苏省-南通市-开发区',
	 '江苏省-南通市-其它区',
	 '江苏省-盐城市-滨海县',
	 '江苏省-盐城市-大丰市',
	 '江苏省-盐城市-东台市',
	 '江苏省-盐城市-阜宁县',
	 '江苏省-盐城市-建湖县',
	 '江苏省-盐城市-射阳县',
	 '江苏省-盐城市-响水县',
	 '江苏省-盐城市-亭湖区',
	 '江苏省-盐城市-盐都区',
	 '江苏省-盐城市-其它区',
	 '江苏省-连云港市-赣榆县',
	 '江苏省-连云港市-灌南县',
	 '江苏省-连云港市-新浦区',
	 '江苏省-连云港市-灌云县',
	 '江苏省-连云港市-东海县',
	 '江苏省-连云港市-连云区',
	 '江苏省-连云港市-海州区',
	 '江苏省-连云港市-其它区',
	 '江苏省-宿迁市-沭阳县',
	 '江苏省-宿迁市-泗洪县',
	 '江苏省-宿迁市-泗阳县',
	 '江苏省-宿迁市-宿豫区',
	 '江苏省-宿迁市-宿城区',
	 '江苏省-宿迁市-其它区',
	 '江苏省-徐州市-丰县',
	 '江苏省-徐州市-睢宁县',
	 '江苏省-徐州市-新沂市',
	 '江苏省-徐州市-邳州市',
	 '江苏省-徐州市-九里区',
	 '江苏省-徐州市-铜山县',
	 '江苏省-徐州市-云龙区',
	 '江苏省-徐州市-贾汪区',
	 '江苏省-徐州市-泉山区',
	 '江苏省-徐州市-沛县',
	 '江苏省-徐州市-鼓楼区',
	 '江苏省-徐州市-其它区',
	 '江苏省-淮安市-洪泽县',
	 '江苏省-淮安市-清河区',
	 '江苏省-淮安市-楚州区',
	 '江苏省-淮安市-金湖县',
	 '江苏省-淮安市-涟水县',
	 '江苏省-淮安市-淮阴区',
	 '江苏省-淮安市-清浦区',
	 '江苏省-淮安市-其它区',
	 '江苏省-淮安市-盱眙县',
	 '江苏省-泰州市-姜堰市',
	 '江苏省-泰州市-靖江市',
	 '江苏省-泰州市-泰兴市',
	 '江苏省-泰州市-海陵区',
	 '江苏省-泰州市-兴化市',
	 '江苏省-泰州市-高港区',
	 '江苏省-泰州市-其它区',
	 '江苏省-扬州市-宝应县',
	 '江苏省-扬州市-高邮市',
	 '江苏省-扬州市-江都市',
	 '江苏省-扬州市-广陵区',
	 '江苏省-扬州市-仪征市',
	 '江苏省-扬州市-邗江区',
	 '江苏省-扬州市-维扬区',
	 '江苏省-扬州市-经济开发区',
	 '江苏省-扬州市-淮安市',
	 '江苏省-扬州市-其它区',
	 '浙江省-杭州市-萧山区',
	 '浙江省-杭州市-余杭区',
	 '浙江省-杭州市-江干区',
	 '浙江省-杭州市-拱墅区',
	 '浙江省-杭州市-西湖区',
	 '浙江省-杭州市-上城区',
	 '浙江省-杭州市-下城区',
	 '浙江省-杭州市-富阳市',
	 '浙江省-杭州市-滨江区',
	 '浙江省-湖州市-吴兴区',
	 '浙江省-嘉兴市-桐乡市',
	 '浙江省-嘉兴市-海宁市',
	 '浙江省-嘉兴市-平湖市',
	 '浙江省-嘉兴市-嘉善县',
	 '浙江省-宁波市-北仑区',
	 '浙江省-宁波市-镇海区',
	 '浙江省-宁波市-余姚市',
	 '浙江省-宁波市-慈溪市',
	 '浙江省-宁波市-奉化市',
	 '浙江省-宁波市-宁海县',
	 '浙江省-宁波市-象山县',
	 '浙江省-宁波市-海曙区',
	 '浙江省-宁波市-江东区',
	 '浙江省-宁波市-江北区',
	 '浙江省-宁波市-鄞州区',
	 '浙江省-舟山市-定海区',
	 '浙江省-舟山市-岱山县',
	 '浙江省-舟山市-普陀区',
	 '浙江省-舟山市-嵊泗县',
	 '浙江省-绍兴市-越城区',
	 '浙江省-绍兴市-绍兴县',
	 '浙江省-绍兴市-诸暨市',
	 '浙江省-绍兴市-上虞市',
	 '浙江省-绍兴市-嵊州市',
	 '浙江省-温州市-鹿城区',
	 '浙江省-温州市-瓯海区',
	 '浙江省-温州市-乐清市',
	 '浙江省-台州市-路桥区',
	 '浙江省-台州市-椒江区',
	 '浙江省-台州市-黄岩区',
	 '浙江省-台州市-玉环县',
	 '浙江省-台州市-仙居县',
	 '浙江省-台州市-温岭市',
	 '浙江省-台州市-天台县',
	 '浙江省-台州市-三门县',
	 '浙江省-台州市-临海市',
	 '浙江省-金华市-婺城区',
	 '浙江省-金华市-金东区',
	 '浙江省-金华市-东阳市',
	 '浙江省-丽水市-莲都区',
	 '浙江省-衢州市-柯城区',
	 '浙江省-衢州市-衢江区',
	 '湖北省-武汉市-硚口区',
	 '湖北省-武汉市-江汉区',
	 '湖北省-武汉市-东西湖区',
	 '湖北省-武汉市-江岸区',
	 '湖北省-武汉市-武昌区',
	 '湖北省-武汉市-青山区',
	 '湖北省-武汉市-汉阳区',
	 '湖北省-武汉市-洪山区',
	 '安徽省-滁州市-天长市',
	 '安徽省-滁州市-琅琊区',
	 '安徽省-滁州市-南谯区',
	 '安徽省-淮南市-大通区',
	 '安徽省-淮南市-田家庵区',
	 '安徽省-淮南市-谢家集区',
	 '安徽省-淮南市-八公山区',
	 '安徽省-淮南市-潘集区',
	 '安徽省-蚌埠市-龙子湖区',
	 '安徽省-蚌埠市-蚌山区',
	 '安徽省-蚌埠市-禹会区',
	 '安徽省-蚌埠市-淮上区',
	 '安徽省-巢湖市-居巢区',
	 '安徽省-合肥市-包河区',
	 '安徽省-合肥市-蜀山区',
	 '安徽省-合肥市-瑶海区',
	 '安徽省-合肥市-庐阳区',
	 '安徽省-合肥市-高新区',
	 '安徽省-合肥市-中区',
	 '安徽省-六安市-金安区',
	 '安徽省-六安市-裕安区',
	 '安徽省-池州市-贵池区',
	 '安徽省-安庆市-迎江区',
	 '安徽省-安庆市-大观区',
	 '安徽省-安庆市-宜秀区',
	 '安徽省-铜陵市-铜关山区',
	 '安徽省-铜陵市-狮子山区',
	 '安徽省-铜陵市-郊区',
	 '安徽省-铜陵市-铜陵县',
	 '安徽省-黄山市-屯溪区',
	 '安徽省-黄山市-徽州区',
	 '安徽省-黄山市-休宁县',
	 '安徽省-黄山市-黔县',
	 '安徽省-芜湖市-镜湖区',
	 '安徽省-芜湖市-弋江区',
	 '安徽省-芜湖市-鸠江区',
	 '安徽省-芜湖市-三山区',
	 '安徽省-宣城市-郎溪县-宣州区',
	 '安徽省-宣城市-郎溪县',
	 '安徽省-宣城市-绩溪县',
	 '安徽省-宣城市-旌德县',
	 '安徽省-马鞍山市-雨山区',
	 '安徽省-马鞍山市-花山区',
	 '安徽省-马鞍山市-金家庄区',
	 '安徽省-淮北市-相山区',
	 '安徽省-淮北市-杜集区',
	 '安徽省-淮北市-烈山区',
	 '安徽省-宿州市-墉桥区',
	 '安徽省-亳州市-谯城区',
	 '安徽省-亳州市-蒙城县',
	 '安徽省-亳州市-利辛县',
	 '安徽省-阜阳市-颍州区',
	 '安徽省-阜阳市-颍泉区',
	 '安徽省-阜阳市-颍东区',
	 '天津-天津市-和平区',
	 '天津-天津市-河东区',
	 '天津-天津市-河西区',
	 '天津-天津市-南开区',
	 '天津-天津市-河北区',
	 '天津-天津市-红桥区',
	 '天津-天津市-东丽区',
	 '天津-天津市-西青区',
	 '天津-天津市-北辰区',
	 '天津-天津市-塘沽区',
	 '天津-天津市-汉沽区',
	 '天津-天津市-大港区',
	 '天津-天津市-津南区',
	 '天津-天津市-武清区',
	 '天津-天津市-宝坻区',
	 '天津-天津市-静海县',
	 '天津-天津市-宁河县',
	 '天津-天津市-滨海新区',
	 '天津-天津市-蓟县',
	 '天津-天津市-其它区',
	 '河北省-唐山市-路南区',
	 '河北省-唐山市-路北区',
	 '河北省-唐山市-古冶区',
	 '河北省-唐山市-开平区',
	 '河北省-唐山市-丰润区',
	 '河北省-唐山市-丰南区',
	 '河北省-唐山市-遵化市',
	 '河北省-唐山市-迁安市',
	 '河北省-唐山市-迁西县',
	 '河北省-唐山市-玉田县',
	 '河北省-唐山市-唐海县',
	 '河北省-唐山市-乐亭县',
	 '河北省-唐山市-滦县',
	 '河北省-唐山市-其它区',
	 '河北省-秦皇岛市-海港区',
	 '河北省-秦皇岛市-山海关区',
	 '河北省-秦皇岛市-北戴河区',
	 '河北省-秦皇岛市-昌黎县',
	 '河北省-秦皇岛市-卢龙县',
	 '河北省-秦皇岛市-经济技术开发区',
	 '河北省-秦皇岛市-抚宁县',
	 '河北省-秦皇岛市-青龙满族自治县',
	 '河北省-秦皇岛市-其它区',
	 '河南省-许昌市-魏都区',
	 '河南省-许昌市-禹州市',
	 '河南省-许昌市-长葛市',
	 '河南省-许昌市-许昌市县',
	 '河南省-许昌市-鄢陵县',
	 '河南省-许昌市-襄城县',
	 '河南省-许昌市-其它区',
	 '河南省-南阳市-宛城区',
	 '河南省-南阳市-卧龙区',
	 '河南省-南阳市-邓州市',
	 '河南省-南阳市-桐柏县',
	 '河南省-南阳市-方城县',
	 '河南省-南阳市-淅川县',
	 '河南省-南阳市-镇平县',
	 '河南省-南阳市-唐河县',
	 '河南省-南阳市-南召县',
	 '河南省-南阳市-内乡县',
	 '河南省-南阳市-新野县',
	 '河南省-南阳市-社旗县',
	 '河南省-南阳市-西峡县',
	 '河南省-南阳市-其它区',
	 '河南省-新乡市-红旗区',
	 '河南省-新乡市-卫滨区',
	 '河南省-新乡市-凤泉区',
	 '河南省-新乡市-牧野区',
	 '河南省-新乡市-卫辉市',
	 '河南省-新乡市-辉县市',
	 '河南省-新乡市-新乡市县',
	 '河南省-新乡市-获嘉县',
	 '河南省-新乡市-原阳县',
	 '河南省-新乡市-长垣县',
	 '河南省-新乡市-封丘县',
	 '河南省-新乡市-延津县',
	 '河南省-新乡市-其它区',
	 '河南省-郑州市-中原区',
	 '河南省-郑州市-二七区',
	 '河南省-郑州市-管城回族区',
	 '河南省-郑州市-金水区',
	 '河南省-郑州市-惠济区',
	 '河南省-郑州市-其它区',
	 '河南省-郑州市-上街区',
	 '河南省-郑州市-巩义市',
	 '河南省-郑州市-新郑市',
	 '河南省-郑州市-新密市',
	 '河南省-郑州市-登封市',
	 '河南省-郑州市-荥阳市',
	 '河南省-郑州市-郑东新区',
	 '河南省-郑州市-高新区',
	 '河南省-郑州市-中牟县',
	 '河南省-洛阳市-老城区',
	 '河南省-洛阳市-西工区',
	 '河南省-洛阳市-廛河回族区',
	 '河南省-洛阳市-涧西区',
	 '河南省-洛阳市-洛龙区',
	 '河南省-洛阳市-偃师市',
	 '河南省-洛阳市-栾川县',
	 '河南省-洛阳市-高新区',
	 '河南省-洛阳市-孟津县',
	 '河南省-洛阳市-吉利区',
	 '河南省-洛阳市-汝阳县',
	 '河南省-洛阳市-伊川县',
	 '河南省-洛阳市-洛宁县',
	 '河南省-洛阳市-嵩县',
	 '河南省-洛阳市-宜阳县',
	 '河南省-洛阳市-新安县',
	 '河南省-洛阳市-其它区',
	 '河南省-安阳市-文峰区',
	 '河南省-安阳市-北关区',
	 '河南省-安阳市-殷都区',
	 '河南省-安阳市-龙安区',
	 '河南省-安阳市-林州市',
	 '河南省-安阳市-安阳市县',
	 '河南省-安阳市-滑县',
	 '河南省-安阳市-内黄县',
	 '河南省-安阳市-汤阴县',
	 '河南省-安阳市-其它区',
	 '河南省-平顶山市-新华区',
	 '河南省-平顶山市-卫东区',
	 '河南省-平顶山市-湛河区',
	 '河南省-平顶山市-石龙区',
	 '河南省-平顶山市-汝州市',
	 '河南省-平顶山市-舞钢市',
	 '河南省-平顶山市-宝丰县',
	 '河南省-平顶山市-叶县',
	 '河南省-平顶山市-郏县',
	 '河南省-平顶山市-鲁山县',
	 '河南省-平顶山市-其它区',
	 '河南省-漯河市-源汇区',
	 '河南省-漯河市-郾城区',
	 '河南省-漯河市-召陵区',
	 '河南省-漯河市-临颍县',
	 '河南省-漯河市-舞阳县',
	 '河南省-漯河市-其它区',
	 '河南省-商丘市-梁园区',
	 '河南省-商丘市-睢阳区',
	 '河南省-商丘市-永城市',
	 '河南省-商丘市-宁陵县',
	 '河南省-商丘市-虞城县',
	 '河南省-商丘市-民权县',
	 '河南省-商丘市-夏邑县',
	 '河南省-商丘市-柘城县',
	 '河南省-商丘市-睢县',
	 '河南省-商丘市-其它区',
	 '河南省-信阳市-浉河区',
	 '河南省-信阳市-平桥区',
	 '河南省-信阳市-潢川县',
	 '河南省-信阳市-淮滨县',
	 '河南省-信阳市-息县',
	 '河南省-信阳市-新县',
	 '河南省-信阳市-商城县',
	 '河南省-信阳市-固始县',
	 '河南省-信阳市-罗山县',
	 '河南省-信阳市-光山县',
	 '河南省-信阳市-其它区',
	 '河南省-周口市-川汇区',
	 '河南省-周口市-项城市',
	 '河南省-周口市-商水县',
	 '河南省-周口市-淮阳县',
	 '河南省-周口市-太康县',
	 '河南省-周口市-鹿邑县',
	 '河南省-周口市-西华县',
	 '河南省-周口市-扶沟县',
	 '河南省-周口市-沈丘县',
	 '河南省-周口市-郸城县',
	 '河南省-周口市-其它区',
	 '河南省-驻马店市-驿城区',
	 '河南省-驻马店市-确山县',
	 '河南省-驻马店市-新蔡县',
	 '河南省-驻马店市-上蔡县',
	 '河南省-驻马店市-西平县',
	 '河南省-驻马店市-泌阳县',
	 '河南省-驻马店市-平舆县',
	 '河南省-驻马店市-汝南县',
	 '河南省-驻马店市-遂平县',
	 '河南省-驻马店市-正阳县',
	 '河南省-驻马店市-其它区',
	 '河南省-济源市-济源市',
	 '河南省-开封市-开封市县',
	 '河南省-开封市-兰考县',
	 '河南省-开封市-杞县',
	 '河南省-开封市-通许县',
	 '河南省-开封市-鼓楼区',
	 '河南省-开封市-龙亭区',
	 '河南省-开封市-顺河回族区',
	 '河南省-开封市-禹王台区',
	 '河南省-开封市-金明区',
	 '河南省-开封市-尉氏县',
	 '河南省-开封市-其它区',
	 '河南省-焦作市-解放区',
	 '河南省-焦作市-中站区',
	 '河南省-焦作市-马村区',
	 '河南省-焦作市-山阳区',
	 '河南省-焦作市-沁阳市',
	 '河南省-焦作市-孟州市',
	 '河南省-焦作市-修武县',
	 '河南省-焦作市-温县',
	 '河南省-焦作市-武陟县',
	 '河南省-焦作市-博爱县',
	 '河南省-焦作市-其它区',
	 '河南省-鹤壁市-淇滨区',
	 '河南省-鹤壁市-山城区',
	 '河南省-鹤壁市-鹤山区',
	 '河南省-鹤壁市-浚县',
	 '河南省-鹤壁市-淇县',
	 '河南省-鹤壁市-其它区',
	 '河南省-三门峡市-湖滨区',
	 '河南省-三门峡市-义马市',
	 '河南省-三门峡市-灵宝市',
	 '河南省-三门峡市-渑池县',
	 '河南省-三门峡市-卢氏县',
	 '河南省-三门峡市-陕县',
	 '河南省-三门峡市-其它区',
	 '河南省-濮阳市-华龙区',
	 '河南省-濮阳市-濮阳市县',
	 '河南省-濮阳市-南乐县',
	 '河南省-濮阳市-台前县',
	 '河南省-濮阳市-清丰县',
	 '河南省-濮阳市-范县',
	 '河南省-濮阳市-其它区',
	 '山西省-太原市-小店区',
	 '山西省-太原市-迎泽区',
	 '山西省-太原市-杏花岭区',
	 '山西省-太原市-尖草坪区',
	 '山西省-太原市-万柏林区',
	 '山西省-太原市-晋源区',
	 '山西省-太原市-古交市',
	 '山西省-太原市-阳曲县',
	 '山西省-太原市-清徐县',
	 '山西省-太原市-娄烦县',
	 '山西省-太原市-其它区',
	 '山西省-运城市-盐湖区',
	 '山西省-运城市-河津市',
	 '山西省-运城市-永济市',
	 '山西省-运城市-闻喜县',
	 '山西省-运城市-新绛县',
	 '山西省-运城市-平陆县',
	 '山西省-运城市-垣曲县',
	 '山西省-运城市-绛县',
	 '山西省-运城市-稷山县',
	 '山西省-运城市-芮城县',
	 '山西省-运城市-夏县',
	 '山西省-运城市-万荣县',
	 '山西省-运城市-临猗县',
	 '山西省-运城市-其它区',
	 '山西省-临汾市-尧都区',
	 '山西省-临汾市-侯马市',
	 '山西省-临汾市-霍州市',
	 '山西省-临汾市-汾西县',
	 '山西省-临汾市-吉县',
	 '山西省-临汾市-安泽县',
	 '山西省-临汾市-大宁县',
	 '山西省-临汾市-浮山县',
	 '山西省-临汾市-古县',
	 '山西省-临汾市-隰县',
	 '山西省-临汾市-襄汾县',
	 '山西省-临汾市-翼城县',
	 '山西省-临汾市-永和县',
	 '山西省-临汾市-乡宁县',
	 '山西省-临汾市-曲沃县',
	 '山西省-临汾市-洪洞县',
	 '山西省-临汾市-蒲县',
	 '山西省-临汾市-其它区',
	 '山西省-大同市-城区',
	 '山西省-大同市-矿区',
	 '山西省-大同市-南郊区',
	 '山西省-大同市-新荣区',
	 '山西省-大同市-大同市县',
	 '山西省-大同市-天镇县',
	 '山西省-大同市-灵丘县',
	 '山西省-大同市-阳高县',
	 '山西省-大同市-左云县',
	 '山西省-大同市-广灵县',
	 '山西省-大同市-浑源县',
	 '山西省-大同市-其它区',
	 '山西省-长治市-城区',
	 '山西省-长治市-郊区',
	 '山西省-长治市-高新区',
	 '山西省-长治市-潞城市',
	 '山西省-长治市-长治市县',
	 '山西省-长治市-长子县',
	 '山西省-长治市-平顺县',
	 '山西省-长治市-襄垣县',
	 '山西省-长治市-沁源县',
	 '山西省-长治市-屯留县',
	 '山西省-长治市-黎城县',
	 '山西省-长治市-武乡县',
	 '山西省-长治市-沁县',
	 '山西省-长治市-壶关县',
	 '山西省-长治市-其它区',
	 '山西省-晋城市-城区',
	 '山西省-晋城市-高平市',
	 '山西省-晋城市-泽州县',
	 '山西省-晋城市-陵川县',
	 '山西省-晋城市-阳城县',
	 '山西省-晋城市-沁水县',
	 '山西省-晋城市-其它区',
	 '山西省-阳泉市-城区',
	 '山西省-阳泉市-矿区',
	 '山西省-阳泉市-郊区',
	 '山西省-阳泉市-平定县',
	 '山西省-阳泉市-盂县',
	 '山西省-阳泉市-其它区',
	 '山西省-运城市-榆次区',
	 '山西省-运城市-介休市',
	 '山西省-运城市-昔阳县',
	 '山西省-运城市-灵石县',
	 '山西省-运城市-祁县',
	 '山西省-运城市-左权县',
	 '山西省-运城市-寿阳县',
	 '山西省-运城市-太谷县',
	 '山西省-运城市-和顺县',
	 '山西省-运城市-平遥县',
	 '山西省-运城市-榆社县',
	 '山西省-运城市-其它区',
	 '山西省-朔州市-朔城区',
	 '山西省-朔州市-平鲁区',
	 '山西省-朔州市-山阴县',
	 '山西省-朔州市-右玉县',
	 '山西省-朔州市-应县',
	 '山西省-朔州市-怀仁县',
	 '山西省-朔州市-其它区',
	 '山西省-忻州市-忻府区',
	 '山西省-忻州市-原平市',
	 '山西省-忻州市-代县',
	 '山西省-忻州市-神池县',
	 '山西省-忻州市-五寨县',
	 '山西省-忻州市-五台县',
	 '山西省-忻州市-偏关县',
	 '山西省-忻州市-宁武县',
	 '山西省-忻州市-静乐县',
	 '山西省-忻州市-繁峙县',
	 '山西省-忻州市-河曲县',
	 '山西省-忻州市-保德县',
	 '山西省-忻州市-定襄县',
	 '山西省-忻州市-岢岚县',
	 '山西省-忻州市-其它区',
	 '山西省-吕梁市-离石区',
	 '山西省-吕梁市-孝义市',
	 '山西省-吕梁市-汾阳市',
	 '山西省-吕梁市-文水县',
	 '山西省-吕梁市-中阳县',
	 '山西省-吕梁市-兴县',
	 '山西省-吕梁市-临县',
	 '山西省-吕梁市-方山县',
	 '山西省-吕梁市-柳林县',
	 '山西省-吕梁市-岚县',
	 '山西省-吕梁市-交口县',
	 '山西省-吕梁市-交城县',
	 '山西省-吕梁市-石楼县',
	 '山西省-吕梁市-其它区',
	 '山东省-青岛市-市南区',
	 '山东省-青岛市-市北区',
	 '山东省-青岛市-四方区',
	 '山东省-青岛市-黄岛区',
	 '山东省-青岛市-崂山区',
	 '山东省-青岛市-李沧区',
	 '山东省-青岛市-城阳区',
	 '山东省-青岛市-其它区',
	 '山东省-青岛市-胶南市',
	 '山东省-青岛市-胶州市',
	 '山东省-青岛市-平度市',
	 '山东省-青岛市-莱西市',
	 '山东省-青岛市-开发区',
	 '山东省-青岛市-即墨市',
	 '山东省-潍坊市-潍城区',
	 '山东省-潍坊市-寒亭区',
	 '山东省-潍坊市-坊子区',
	 '山东省-潍坊市-奎文区',
	 '山东省-潍坊市-其它区',
	 '山东省-潍坊市-青州市',
	 '山东省-潍坊市-诸城市',
	 '山东省-潍坊市-寿光市',
	 '山东省-潍坊市-安丘市',
	 '山东省-潍坊市-高密市',
	 '山东省-潍坊市-昌邑市',
	 '山东省-潍坊市-昌乐县',
	 '山东省-潍坊市-开发区',
	 '山东省-潍坊市-临朐县',
	 '山东省-青岛市-芝罘区',
	 '山东省-青岛市-莱山区',
	 '山东省-青岛市-龙口市',
	 '山东省-青岛市-其它区',
	 '山东省-青岛市-福山区',
	 '山东省-青岛市-牟平区',
	 '山东省-青岛市-莱阳市',
	 '山东省-青岛市-莱州市',
	 '山东省-青岛市-招远市',
	 '山东省-青岛市-栖霞市',
	 '山东省-青岛市-蓬莱市',
	 '山东省-青岛市-海阳市',
	 '山东省-青岛市-长岛县',
	 '山东省-威海市-乳山市',
	 '山东省-威海市-其它区',
	 '山东省-威海市-环翠区',
	 '山东省-威海市-文登市',
	 '山东省-威海市-荣成市',
	 '山东省-青岛市-张店区',
	 '山东省-青岛市-临淄区',
	 '山东省-青岛市-淄川区',
	 '山东省-青岛市-博山区',
	 '山东省-青岛市-桓台县',
	 '山东省-青岛市-周村区',
	 '山东省-青岛市-高青县',
	 '山东省-青岛市-沂源县',
	 '山东省-青岛市-其它区',
	 '山东省-青岛市-青岛市区',
	 '山东省-青岛市-河口区',
	 '山东省-青岛市-垦利县',
	 '山东省-青岛市-广饶县',
	 '山东省-青岛市-东城区',
	 '山东省-青岛市-西城区',
	 '山东省-青岛市-利津县',
	 '山东省-青岛市-其它区',
	 '山东省-济南市-历下区',
	 '山东省-济南市-市中区',
	 '山东省-济南市-槐荫区',
	 '山东省-济南市-天桥区',
	 '山东省-济南市-历城区',
	 '山东省-济南市-长清区',
	 '山东省-济南市-章丘市',
	 '山东省-济南市-平阴县',
	 '山东省-济南市-济阳县',
	 '山东省-济南市-商河县',
	 '山东省-济南市-其它区',
	 '山东省-济宁市-市中区',
	 '山东省-济宁市-任城区',
	 '山东省-济宁市-曲阜市',
	 '山东省-济宁市-兖州市',
	 '山东省-济宁市-邹城市',
	 '山东省-济宁市-鱼台县',
	 '山东省-济宁市-金乡县',
	 '山东省-济宁市-嘉祥县',
	 '山东省-济宁市-微山县',
	 '山东省-济宁市-汶上县',
	 '山东省-济宁市-泗水县',
	 '山东省-济宁市-梁山县',
	 '山东省-济宁市-其它区',
	 '山东省-泰安市-泰山区',
	 '山东省-泰安市-岱岳区',
	 '山东省-泰安市-新泰市',
	 '山东省-泰安市-肥城市',
	 '山东省-泰安市-宁阳县',
	 '山东省-泰安市-东平县',
	 '山东省-泰安市-其它区',
	 '山东省-临沂市-兰山区',
	 '山东省-临沂市-罗庄区',
	 '山东省-临沂市-河东区',
	 '山东省-临沂市-沂南县',
	 '山东省-临沂市-郯城县',
	 '山东省-临沂市-沂水县',
	 '山东省-临沂市-苍山县',
	 '山东省-临沂市-费县',
	 '山东省-临沂市-平邑县',
	 '山东省-临沂市-莒南县',
	 '山东省-临沂市-蒙阴县',
	 '山东省-临沂市-临沭县',
	 '山东省-临沂市-其它区',
	 '山东省-枣庄市-市中区',
	 '山东省-枣庄市-山亭区',
	 '山东省-枣庄市-峄城区',
	 '山东省-枣庄市-台儿庄区',
	 '山东省-枣庄市-薛城区',
	 '山东省-枣庄市-滕州市',
	 '山东省-枣庄市-其它区',
	 '山东省-莱芜市-莱城区',
	 '山东省-莱芜市-钢城区',
	 '山东省-莱芜市-其它区',
	 '山东省-德州市-德城区',
	 '山东省-德州市-乐陵市',
	 '山东省-德州市-禹城市',
	 '山东省-德州市-陵县',
	 '山东省-德州市-宁津县',
	 '山东省-德州市-齐河县',
	 '山东省-德州市-武城县',
	 '山东省-德州市-庆云县',
	 '山东省-德州市-平原县',
	 '山东省-德州市-夏津县',
	 '山东省-德州市-开发区',
	 '山东省-德州市-临邑县',
	 '山东省-德州市-其它区',
	 '山东省-聊城市-东昌府区',
	 '山东省-聊城市-临清市',
	 '山东省-聊城市-高唐县',
	 '山东省-聊城市-阳谷县',
	 '山东省-聊城市-茌平县',
	 '山东省-聊城市-莘县',
	 '山东省-聊城市-东阿县',
	 '山东省-聊城市-冠县',
	 '山东省-聊城市-其它区',
	 '山东省-滨州市-滨城区',
	 '山东省-滨州市-邹平县',
	 '山东省-滨州市-沾化县',
	 '山东省-滨州市-惠民县',
	 '山东省-滨州市-博兴县',
	 '山东省-滨州市-阳信县',
	 '山东省-滨州市-无棣县',
	 '山东省-滨州市-其它区',
	 '山东省-菏泽市-牡丹区',
	 '山东省-菏泽市-鄄城县',
	 '山东省-菏泽市-单县',
	 '山东省-菏泽市-郓城县',
	 '山东省-菏泽市-曹县',
	 '山东省-菏泽市-定陶县',
	 '山东省-菏泽市-巨野县',
	 '山东省-菏泽市-东明县',
	 '山东省-菏泽市-成武县',
	 '山东省-菏泽市-其它区',
	 '山东省-日照市-其它区',
	 '山东省-日照市-东港区',
	 '山东省-日照市-岚山区',
	 '山东省-日照市-五莲县',
	 '山东省-日照市-莒县',
	 '四川省-成都市-锦江区',
	 '四川省-成都市-青羊区',
	 '四川省-成都市-金牛区',
	 '四川省-成都市-武侯区',
	 '四川省-成都市-成华区',
	 '湖南省-株洲市-荷塘区',
	 '湖南省-株洲市-芦淞区',
	 '湖南省-株洲市-石峰区',
	 '湖南省-株洲市-天元区',
	 '湖南省-株洲市-醴陵市',
	 '湖南省-株洲市-株洲县',
	 '湖南省-株洲市-炎陵县',
	 '湖南省-株洲市-茶陵县',
	 '湖南省-株洲市-攸县',
	 '湖南省-株洲市-其它区',
	 '湖南省-长沙市-芙蓉区',
	 '湖南省-长沙市-天心区',
	 '湖南省-长沙市-岳麓区',
	 '湖南省-长沙市-开福区',
	 '湖南省-长沙市-雨花区',
	 '湖南省-长沙市-浏阳市',
	 '湖南省-长沙市-长沙县',
	 '湖南省-长沙市-望城县',
	 '湖南省-长沙市-宁乡县',
	 '湖南省-长沙市-其它区',
	 '湖南省-湘潭市-岳塘区',
	 '湖南省-湘潭市-雨湖区',
	 '湖南省-湘潭市-湘乡市',
	 '湖南省-湘潭市-韶山市',
	 '湖南省-湘潭市-湘潭县',
	 '湖南省-湘潭市-其它区',
	 '湖南省-衡阳市-雁峰区',
	 '湖南省-衡阳市-珠晖区',
	 '湖南省-衡阳市-石鼓区',
	 '湖南省-衡阳市-蒸湘区',
	 '湖南省-衡阳市-南岳区',
	 '湖南省-衡阳市-耒阳市',
	 '湖南省-衡阳市-常宁市',
	 '湖南省-衡阳市-衡阳县',
	 '湖南省-衡阳市-衡东县',
	 '湖南省-衡阳市-衡山县',
	 '湖南省-衡阳市-衡南县',
	 '湖南省-衡阳市-祁东县',
	 '湖南省-衡阳市-其它区',
	 '湖南省-邵阳市-双清区',
	 '湖南省-邵阳市-大祥区',
	 '湖南省-邵阳市-北塔区',
	 '湖南省-邵阳市-武冈市',
	 '湖南省-邵阳市-邵东县',
	 '湖南省-邵阳市-洞口县',
	 '湖南省-邵阳市-新邵县',
	 '湖南省-邵阳市-绥宁县',
	 '湖南省-邵阳市-新宁县',
	 '湖南省-邵阳市-邵阳县',
	 '湖南省-邵阳市-隆回县',
	 '湖南省-邵阳市-城步苗族自治县',
	 '湖南省-邵阳市-其它区',
	 '湖南省-岳阳市-岳阳楼区',
	 '湖南省-岳阳市-君山区',
	 '湖南省-岳阳市-云溪区',
	 '湖南省-岳阳市-临湘市',
	 '湖南省-岳阳市-汨罗市',
	 '湖南省-岳阳市-岳阳县',
	 '湖南省-岳阳市-湘阴县',
	 '湖南省-岳阳市-平江县',
	 '湖南省-岳阳市-华容县',
	 '湖南省-岳阳市-其它区',
	 '湖南省-常德市-武陵区',
	 '湖南省-常德市-鼎城区',
	 '湖南省-常德市-津市市',
	 '湖南省-常德市-澧县',
	 '湖南省-常德市-临澧县',
	 '湖南省-常德市-桃源县',
	 '湖南省-常德市-汉寿县',
	 '湖南省-常德市-安乡县',
	 '湖南省-常德市-石门县',
	 '湖南省-常德市-其它区',
	 '湖南省-张家界市-永定区',
	 '湖南省-张家界市-武陵源区',
	 '湖南省-张家界市-慈利县',
	 '湖南省-张家界市-桑植县',
	 '湖南省-张家界市-其它区',
	 '湖南省-益阳市-赫山区',
	 '湖南省-益阳市-资阳区',
	 '湖南省-益阳市-沅江市',
	 '湖南省-益阳市-桃江县',
	 '湖南省-益阳市-南县',
	 '湖南省-益阳市-安化县',
	 '湖南省-益阳市-其它区',
	 '湖南省-郴州市-北湖区',
	 '湖南省-郴州市-苏仙区',
	 '湖南省-郴州市-资兴市',
	 '湖南省-郴州市-宜章县',
	 '湖南省-郴州市-汝城县',
	 '湖南省-郴州市-安仁县',
	 '湖南省-郴州市-嘉禾县',
	 '湖南省-郴州市-临武县',
	 '湖南省-郴州市-桂东县',
	 '湖南省-郴州市-永兴县',
	 '湖南省-郴州市-桂阳县',
	 '湖南省-郴州市-其它区',
	 '湖南省-永州市-冷水滩区',
	 '湖南省-永州市-零陵区',
	 '湖南省-永州市-祁阳县',
	 '湖南省-永州市-蓝山县',
	 '湖南省-永州市-宁远县',
	 '湖南省-永州市-新田县',
	 '湖南省-永州市-东安县',
	 '湖南省-永州市-江永县',
	 '湖南省-永州市-道县',
	 '湖南省-永州市-双牌县',
	 '湖南省-永州市-江华瑶族自治县',
	 '湖南省-永州市-其它区',
	 '湖南省-怀化市-鹤城区',
	 '湖南省-怀化市-洪江市',
	 '湖南省-怀化市-会同县',
	 '湖南省-怀化市-沅陵县',
	 '湖南省-怀化市-辰溪县',
	 '湖南省-怀化市-溆浦县',
	 '湖南省-怀化市-中方县',
	 '湖南省-怀化市-新晃侗族自治县',
	 '湖南省-怀化市-芷江侗族自治县',
	 '湖南省-怀化市-通道侗族自治县',
	 '湖南省-怀化市-靖州苗族侗族自治县',
	 '湖南省-怀化市-麻阳苗族自治县',
	 '湖南省-怀化市-其它区',
	 '湖南省-娄底市-娄星区',
	 '湖南省-娄底市-冷水江市',
	 '湖南省-娄底市-涟源市',
	 '湖南省-娄底市-新化县',
	 '湖南省-娄底市-双峰县',
	 '湖南省-娄底市-其它区',
	 '湖南省-湘西土家族苗族自治州-吉首市',
	 '湖南省-湘西土家族苗族自治州-古丈县',
	 '湖南省-湘西土家族苗族自治州-龙山县',
	 '湖南省-湘西土家族苗族自治州-永顺县',
	 '湖南省-湘西土家族苗族自治州-凤凰县',
	 '湖南省-湘西土家族苗族自治州-泸溪县',
	 '湖南省-湘西土家族苗族自治州-保靖县',
	 '湖南省-湘西土家族苗族自治州-花垣县',
	 '湖南省-湘西土家族苗族自治州-其它区',
	 '福建省-厦门市-思明区',
	 '福建省-厦门市-海沧区',
	 '福建省-厦门市-湖里区',
	 '福建省-厦门市-集美区',
	 '福建省-厦门市-同安区',
	 '福建省-厦门市-翔安区',
	 '福建省-厦门市-其它区',
	 '福建省-漳州市-龙海市',
	 '福建省-漳州市-漳浦县',
	 '福建省-泉州市-泉港区',
	 '福建省-泉州市-南安市',
	 '福建省-泉州市-惠安县',
	 '福建省-泉州市-永春县',
	 '福建省-泉州市-安溪县',
	 '福建省-泉州市-德化县',
	 '福建省-龙岩市-新罗区',
	 '福建省-龙岩市-武平县',
	 '福建省-龙岩市-上杭县',
	 '福建省-龙岩市-永定县',
	 '福建省-龙岩市-其它区',
	 '海南省-海口市-琼山区',
	 '海南省-海口市-其它区',
	 '海南省-海口市-龙华区',
	 '海南省-海口市-美兰区',
	 '海南省-海口市-秀英区',
	 '海南省-三亚市-三亚市区',
	 '海南省-五指山市-五指山市',
	 '海南省-琼海市-琼海市',
	 '海南省-儋州市-儋州市',
	 '海南省-文昌市-文昌市',
	 '海南省-万宁市-万宁市',
	 '海南省-东方市-东方市',
	 '海南省-澄迈县-澄迈县',
	 '海南省-定安县-定安县',
	 '海南省-屯昌县-屯昌县',
	 '海南省-临高县-临高县',
	 '海南省-白沙黎族自治县-白沙黎族自治县',
	 '海南省-昌江黎族自治县-昌江黎族自治县',
	 '海南省-乐东黎族自治县-乐东黎族自治县',
	 '海南省-陵水黎族自治县-陵水黎族自治县',
	 '海南省-保亭黎族苗族自治县-保亭黎族苗族自治县',
	 '海南省-琼中黎族苗族自治县-琼中黎族苗族自治县',
	 '广东省-湛江市-赤坎区',
	 '广东省-湛江市-霞山区',
	 '广东省-湛江市-坡头区',
	 '广东省-湛江市-麻章区',
	 '广东省-湛江市-廉江市',
	 '广东省-湛江市-雷州市',
	 '广东省-湛江市-吴川市',
	 '广东省-湛江市-遂溪县',
	 '广东省-湛江市-徐闻县',
	 '广东省-湛江市-其它区',
	 '广东省-茂名市-茂南区',
	 '广东省-茂名市-茂港区',
	 '广东省-茂名市-高州市',
	 '广东省-茂名市-化州市',
	 '广东省-茂名市-信宜市',
	 '广东省-茂名市-电白县',
	 '广东省-茂名市-其它区',
	 '广东省-阳江市-江城区',
	 '广东省-阳江市-阳春市',
	 '广东省-阳江市-阳西县',
	 '广东省-阳江市-阳东县',
	 '广东省-阳江市-其它区',
	 '广东省-东莞市-东莞市',
	 '广东省-深圳市-罗湖区',
	 '广东省-深圳市-福田区',
	 '广东省-深圳市-南山区',
	 '广东省-深圳市-宝安区',
	 '广东省-深圳市-龙岗区',
	 '广东省-深圳市-盐田区',
	 '广东省-深圳市-其它区',
	 '广东省-广州市-越秀区',
	 '广东省-广州市-海珠区',
	 '广东省-广州市-荔湾区',
	 '广东省-广州市-天河区',
	 '广东省-广州市-白云区',
	 '广东省-广州市-黄埔区',
	 '广东省-广州市-番禺区',
	 '广东省-广州市-南沙区',
	 '广东省-广州市-萝岗区',
	 '广东省-广州市-东山区',
	 '广东省-珠海市-香洲区',
	 '广东省-珠海市-斗门区',
	 '广东省-珠海市-金湾区',
	 '广东省-佛山市-禅城区',
	 '广东省-佛山市-南海区',
	 '广东省-佛山市-顺德区',
	 '河南省-南昌市-青山湖区',
	 '内蒙古自治区-呼和浩特市-回民区',
	 '内蒙古自治区-呼和浩特市-玉泉区',
	 '内蒙古自治区-呼和浩特市-新城区',
	 '内蒙古自治区-呼和浩特市-赛罕区',
	 '内蒙古自治区-包头市-昆都仑区',
	 '内蒙古自治区-包头市-青山区',
	 '内蒙古自治区-包头市-东河区',
	 '内蒙古自治区-包头市-九原区',
	 '内蒙古自治区-乌海市-海勃湾区',
	 '内蒙古自治区-乌海市-乌达区',
	 '内蒙古自治区-乌海市-海南省区',
	 '内蒙古自治区-鄂尔多斯市-东胜区',
	 '内蒙古自治区-巴彦淖尔市-临河区',
	 '广西壮族自治区-柳州市-城中区',
	 '广西壮族自治区-柳州市-鱼峰区',
	 '广西壮族自治区-柳州市-柳北区',
	 '广西壮族自治区-柳州市-柳南区',
	 '广西壮族自治区-桂林市-象山区',
	 '广西壮族自治区-桂林市-秀峰区',
	 '广西壮族自治区-桂林市-叠彩区',
	 '广西壮族自治区-桂林市-七星区',
	 '广西壮族自治区-梧州市-万秀区',
	 '广西壮族自治区-梧州市-蝶山区',
	 '广西壮族自治区-梧州市-长洲区',
	 '广西壮族自治区-北海市-海城区',
	 '广西壮族自治区-北海市-银海区',
	 '广西壮族自治区-防城港市-港口区',
	 '广西壮族自治区-防城港市-防城区',
	 '广西壮族自治区-防城港市-东兴市',
	 '广西壮族自治区-钦州市-钦南区',
	 '广西壮族自治区-钦州市-钦北区',
	 '广西壮族自治区-钦州市-灵山县',
	 '广西壮族自治区-贵港市-港北区',
	 '广西壮族自治区-贵港市-港南区',
	 '广西壮族自治区-玉林市-玉州区',
	 '广西壮族自治区-百色市-右江区',
	 '广西壮族自治区-贺州市-八步区',
	 '广西壮族自治区-河池市-金城江区',
	 '广西壮族自治区-崇左市-江州区',
	 '广西壮族自治区-崇左市-凭祥市',
	 '广西壮族自治区-崇左市-宁明县',
	 '广西壮族自治区-崇左市-龙州县',
	 '广西壮族自治区-南宁市-兴宁区',
	 '广西壮族自治区-南宁市-西乡塘区',
	 '广西壮族自治区-南宁市-良庆区',
	 '广西壮族自治区-南宁市-江南区',
	 '广西壮族自治区-南宁市-青秀区',
	 '广西壮族自治区-来宾市-兴宾区',
	 '黑龙江省-哈尔滨市-南岗区',
	 '吉林省-长春市-净月旅游开发区',
	 '辽宁省-大连市-沙河口区',
	 '黑龙江省-大庆市-萨尔图区',
	 '吉林省-长春市-汽车产业开发区',
	 '辽宁省-沈阳市-和平区',
	 '辽宁省-大连市-甘井子区',
	 '辽宁省-沈阳市-皇姑区',
	 '福建省-福州市-鼓楼区',
	 '福建省-福州市-台江区',
	 '福建省-福州市-仓山区',
	 '福建省-福州市-晋安区',
	 '福建省-福州市-福清市',
	 '福建省-福州市-长乐市',
	 '福建省-福州市-闽侯县',
	 '福建省-福州市-闽清县',
	 '福建省-福州市-永泰县',
	 '福建省-福州市-连江县',
	 '福建省-福州市-罗源县',
	 '福建省-福州市-平潭县',
	 '福建省-福州市-其它区',
	 '福建省-莆田市-城厢区',
	 '福建省-莆田市-涵江区',
	 '福建省-莆田市-荔城区',
	 '福建省-莆田市-秀屿区',
	 '福建省-莆田市-仙游县',
	 '福建省-莆田市-其它区',
	 '福建省-三明市-梅列区',
	 '福建省-三明市-三元区',
	 '福建省-三明市-永安市',
	 '福建省-三明市-明溪县',
	 '福建省-三明市-将乐县',
	 '福建省-三明市-大田县',
	 '福建省-三明市-宁化县',
	 '福建省-三明市-建宁县',
	 '福建省-三明市-沙县',
	 '福建省-三明市-尤溪县',
	 '福建省-三明市-清流县',
	 '福建省-三明市-泰宁县',
	 '福建省-三明市-其它区'
	]

	product = Product.where(iid: 'I1P18L40063C4V04').first

	unless product
		puts 'I1P18L40063C4V04不存在'
		return
	end

	a.each do |area|
		district = nil
		areas = area.split('-')
		state_name = areas[0]
		city_name = areas[1]
		district_name = areas[2]
		state = Area.find_by_name state_name
    city = state.children.where(name: city_name).first if state
    district = city.children.where(name: district_name).first if city
    if district
    	district.sellers.where("seller_id not in (?)", [1791,1792,1793,1794]).each {|seller| seller.stock_products.where(product_id: product.id).delete_all}
    else
    	puts "#{area} not exists"
    end
  end
end