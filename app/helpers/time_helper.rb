# frozen_string_literal: true
module TimeHelper
  def timeago(time)
    content_tag(:span, time&.iso8601, title: time&.iso8601, class: 'timeago-js')
  end
end
