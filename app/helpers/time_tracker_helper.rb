module TimeTrackerHelper
  def time_entry_title(time_entry)
    str = "[#{time_entry.hours}] #{time_entry.project.name}/#{time_entry.issue.try(:subject)}"
    unless time_entry.comments.blank?
      str += "(#{time_entry.comments})"
    end
    str.html_safe
  end

  def time_entry_width(hours, scale, border = 0)
    if hours.is_a? TimeEntry
      hours = hours.hours
    end
    width = hours  * scale - border * 2
    width = 0 if width < 0
    "#{width}px".html_safe
  end

  def time_entry_div(time_entry, options)
    %{<div class="entry" title="#{time_entry_title(time_entry)}"
      style="width: #{time_entry_width(time_entry, options[:scale], 1)}; border: solid 1px;">
      #{time_entry_title(time_entry)}</div>}.html_safe
  end
  
  def empty_div(hours, text, options)
    options[:border] ||= 0
    %{<div class="entry" style="width: #{time_entry_width(hours, options[:scale], options[:border])}; #{options[:style]}">#{text}</div>}.html_safe
  end
end
