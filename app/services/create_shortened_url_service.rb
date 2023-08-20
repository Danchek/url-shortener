class CreateShortenedUrlService < BaseService
  MAX_RETRIES = 2
  RETRY_DELAY = 1.second

  def perform!(params:)
    url = params[:original_url]
    validate_params(url)
    return if result.error.present?

    shortened_url_id = ShortenedUrl.find_shortened_url_id_by_original(url)
    return result.shortened_url = build_url_from_id(shortened_url_id) if shortened_url_id.present?

    create_new_shortened_url(url)
  end

  private

  def validate_params(url)
    return result.error = 'Missing required parameter "original_url"' if url.blank?
    return result.error = 'URL must be up to 2048 characters' if url.size > 2048
    return if /^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/ix.match?(url)

    result.error = 'URL is incorrect'
  end

  def create_new_shortened_url(url)
    shortened_url_id = ShortenedUrl.encrypted_url(url)



    result.shortened_url = build_url_from_id(shortened_url_id)
  end

  def build_url_from_id(id)
    Rails.application.routes.url_helpers.api_v1_url_shortener_url(id)
  end

  def save_shortened_url(shortened_url_id, url)
    retries = 0

    begin
      # First we try just to create ShortenedUrl, it might fail if in concurrent thread same row has been added,
      # in such case we try to check if such raw already present before trying to create a new one.
      if retries.zero?
        ShortenedUrl.create(shortened_url_id: shortened_url_id, original_url: url)
      else
        ShortenedUrl.find_or_create_by(shortened_url_id: shortened_url_id, original_url: url)
      end
    rescue ActiveRecordError
      if retries < MAX_RETRIES
        retries += 1
        sleep RETRY_DELAY
        retry
      else
        Rails.logger.error("Max retries reached. Failed to complete operation.")
        raise
      end
    end
  end
end
