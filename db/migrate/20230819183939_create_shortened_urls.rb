class CreateShortenedUrls < ActiveRecord::Migration[7.0]
  def change
    create_table :shortened_urls, id: false do |t|
      t.string :shortened_url_id, primary_key: true, index: true
      t.text :original_url, limit: 2048, null: false

      t.timestamps
    end
  end
end
