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

      pinyin = line.match(/\[[ ,0-9a-z]*\]/).to_s
      pinyin.sub!(/\[/, '')
      pinyin.sub!(/\]/, '')
      line.sub!(/\[[ ,0-9a-z]*\]/,'')

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
    for i in 0..group.length
      for j in i..19
        break if j >= group.length
        entry = search(entries, group[i..j])
        if (entry != nil && !vocabItems.has_key?(entry["simplified"]))
          vocabItems[entry["simplified"]] = entry
        end
      end
    end
  end

  return vocabItems
end

def getVocabFromFile(filePath)
  dict = loadDict
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
    <style>
      * {
        margin: 0;
        padding: 0;
        font-family: sans-serif;
        box-sizing: border-box;
      }
      html, body {
        width: 100%;
        height: 100%;
      }
      #vocab-container {
        width: 100%;
        height: 100%;
        display: flex;
        flex-wrap: wrap;
        align-items: flex-start;
      }
      .vocab-item {
        flex: 1;
        display: flex;
        flex-direction: column;
        border: 2px solid black;
        margin: 5px;
        padding: 10px;
        text-align: center;
      }
      .character {
        font-size: 24px;
        height: 35px;
        line-height: 35px;
        vertical-align: top;
      }
      .pinyin {
        font-style: italic;
      }
      .definitions {
        display: none;
      }
    </style>
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
