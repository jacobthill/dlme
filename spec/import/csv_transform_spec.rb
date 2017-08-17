# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Transforming CSV files' do
  let(:indexer) do
    Traject::Indexer.new('exhibit_slug' => slug).tap do |i|
      i.load_config_file('lib/traject/csv_config.rb')
    end
  end
  let(:fixture_file_path) { File.join(fixture_path, 'csv/met.csv') }
  let(:data) { File.open(fixture_file_path).read }
  let(:exhibit) { create(:exhibit) }
  let(:slug) { exhibit.slug }

  it 'does the transform' do
    expect { indexer.process(data) }.to change { DlmeJson.count }.by(3)
    dlme = DlmeJson.last.json
    expect(dlme['id']).to eq [321_383]
    expect(dlme['cho_title']).to eq ['Stamp seal']
  end
end