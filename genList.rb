def loadDict
  dictFile = File.new("dict.u8", "r")
  entries = []
  count = 0
  print("Loading dictionary...\n")
  max = 0
  lengths = []
  while (line = dictFile.gets) do
    if line.start_with?("#")
      next
    else
      definitions = line.match(/\/.*\//).to_s.split("/")
      definitions.delete("")
      line.sub!(/\/.*\//, '')

      pinyin = line.match(/\[[ 0-9a-z]*\]/).to_s
      pinyin.delete("[")
      pinyin.delete("]")
      line.sub!(/\[[ 0-9a-z]*\]/,'')

      tokens = line.strip().split(" ")

      tokens.push(pinyin)
      tokens.push(definitions)

      entries.push(tokens)

      if max < tokens[0].length
        print(tokens[0])
        max = tokens[0].length
        lengths.push(max)
      end

      count += 1
      print("\b\b\b\b#{count * 100 / 114852}%")
    end
  end
  print("\nFound words of sizes: #{lengths}\n")

  return entries
end


entries = loadDict
