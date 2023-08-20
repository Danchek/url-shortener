RSpec.describe FetchOriginalUrlService, type: :service do
  describe '#call' do
    let(:original_url) { Faker::Internet.url }
    let(:shortened_url_id) { ShortenedUrl.encrypted_url(original_url) }
    let(:params) { { id: shortened_url_id } }
    let(:result) { described_class.call(params: params) }

    context 'when shortened_url_id is valid' do
      before { ShortenedUrl.create!(shortened_url_id: shortened_url_id, original_url: original_url) }

      it 'return original url' do
        expect(result.original_url).to eq original_url
      end

      it 'does not contain an error' do
        expect(result.error).to be_nil
      end
    end

    context 'when shortened_url_id is invalid' do
      context 'when shortened_url_id is empty' do
        let(:shortened_url_id) { nil }

        before do
          ShortenedUrl.create!(shortened_url_id: ShortenedUrl.encrypted_url(original_url), original_url: original_url)
        end

        it 'returns specific error' do
          expect(result.error).to eq 'Invalid URL'
        end
      end

      context 'when shortened_url_id is incorrect' do
        let(:shortened_url_id) { Faker::Lorem.characters(number: 30) }

        before do
          ShortenedUrl.create!(shortened_url_id: ShortenedUrl.encrypted_url(original_url), original_url: original_url)
        end

        it 'returns specific error' do
          expect(result.error).to eq 'Invalid URL'
        end
      end

      context 'when there is no ShortenedUrl with such shortened_url_id in the database' do
        it 'returns specific error' do
          expect(result.error).to eq 'Invalid URL'
        end
      end
    end
  end
end
