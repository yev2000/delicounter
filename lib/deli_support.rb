module DeliSupport

  def pretty_time_string(date_time)
    date_time.strftime("%B %d, %Y at %I:%M%P %Z")
  end

end
