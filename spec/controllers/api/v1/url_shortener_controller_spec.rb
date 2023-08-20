RSpec.describe Api::V1::UrlShortenerController, type: :controller do
  describe 'POST #create' do
    context 'when parameters are valid' do
      let(:original_url) { Faker::Internet.url }
      let(:shortened_url_id) { ShortenedUrl.encrypted_url(original_url) }
      it 'succeeds' do
        post :create, params: { original_url: original_url }, xhr: true

        expect(response).to have_http_status(:success)
        expect(response.content_type).to include 'application/json'

        json_response = JSON.parse(response.body)
        expect(json_response['short_url']).to include shortened_url_id
      end
    end

    context 'when parameters are invalid' do
      let(:original_url) { nil }
      it 'returns an error' do
        post :create, params: { original_url: original_url }, xhr: true

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to include 'application/json'

        json_response = JSON.parse(response.body)
        expect(json_response).to have_key('error')
      end
    end
  end


  describe 'GET #show' do
    context 'when parameters are valid' do
      let(:original_url) { Faker::Internet.url }
      let(:shortened_url_id) { ShortenedUrl.encrypted_url(original_url) }

      before { ShortenedUrl.create!(shortened_url_id: shortened_url_id,  original_url: original_url) }

      it 'succeeds' do
        get :show, params: { id: shortened_url_id }, xhr: true

        expect(response).to have_http_status(:success)
        expect(response.content_type).to include 'application/json'

        json_response = JSON.parse(response.body)
        expect(json_response['original_url']).to include original_url
      end
    end

    context 'when there is no shortened url with such id' do
      let(:original_url) { Faker::Internet.url }
      let(:shortened_url_id) { ShortenedUrl.encrypted_url(original_url) }

      it 'returns an error' do
        get :show, params: { id: shortened_url_id }, xhr: true

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to include 'application/json'

        json_response = JSON.parse(response.body)
        expect(json_response).to have_key('error')
      end
    end
  end
end
