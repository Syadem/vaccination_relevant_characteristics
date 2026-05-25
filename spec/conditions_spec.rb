# frozen_string_literal: true
require 'json'
require 'yaml'

describe 'The characteristics folder' do
  Dir.glob('characteristics/*').each do |file|
    context "for #{file}" do
      let(:embedding_file) { file.sub('characteristics/', 'embeddings/').sub('.yml', '.json') }

      it 'should be a yml file' do
        expect(File.extname(file)).to eq('.yml')
      end

      it 'should be a valid yml' do
        expect { YAML.load_file(file) }.not_to raise_error
      end

      it 'should match the expected schema' do
        data = YAML.load_file(file)

        expect(data).to have_key('id')
        expect(data['id']).to be_a(Numeric)
        expect(data['id']).to eq(file.split('/').last.split('.').first.split('C-').last.to_i)

        expect(data).to have_key('label')
        expect(data['label']).to be_a(String)
        expect(data['label']).not_to eq('')

        expect(data).to have_key('description')
        expect(data['description']).to(be_a(String).or be_nil)

        expect(data).to have_key('type')
        expect(%w[boolean integer date float]).to include(data['type'])

        expect(data).to have_key('codes')
        expect(data['codes']).to be_a(Array)
        expect(data['codes']).to all(have_key('nomenclature'))
        expect(data['codes']).to all(have_key('code'))

        expect(data).to have_key('tags')
        expect(data['tags']).to be_a(Array)
        expect(data['tags']).to all(be_a(String))
      end

      it 'should have a matching embedding json file' do
        expect(File).to exist(embedding_file)
      end

      it 'should have a valid embedding json' do
        expect { JSON.parse(File.read(embedding_file)) }.not_to raise_error
      end

      it 'should have an embedding vector of 1024 numeric values' do
        embedding = JSON.parse(File.read(embedding_file))

        expect(embedding).to be_a(Array)
        expect(embedding.size).to eq(1024)
        expect(embedding).to all(be_a(Numeric))
      end

      it 'should have a matching yml file in each translations subfolder' do
        Dir.glob('translations/*').each do |directory|
          translation_file = File.join(directory, File.basename(file))

          expect(File).to exist(translation_file)
        end
      end

      it 'should have valid yml files in each translations subfolder' do
        Dir.glob('translations/*').each do |directory|
          translation_file = File.join(directory, File.basename(file))

          expect { YAML.load_file(translation_file) }.not_to raise_error
        end
      end

      it 'should have yml files match the expected schema in each translations subfolder' do
        Dir.glob('translations/*').each do |directory|
          translation_file = File.join(directory, File.basename(file))
          data             = YAML.load_file(translation_file)

          expect(data).to have_key('label')
          expect(data['label']).to be_a(String)
          expect(data['label']).not_to eq('')

          expect(data).to have_key('description')
          expect(data['description']).to(be_a(String).or be_nil)
        end
      end
    end
  end

  it 'should contain uniq ids' do
    ids = Dir.glob('characteristics/*').map { |file| YAML.load_file(file)['id'] }

    expect(ids).to eq(ids.uniq)
  end
end