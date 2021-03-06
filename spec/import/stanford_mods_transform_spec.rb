# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Transforming MODS files' do
  let(:indexer) { Pipeline.for('stanford_mods').indexer(HarvestedResource.new(original_filename: fixture_file_path)) }
  let(:data) { File.open(fixture_file_path) }
  let(:exhibit) { create(:exhibit) }
  let(:slug) { exhibit.slug }

  before do
    indexer.settings['exhibit_slug'] = slug
    allow(CreateResourceJob).to receive(:perform_later)
  end

  describe 'Transform MODS Manuscript file' do
    let(:identifier) { 'stanford_tk780vf9050' }
    let(:fixture_file_path) { File.join(fixture_path, 'mods/stanford_tk780vf9050.mods') }

    it 'does the transform' do
      indexer.process(data)
      expect(CreateResourceJob).to have_received(:perform_later) do |_id, _two, json|
        dlme = JSON.parse(json)
        expect(dlme['id']).to eq 'stanford_tk780vf9050'
        expect(dlme['agg_data_provider']).to eq 'Stanford Libraries'
        expect(dlme['agg_is_shown_at']).to include('wr_id' => 'https://purl.stanford.edu/tk780vf9050')
        expect(dlme['agg_is_shown_by']).to include('wr_description' => ['reformatted digital', 'access'],
                                                   'wr_format' => ['image/jpeg', 'image/tiff'],
                                                   'wr_has_service' => [{ 'service_id' =>
                                                                         'https://stacks.stanford.edu/image/iiif/tk780vf9050%2FW586_000001_300',
                                                                          'service_conforms_to' => ['http://iiif.io/api/image/'],
                                                                          'service_implements' =>
                                                                         'http://iiif.io/api/image/2/level1.json' }],
                                                   'wr_id' =>
                                                   'https://stacks.stanford.edu/image/iiif/tk780vf9050%2FW586_000001_300/full/full/0/default.jpg',
                                                   'wr_is_referenced_by' =>
                                                   ['https://purl.stanford.edu/tk780vf9050/iiif/manifest'])
        expect(dlme['agg_preview']).to include('wr_format' => ['image/jpeg', 'image/tiff'],
                                               'wr_has_service' => [{ 'service_id' =>
                                                                     'https://stacks.stanford.edu/image/iiif/tk780vf9050%2FW586_000001_300',
                                                                      'service_conforms_to' => ['http://iiif.io/api/image/'],
                                                                      'service_implements' =>
                                                                     'http://iiif.io/api/image/2/level1.json' }],
                                               'wr_id' =>
                                               'https://stacks.stanford.edu/image/iiif/tk780vf9050%2FW586_000001_300/full/!400,400/0/default.jpg',
                                               'wr_is_referenced_by' => ['https://purl.stanford.edu/tk780vf9050/iiif/manifest'])
        expect(dlme['agg_provider']).to eq 'Stanford Libraries'
        expect(dlme['cho_alternative']).to eq ['al-Shifāʾ fī taʿrīf ḥuqūq al-Muṣṭafá', 'الشفاء في تعريف حقوق المصطفى']
        expect(dlme['cho_contributor']).to eq ['Salīm al-Rashīd']
        expect(dlme['cho_creator']).to eq ['Abū al-Faḍl ʿIyāḍ ibn Mūsá al-Yaḥṣubī al-Bāhilī',
                                           'ʿIyāḍ al-Yaḥṣubī (d. 544 AH / 1149 CE)',
                                           'ابو الفضل عياض بن موسى اليحصبي الباهلي']

        expect(dlme['cho_date']).to eq ['1777']
        expect(dlme['cho_description'].first).to start_with 'This manuscript is an illuminated copy'
        expect(dlme['cho_dc_rights'].first).to start_with 'Licensed for use'
        expect(dlme['cho_edm_type']).to eq ['text']
        expect(dlme['cho_format']).to eq ['paper', 'Laid paper']
        expect(dlme['cho_has_part']).to eq ['al-Shifāʾ fī taʿrīf ḥuqūq al-Muṣṭafá', 'الشفاء في تعريف حقوق المصطفى']
        expect(dlme['cho_is_part_of']).to eq ['Walters Manuscripts']
        expect(dlme['cho_language']).to eq ['Arabic']
        expect(dlme['cho_title']).to eq ['Walters Ms. W.586, Work on the duties of Muslims toward the ' \
                                        'Prophet Muhammad with an account of his life']
        expect(dlme['cho_type']).to eq ['mixed material']
      end
    end

    context 'with duplicate values' do
      let(:data) do
        '<?xml version="1.0" encoding="UTF-8"?>
        <mods xmlns="http://www.loc.gov/mods/v3">
          <titleInfo>
            <title>My title</title>
            <partNumber>My title</title>
            <partName>My subtitle</partName>
            <subTitle>My subtitle</subTitle>
          </titleInfo>
        </mods>'
      end
      let(:writer) { instance_double Traject::JsonWriter, put: '' }

      before do
        indexer.settings['writer_class_name'] = 'Traject::JsonWriter'
        allow(Traject::JsonWriter).to receive(:new).and_return(writer)
      end

      it 'deduplicates' do
        indexer.process(data)
        expect(writer).to have_received(:put) do |context|
          dlme = context.output_hash
          expect(dlme['cho_title']).to eq ['My title', 'My subtitle']
        end
      end
    end
  end

  describe 'Transform MODS Geodata file' do
    let(:identifier) { 'stanford_maps/records/stanford/bg149mk9437' }
    let(:fixture_file_path) { File.join(fixture_path, 'mods/stanford_bg149mk9437.mods') }

    it 'does the transform' do
      indexer.process(data)
      expect(CreateResourceJob).to have_received(:perform_later) do |_id, _two, json|
        dlme = JSON.parse(json)

        expect(dlme['id']).to eq 'stanford_bg149mk9437'
        expect(dlme['agg_is_shown_at']).to include('wr_id' => 'https://purl.stanford.edu/bg149mk9437')
        expect(dlme['cho_coverage']).to eq ['2013', 'Washington, DC, US']
        expect(dlme['cho_edm_type']).to eq %w[cartographic software]
        expect(dlme['cho_format']).to eq ['Shapefile']
        expect(dlme['cho_has_type']).to eq ['Geospatial data',
                                            'cartographic dataset',
                                            'application/x-esri-shapefile; format=Shapefile']
        expect(dlme['cho_identifier']).to eq ['edu.stanford.purl:bg149mk9437']
        expect(dlme['cho_is_part_of']).to eq ['https://purl.stanford.edu/zy496qj4689']
        expect(dlme['cho_publisher']).to eq ['United States. Department of State. Humanitarian Information Unit']
        expect(dlme['cho_spatial']).to eq ['(E 35°29ʹ28ʺ--E 45°36ʹ37ʺ/N 38°20ʹ24ʺ--N 31°54ʹ40ʺ)',
                                           'EPSG::4326',
                                           'Scale not given.',
                                           'Iraq',
                                           'Turkey',
                                           'Jordan',
                                           'Syria']
        expect(dlme['cho_subject']).to eq ['Refugee camps', 'Refugee', 'Location', 'Society']
        expect(dlme['cho_temporal']).to eq ['2013']
        expect(dlme['cho_type']).to eq ['cartographic', 'software, multimedia', 'Dataset#Point']
      end
    end
  end
end
