class FetchOriginalUrlService < BaseService
  def perform!(params:)
    shortened_url = params[:id]
    validate_shortened_url(shortened_url)
    result.original_url = ShortenedUrl.find_original_url_by_shortened_id(shortened_url)
    result.error = 'Invalid URL' if result.original_url.nil?
  end

  private

  def validate_shortened_url(shortened_url)
    result.error = 'Invalid URL' if shortened_url&.size.to_i != 32
  end
end
