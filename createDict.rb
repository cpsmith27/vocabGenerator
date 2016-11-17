require 'yaml'

def loadDict
  dictFile = File.new("dict.u8", "r")
  entries = {}
  while (line = dictFile.gets) do
    if line.start_with?("#")
      next
    else
      definitions = line.match(/\/.*\//).to_s.split("/")
      definitions.delete("")
      line.sub!(/\/.*\//, '')

      pinyin = line.match(/\[.*\]/).to_s
      pinyin.sub!(/\[/, '')
      pinyin.sub!(/\]/, '')
      line.sub!(/\[.*\]/,'')

      tokens = line.strip().split(" ")

      if !entries.has_key?(tokens[0].length)
        entries[tokens[0].length] = []
      end

      entry = {
        "traditional" => tokens[0],
        "simplified" => tokens[1],
        "pinyin" => pinyin,
        "definitions" => definitions
      }

      entries[tokens[0].length].push(entry)
    end
  end

  return entries
end

def loadYAML
  entries = YAML::load_file "dict.yaml"
  return entries
end

entries = loadYAML

print(entries[20])
