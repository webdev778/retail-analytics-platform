module ApplicationHelper
  def file_extention(file)
    File.extname(file)
  end

  def file_status(file)
    file.status ? file.status : 'will be proceed in few minutes'
  end
end
