module ApplicationHelper
  def file_extention(file)
    File.extname(file)
  end

  def file_status(file)
    file.status ? file.status : 'will be proceed in few minutes'
  end

  def bootstrap_class_for(flash_type)
    classes_list = { success: 'alert-success',
                     error: 'alert-danger',
                     alert: 'alert-warning',
                     notice: 'alert-info' }
    classes_list[flash_type.to_sym] || flash_type.to_s
  end

  def flash_messages(opts = {})
    # alert alert-info alert-dismissible
    # alert notice fade in
    flash.each do |msg_type, message|
      concat(content_tag(:div, message, class: "alert #{bootstrap_class_for(msg_type)} fade in") do
        concat content_tag(:button, '×', class: 'close', data: { dismiss: 'alert' })
        concat message
      end)
    end
    nil
  end
end
