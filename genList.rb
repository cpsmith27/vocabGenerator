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

def search(entries, item)
  if (item != nil && item.length <= 20)
    entries[item.length].each do |entry|
      if (entry["simplified"] == item)
        return entry
      end
    end
  end

  return nil
end

def getVocabItems(entries, line)
  groups = line.scan(/\p{Han}*/)
  vocabItems = {}

  groups.each do |group|
    i = 0;
    while i < group.length
      j = i + 19
      while j >= i
        if j >= group.length
          j = group.length - 1
          next
        end

        entry = search(entries, group[i..j])

        if (entry != nil)
          if (!vocabItems.has_key?(entry["simplified"]))
            vocabItems[entry["simplified"]] = entry
          end
          break
        end

        j = j - 1
      end

      i = j + 1
    end
  end

  return vocabItems
end

def getVocabFromFile(filePath)
  dict = loadYAML
  file = File.new(filePath, "r")

  vocabItems = {}
  while (line = file.gets)
    lineItems = getVocabItems(dict, line)
    vocabItems.merge!(lineItems)
  end

  return vocabItems
end

def genHTML(file)
  vocab = getVocabFromFile(file)

  print(
"<!DOCTYPE HTML>
<html>
  <head>
    <title>Vocabulary from file \"#{file}\".</title>
    <script src=\"https://ajax.googleapis.com/ajax/libs/jquery/3.1.0/jquery.min.js\"></script>
    <link rel=\"stylesheet\" type=\"text/css\" href=\"vocab.css\">
    <script src=\"vocab.js\"></script>
  </head>
  <body>
    <div id=\"vocab-container\">")

  vocab.each_value do |item|
    hasTraditional = item["traditional"] != nil

    print("
      <div class=\"vocab-item\">
        <span class=\"character\">#{item["simplified"]} [#{item["traditional"]}]</span>
        <span class=\"pinyin\">#{item["pinyin"]}</span>
        <span class=\"definitions\">#{item["definitions"].join("<br>")}</span>
      </div>")
  end

  print("
    </div>
  </body>
</html>
")
end

genHTML(ARGV[0])
