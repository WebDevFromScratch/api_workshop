module RequestHelpers
  def json
    @json ||= JSON.parse(last_response.body)
  end
end
