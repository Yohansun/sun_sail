# -*- encoding : utf-8 -*-
##### MUST initialize AutoSetting before use #####
#
# Usage:
#
# auto_setting = AutoSetting.new(current_account.settings.auto_settings)
#

module MagicAutoSettings

  module ViewHelper
    include ActionView::Helpers::TagHelper

    class AutoSetting
      include MagicAutoSettings::ViewHelper

      def initialize(setting)
        @setting = setting
      end

      def setting(array)
        specific_setting = @setting.dup
        array.count.times{|i| specific_setting = specific_setting[array[i]] rescue nil}
        specific_setting
      end
    end

    def setting_name(array)
      array.inject("auto_settings"){|name, string| name += ("["+string+"]")}
    end

    def is_checked(array, value)
      return "checked" if setting(array).present? && value == "on"
      return "checked" if setting(array).blank? && value == "off"
    end

    def block_radio(array, value, text)
      label_class = (value == "on" ? "radio input-small pull-left" : "radio")
      radio       = tag("input", type: 'radio', value: value, name: setting_name(array), checked: is_checked(array, value))
      content_tag("label", radio + text, class: label_class)
    end

    def block_checkbox(array, value="on")
      tag("input", type: 'checkbox', name: setting_name(array), checked: is_checked(array, value))
    end

    def block_time(array)
      tag("input", type: 'text', name: setting_name(array), value: setting(array), class: "input-mini timepickers radius_no_rb")
    end

    def block_input(array)
      tag("input", type: 'text', name: setting_name(array), value: setting(array), class: "input-medium")
    end

    def block_select(options, array, multiple=false, input_class="input-large")
      content = options.collect { |value|
        content_tag('option', value.to_a[0],
          value:    value.to_a[1] || value.to_a[0],
          selected: (multiple ? (setting(array).is_a?(Array) ? setting(array).include?(value.to_a[1] || value.to_a[0]) : false) : setting(array).to_s == value)
        )
      }.join("\n").html_safe
      content_tag('select', content,
        name:     (multiple ? setting_name(array) + "[]" : setting_name(array)),
        class:    (multiple ? input_class + " select2" : input_class),
        multiple: multiple
      )
    end

    def block_label_checkbox(array, text)
      block = block_checkbox(array) +
              text
      content_tag("label", block, class: "checkbox input-xxlarge")
    end

    def block_label_select(options, array, label_text, select_text=nil, multiple=false)
      block = content_tag('label', label_text, class: "input-large pull-left") +
              block_select(options, array, multiple) + select_text
      content_tag("p", block, class: "clear")
    end

    def block_check_select(options, arrays, checkbox_text, select_text=nil, multiple=false)
      block = block_checkbox(arrays[0]) +
              checkbox_text +
              block_select(options, arrays[1], multiple, (multiple ? "input-large" : "input-mini")) +
              select_text
      content_tag("label", block, class: "checkbox input-xxlarge")
    end

    def block_check_input(arrays, checkbox_text)
      block = block_checkbox(arrays[0]) +
              checkbox_text +
              block_input(arrays[1])
      content_tag("label", block, class: "checkbox input-xxlarge")
    end

    def block_dual_radio(*array)
      block_radio(array, "on", "开启") + "\n" +
      block_radio(array, 'off', "关闭")
    end

    def block_time_range(*arrays)
      block = content_tag('label', "请输入开启时间范围：", class: "input-large pull-left") +
              block_time(arrays[0]) + "\n" +
              content_tag("i", '', class: "icon-arrow-right") + "\n" +
              block_time(arrays[1]) + "\n" +
              content_tag("span", "(不选择默认为全天开启)", class: "muted")
      content_tag("p", block, class: "clear")
    end
  end
end