require "yaml"

BASE_PATH = "characteristics".freeze

def handle_groups(groups, groups_by_parent_id, conditions_by_id, parents)
  groups.each do |group|
    group.condition_ids.each do |condition_id|
      condition = conditions_by_id[condition_id]

      condition_data = {
        "id" => condition.code.to_i,
        "label" => condition.label,
        "type" => condition.type.to_s.downcase,
        "tags" => [*parents, group.label],
        "codes" => [{ "nomenclature" => "SYADEM", "code" => condition.id }]
      }

      File.write("#{BASE_PATH}/C-#{condition.code}.yml", condition_data.to_yaml)
    end

    children = groups_by_parent_id[group.id]

    handle_groups(children, groups_by_parent_id, conditions_by_id, [*parents, group.label]) if children
  end
end

medcon = Medcon::Medcon.load(lang: "fr")

FileUtils.rm_rf(BASE_PATH)
FileUtils.mkdir_p(BASE_PATH)

conditions_by_id    = medcon.repositories.conditions.all.map { |c| [c.id, c] }.to_h
groups_by_parent_id = medcon.repositories.condition_groups.all.group_by(&:parent_id)
root_groups         = groups_by_parent_id[""]

handle_groups(root_groups, groups_by_parent_id, conditions_by_id, [])
