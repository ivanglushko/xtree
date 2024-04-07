class String
	def colorize(color_code)
		"\e[38;5;#{color_code}m#{self}\e[0m"
	end
end

BUMP_TYPE = ARGV[0]
unless /^(major|minor|patch)$/.match?(BUMP_TYPE)
	abort("Please, pass one of these major/minor/patch bump type.".colorize(9))
end

VERSION_FILE = 'Sources/XTree/CLI/Commands/Common/Environment.swift'
CONTENT = File.read(VERSION_FILE)
VERSION = CONTENT.match(/version\s=\s"([0-9]{1,2}\.[0-9]{1,2}\.[0-9]{1,2})"/).captures.first.chomp
VERSION_PARTS = VERSION.split(".").map(&:to_i)

if BUMP_TYPE == "major"
	VERSION_PARTS[0] += 1
	VERSION_PARTS[1] = 0
	VERSION_PARTS[2] = 0
elsif BUMP_TYPE == "minor"
	VERSION_PARTS[1] += 1
	VERSION_PARTS[2] = 0
elsif BUMP_TYPE == "patch"
	VERSION_PARTS[2] += 1
end
NEW_VERSION = VERSION_PARTS.join(".")

# Update version in XTree.swift for ArgumentParser
%x[sed -i '' 's/#{VERSION}/#{NEW_VERSION}/g' #{VERSION_FILE}]
# Add bump commit
%x[git commit -i #{VERSION_FILE} -m "[skip ci] Bump version #{NEW_VERSION}"]

puts NEW_VERSION
