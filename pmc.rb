require 'json'
require 'fileutils'

def main(jsonMakefile)

    makeCommands = JSON.parse File.read jsonMakefile
    projectDir = File.dirname(jsonMakefile)

    # Compiler Options
    sourceDir = "#{projectDir}\\#{makeCommands['compilerOptions']['include']}"
    intermediaryDir = File.join(sourceDir, "../", "obj")
    binaryDir = File.join(sourceDir, "../", "bin")
    modName = makeCommands['compilerOptions']['modname']

    #Clean
    if Dir.exist? intermediaryDir
        FileUtils.remove_dir(intermediaryDir)
    end
    if Dir.exist? binaryDir
        FileUtils.remove_dir(binaryDir)
    end

    FileUtils.mkdir_p(intermediaryDir)
    FileUtils.mkdir_p(binaryDir)

    #Read Make
    FileUtils.copy_entry("#{sourceDir}", intermediaryDir)
    Dir[intermediaryDir].reverse_each { |d| Dir.rmdir d if Dir.entries(d).size == 2 }

    tagString = "\t"
    makeCommands['tags'].each do |tag|
        tagString += " #{tag}"
    
    open("#{intermediaryDir}/descriptor.mod", "w") do |f|
        f.puts "name=#{makeCommands['compilerOptions']['title']}"
        f.puts "archive=mod/#{modName}.zip"
        f.puts "tags="
        f.puts '{'
        f.puts "#{makeCommands['tags']}"
        f.puts '}'
        f.puts "picture=#{makeCommands['compilerOptions']['picture']}"
    end

    open("#{binaryDir}/#{modName}.mod", "w") do |f|
        f.puts "name=#{makeCommands['compilerOptions']['title']}"
        f.puts "archive=mod/#{modName}.zip"
        f.puts "tags="
        f.puts '{'
        makeCommands['tags'].each do |tag|
            tagString+
        f.puts "#{makeCommands['tags']}"
        f.puts '}'
        f.puts "picture=#{makeCommands['compilerOptions']['picture']}"
    end

    Dir.chdir binaryDir

    puts "7z a -tzip #{modName}.zip @#{sourceDir}/../srclist.txt -o#{binaryDir}"
    `7z a -tzip #{modName}.zip #{intermediaryDir}/*`

    FileUtils.cp_r('./', makeCommands['compilerOptions']['deployDir'])
    
    #Clean
    if Dir.exist? intermediaryDir
        FileUtils.remove_dir(intermediaryDir)
    end
    if Dir.exist? binaryDir
        FileUtils.remove_dir(binaryDir)
    end
end

main(ARGV[0])