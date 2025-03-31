require "yaml"

BASE_PATH = "characteristics".freeze

def handle_groups(groups, groups_by_parent, conditions_by_id, parent_ids)
  groups.each do |group|
    dir_path   = [BASE_PATH, *parent_ids, group.id].join("/")
    group_data = { "id" => group.id, "label" => group.label, "parent_ids" => parent_ids }

    FileUtils.mkdir_p(dir_path)
    File.write("#{dir_path}/group.yml", group_data.to_yaml)

    group.condition_ids.each do |condition_id|
      condition = conditions_by_id[condition_id]

      condition_data = {
        "id" => condition.code.to_i,
        "group_id" => group.id,
        "label" => condition.label,
        "type" => condition.type.to_s.downcase,
        "codes" => [{ "nomenclature" => "SYADEM", "code" => condition.id }]
      }

      File.write("#{dir_path}/C-#{condition.code}.yml", condition_data.to_yaml)
    end

    children = groups_by_parent[group.id]

    handle_groups(children, groups_by_parent, conditions_by_id, [*parent_ids, group.id]) if children
  end
end

medcon = Medcon::Medcon.load(lang: "fr")

FileUtils.rm_rf(BASE_PATH)

conditions_by_id = medcon.repositories.conditions.all.map { |c| [c.id, c] }.to_h
groups_by_parent = medcon.repositories.condition_groups.all.group_by(&:parent_id)
root_groups      = groups_by_parent[""]

handle_groups(root_groups, groups_by_parent, conditions_by_id, [])
