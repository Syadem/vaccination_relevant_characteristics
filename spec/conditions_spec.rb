# frozen_string_literal: true
require 'yaml'

describe 'The characteristics folder' do
  Dir.glob('characteristics/**/*').each do |file|
    it "contain only yml and folder (#{file})" do
      expect(File.extname(file)).to eq('.yml').or eq('')
    end
  end

  describe 'yml files' do
    Dir.glob('characteristics/**/*.yml').each do |file|
      context "(#{file})" do
        it "are valid yml files" do
          expect { YAML.load_file(file) }.not_to raise_error
        end
      end
    end

    describe 'schema' do
      Dir.glob('characteristics/**/*.yml').each do |file|
        context "for #{file}" do
          it "has the correct schema" do
            data = YAML.load_file(file)
            expect(data).to have_key('id')
            expect(data['id']).to be_a(Numeric)
            expect(data['id']).to eq(file.split('/').last.split('.').first.split('C-').last.to_i)
            expect(data).to have_key('label')
            expect(data['label']).to be_a(String)
            expect(data['label']).not_to eq('')

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
        end
      end
    end
  end

  describe 'data' do
    it 'has unique ids' do
      ids = Dir.glob('characteristics/**/*.yml').map do |file|
        YAML.load_file(file)['id']
      end
      expect(ids).to eq(ids.uniq)
    end
  end
end
