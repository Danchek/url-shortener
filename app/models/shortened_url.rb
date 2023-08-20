class ShortenedUrl < ApplicationRecord
  after_commit :write_through_cache, on: [:create, :update]

  validates_presence_of :original_url, :shortened_url_id

  def self.encrypted_url(original_url)
    Digest::MD5.hexdigest original_url
  end

  def self.find_shortened_url_id_by_original(original_url)
    encrypted_url_id = encrypted_url(original_url)
    cached_key = "shortened_url:#{encrypted_url_id}"
    cached_data = $redis.then { |r| r.get cached_key }
    return encrypted_url_id if cached_data

    shortened_url = find_by(shortened_url_id: encrypted_url_id)
    return nil if shortened_url.nil?

    $redis.then { |r| r.set cached_key, original_url }
    shortened_url.shortened_url_id
  end

  def self.find_original_url_by_shortened_id(short_url_id)
    cached_key = "shortened_url:#{short_url_id}"
    cached_data = $redis.then { |r| r.get cached_key }
    return cached_data if cached_data

    shortened_url = find_by(shortened_url_id: short_url_id)
    return nil if shortened_url.nil?

    $redis.then { |r| r.set cached_key, shortened_url.original_url }
    shortened_url.original_url
  end

  private

  def write_through_cache
    $redis.then { |r| r.set "shortened_url:#{self.shortened_url_id}", original_url }
    # $redis.set("shortened_url:#{self.shortened_url_id}", original_url)
  end
end
