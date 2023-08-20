RSpec.describe CreateShortenedUrlService, type: :service do
  describe '#call' do
    let(:params) { { original_url: original_url } }
    let(:result) { described_class.call(params: params) }

    context 'when url is a valid url' do
      let(:original_url) { Faker::Internet.url }

      it 'handles high load' do
        num_requests = 200 # Number of concurrent requests

        responses = []
        mutex = Mutex.new

        concurrent_requests = (1..num_requests).map do
          original_url = Faker::Internet.url
          params = { original_url: original_url }

          Thread.new do
            mutex.synchronize { responses << described_class.call(params: params) }
          end
        end

        concurrent_requests.each(&:join)
        expect(responses.all? { |r| r.shortened_url.present? }).to be true
      end

      context 'when url is not present in database' do
        it 'contains shortened url in result' do
          expect(result.shortened_url).to be
        end

        it 'does not contain error' do
          expect(result.error).to be_nil
        end
      end

      context 'when url is present in database' do
        let(:original_url) { Faker::Internet.url }
        let(:shortened_url_id) { ShortenedUrl.encrypted_url(original_url) }

        before { ShortenedUrl.create!(original_url: original_url, shortened_url_id: shortened_url_id) }

        it 'contains shortened url in result' do
          expect(result.shortened_url).to be
        end

        it 'does not create new ShortenedUrl' do
          expect { result }.to change { ShortenedUrl.count }.by 0
        end
      end
    end

    context 'when original url is invalid' do
      context 'when original url is empty' do
        let(:original_url) { nil }
        it 'returns specific error' do
          expect(result.error).to eq 'Missing required parameter "original_url"'
        end

        it 'does not create new ShortenedUrl' do
          expect { result }.to change { ShortenedUrl.count }.by 0
        end
      end

      context 'when original url is too long' do
        let(:original_url) { Faker::Lorem.characters(number: 2049) }
        it 'returns specific error' do
          expect(result.error).to eq 'URL must be up to 2048 characters'
        end

        it 'does not create new ShortenedUrl' do
          expect { result }.to change { ShortenedUrl.count }.by 0
        end
      end

      context 'when original url is invalid' do
        let(:original_url) { Faker::Lorem.characters }
        it 'returns specific error' do
          expect(result.error).to eq 'URL is incorrect'
        end

        it 'does not create new ShortenedUrl' do
          expect { result }.to change { ShortenedUrl.count }.by 0
        end
      end
    end
  end
end
