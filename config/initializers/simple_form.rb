# frozen_string_literal: true

SimpleForm.setup do |config|
  config.wrappers :default, tag: :div, class: "mb-4" do |b|
    b.use :html5
    b.use :placeholder
    b.optional :maxlength
    b.optional :minlength
    b.optional :pattern
    b.optional :min_max
    b.optional :readonly
    b.use :label, class: "block text-sm font-medium text-gray-700 mb-1"
    b.use :input,
          class: "w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-transparent",
          error_class: "border-red-500",
          valid_class: ""
    b.use :hint,  wrap_with: { tag: :p, class: "mt-1 text-xs text-gray-500" }
    b.use :error, wrap_with: { tag: :p, class: "mt-1 text-xs text-red-600" }
  end

  config.wrappers :check_box, tag: :div, class: "mb-4 flex items-center gap-2" do |b|
    b.use :html5
    b.use :input, class: "h-4 w-4 text-indigo-600 border-gray-300 rounded"
    b.use :label, class: "text-sm text-gray-700"
    b.use :hint,  wrap_with: { tag: :p, class: "mt-1 text-xs text-gray-500" }
    b.use :error, wrap_with: { tag: :p, class: "mt-1 text-xs text-red-600" }
  end

  config.default_wrapper     = :default
  config.boolean_style       = :inline
  config.button_class        = "py-2 px-4 bg-indigo-600 hover:bg-indigo-700 text-white font-medium rounded-lg text-sm transition-colors duration-150 cursor-pointer"
  config.error_notification_tag   = :div
  config.error_notification_class = "mb-4 p-3 bg-red-50 border border-red-200 text-red-700 text-sm rounded-lg"
  config.browser_validations      = false
  config.boolean_label_class      = nil

  config.wrapper_mappings = { boolean: :check_box }
end
