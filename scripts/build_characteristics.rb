require "bundler/setup"
require "yaml"
require "fileutils"
require "medcon"

CHARACTERISTICS_BASE_PATH = "characteristics".freeze
TRANSLATIONS_BASE_PATH    = "translations".freeze
ADDITIONAL_LANGUAGES      = %w[fr].freeze

def handle_groups(groups, groups_by_parent_id, conditions_by_id, additional_medcons, parents)
  groups.each do |group|
    group.condition_ids.each do |condition_id|
      condition = conditions_by_id[condition_id]

      condition_data = {
        "id" => condition.code.to_i,
        "label" => condition.label,
        "description" => condition.help,
        "type" => condition.type.to_s.downcase,
        "tags" => [*parents, group.label],
        "codes" => [{ "nomenclature" => "SYADEM", "code" => condition.id }]
      }

      File.write("#{CHARACTERISTICS_BASE_PATH}/C-#{condition.code}.yml", condition_data.to_yaml(line_width: -1))

      additional_medcons.each do |lang, medcon|
        translated_condition = medcon.repositories.conditions.find(condition_id)

        translation_data = {
          "label" => translated_condition.label,
          "description" => translated_condition.help
        }

        File.write("#{TRANSLATIONS_BASE_PATH}/#{lang}/C-#{condition.code}.yml", translation_data.to_yaml(line_width: -1))
      end
    end

    children = groups_by_parent_id[group.id]

    next if children.nil?

    handle_groups(children, groups_by_parent_id, conditions_by_id, additional_medcons, [*parents, group.label])
  end
end

medcon             = Medcon::Medcon.load(lang: "en")
additional_medcons = ADDITIONAL_LANGUAGES.each_with_object({}) { |lang, obj| obj[lang] = Medcon::Medcon.load(lang:) }

FileUtils.rm_rf(CHARACTERISTICS_BASE_PATH)
FileUtils.rm_rf(TRANSLATIONS_BASE_PATH)
FileUtils.mkdir_p(CHARACTERISTICS_BASE_PATH)
ADDITIONAL_LANGUAGES.each { |lang| FileUtils.mkdir_p("#{TRANSLATIONS_BASE_PATH}/#{lang}") }

conditions_by_id    = medcon.repositories.conditions.all.map { |c| [c.id, c] }.to_h
groups_by_parent_id = medcon.repositories.condition_groups.all.group_by(&:parent_id)
root_groups         = groups_by_parent_id[""]

handle_groups(root_groups, groups_by_parent_id, conditions_by_id, additional_medcons, [])
