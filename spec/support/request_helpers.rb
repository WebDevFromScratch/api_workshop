module RequestHelpers
  def json
    JSON.parse(last_response.body)
  end

  def xml
    Hash.from_xml(last_response.body)
  end
end
