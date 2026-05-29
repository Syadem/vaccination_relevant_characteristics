require 'bundler/setup'
require 'yaml'
require 'fileutils'
require 'medcon'

class MedconDumpCreator
  CONDITION_TYPE_MAPPING = {
    'boolean' => 1,
    'integer' => 4,
    'date' => 2,
    'float' => 3
  }.freeze

  def call(version, lang, time = Time.now)
    db = Medcon::VaccinationProfileDatabase.new({
      generated_at: time,
      locale: lang,
      version:,
      conditions: retrieve_characteristics(lang)
    })

    Medcon::VaccinationProfileDatabase.encode(db)
  end

  private

  def retrieve_characteristics(lang)
    Dir.glob('characteristics/*').map do |path|
      characteristic = YAML.safe_load(File.read(path))
      translations   = retrieve_translations(characteristic, lang)

      Medcon::Condition.new(
        id: characteristic['id'],
        label: translations['label'],
        description: translations['description'],
        type: CONDITION_TYPE_MAPPING[characteristic['type']],
        tags: characteristic['tags'],
        codes: characteristic['codes']
      )
    end
  end

  def retrieve_translations(characteristic, lang)
    return characteristic.slice('label', 'description') if lang == 'en'

    YAML.safe_load(File.read("translations/#{lang}/C-#{characteristic['id']}.yml"))
  end
end

version             = ARGV[0]
major, minor, patch = version.split('.').map(&:to_i)
languages           = ['en', *Dir.glob('*', base: 'translations')]

FileUtils.mkdir_p('release_assets')

languages.each do |lang|
  dump = MedconDumpCreator.new.call({ major:, minor:, patch: }, lang)
  
  File.write("release_assets/#{version}_#{lang}.db", dump)
end