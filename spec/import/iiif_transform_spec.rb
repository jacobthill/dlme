# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Transforming IIIF files' do
  let(:indexer) do
    Traject::Indexer.new('identifier' => identifier, 'exhibit_slug' => slug).tap do |i|
      i.load_config_file('lib/traject/iiif_config.rb')
    end
  end
  let(:identifier) { 'stanford_tk780vf9050' }
  let(:fixture_file_path) { File.join(fixture_path, 'iiif/manifest.json') }
  let(:data) { File.open(fixture_file_path).read }
  let(:exhibit) { create(:exhibit) }
  let(:slug) { exhibit.slug }

  it 'does the transform' do
    expect { indexer.process(data) }.to change { DlmeJson.count }.by(1)
    dlme = DlmeJson.last.json
    expect(dlme['id']).to eq ['stanford_tk780vf9050']
    expect(dlme['cho_title']).to eq ['Walters Ms. W.586, Work on the duties of Muslims toward the ' \
                                     'Prophet Muhammad with an account of his life']
  end
end