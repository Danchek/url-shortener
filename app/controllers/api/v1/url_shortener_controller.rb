class Api::V1::UrlShortenerController < ApplicationController
  def create
    result = CreateShortenedUrlService.call(params: params)
    if result.error.nil?
      render json: { short_url: result.shortened_url }.to_json
    else
      render json: { error: result.error }.to_json, status: :unprocessable_entity
    end
  end

  def show
    result = FetchOriginalUrlService.call(params: params)
    if result.error.nil?
      render json: { original_url: result.original_url }
    else
      render json: { error: result.error }, status: :unprocessable_entity
    end
  end
end
