RSpec.describe ShortenedUrl, type: :model do
  let(:original_url) { Faker::Internet.url }
  let(:shortened_url_id) { Digest::MD5.hexdigest original_url }
  describe 'validations' do
    it 'is valid with valid attributes' do
      shortened_url = ShortenedUrl.new(shortened_url_id: shortened_url_id, original_url: original_url)
      expect(shortened_url).to be_valid
    end

    it 'is not valid without a shortened_url_id' do
      user = ShortenedUrl.new(original_url: original_url)
      expect(user).not_to be_valid
    end

    it 'is not valid without an original_url' do
      user = ShortenedUrl.new(shortened_url_id: shortened_url_id)
      expect(user).not_to be_valid
    end
  end

  describe '#encrypted_url' do
    it 'returns the url encrypted with MD5 algorithm' do
      expect(described_class.encrypted_url(original_url)).to eq shortened_url_id
    end
  end

  describe '#find_shortened_url_id_by_original' do
    context 'when url is present in database' do
      before { ShortenedUrl.create!(original_url: original_url, shortened_url_id: shortened_url_id) }

      it 'returns shortened_url_id' do
        expect(described_class.find_shortened_url_id_by_original(original_url)).to eq shortened_url_id
      end
    end

    context 'when url is not present in database' do
      it 'returns nil' do
        expect(described_class.find_shortened_url_id_by_original(original_url)).to be_nil
      end
    end
  end

  describe '#find_original_url_by_shortened_id' do
    context 'when url is present in database' do
      before { ShortenedUrl.create!(original_url: original_url, shortened_url_id: shortened_url_id) }

      it 'returns shortened_url_id' do
        expect(described_class.find_original_url_by_shortened_id(shortened_url_id)).to eq original_url
      end
    end

    context 'when url is not present in database' do
      it 'returns nil' do
        expect(described_class.find_original_url_by_shortened_id(shortened_url_id)).to be_nil
      end
    end
  end
end
