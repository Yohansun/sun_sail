jsReady = false
var dd
var flash_path = current_account ? "/swf/print_flash.swf" : '';

function isReady() { // //flash 会调用此方法检测页面 js 是否已经准备完毕；
  return jsReady
}

function pageInit() {   //flash 会检测页面 js 是否已经准备完毕；
  jsReady = true       //flash 需要这个值；
}

function printfeedback(str){  //如果flash 数据还未载入成功，会返回一个报错信息在str中；
  MagicOrders.hasPrint  = true
  data                  = str.split('|')
  print_type            = data[0]
  print_time            = data[1]
  ids                   = data[2]

  if (print_type == 'ffd') {
    $.get('/deliver_bills/batch-print-deliver', {ids: ids, time: print_time})
  } else {
    $.get('/deliver_bills/batch-print-logistic', {ids: ids, time: print_time, logistic: $("#logistic_select").find("option:selected").attr('lid')})
  }
}

function printfeedbacksize(str){ // 如果页面端需要知道 flash 当前的真实高度，这里会返回一个 ［宽，高］ 数组；
  alert(str);
}

function bind_swf(id, type, xml) {
  var flashvars = {
    'config':             '/deliver_bills/print_deliver_bill.xml?ids=' + id.toString(),
    'ppHeight':           '349',
    'ppWidth':            '648',
    'template':           'default',
    'printType':          type,
    'displayprint':       'true',            //是否显示打印按钮
    'view':               'false',                   //是否需要打印预览
    'allowScriptAccess':  'always',
    'needfeedbacksize':   'false',
    'templateUrl':        xml
  }

  if(type == 'kdd'){
    flashvars.templateUrl = xml
  }

  swfobject.embedSWF(flash_path, "showbox", "83", "35", "10","/swf/expressInstall.swf", flashvars);
}


function startPrint() {
  dd = getElement('logistic_print')
  dd.startPrint(); //调用Flash 的打印命令
  $('.print_logistic_button').attr('data-click', '1')
}

function getElement(id){ //获取Flash 元素，尽量别用jquery ，以jquery返回的是一个 jquery对象，而不是flash 本身 ；
  return document.getElementById(id);
}

function bind_deliver_swf (id,templateUrl) {
  bind_swf(id, 'ffd',templateUrl)
}

function bind_logistic_swf (id, xml) {
  var flashvars = {
    'config':             '/deliver_bills/print_deliver_bill.xml?ids='+ id,
    'ppHeight':           '349',
    'ppWidth':            '648',
    'template':           'default',
    'printType':          'kdd',
    'displayprint':       'false',                  //是否显示打印按钮
    'view':               'true',                   //是否需要打印预览
    'allowScriptAccess':  'always',
    'needfeedbacksize':   'false',
  }

  if(xml == ''){
    $.get('/trades/' + id + '/logistic_info', {}, function(data){
      flashvars.templateUrl = data
      swfobject.embedSWF(flash_path, "logistic_print", "820", "340", "10","/swf/expressInstall.swf", flashvars);
    })
  }else{
    flashvars.templateUrl = xml
    swfobject.embedSWF(flash_path, "logistic_print", "820", "340", "10","/swf/expressInstall.swf", flashvars);
  }
}