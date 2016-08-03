usage       'create-note [note title]'
aliases     :cn
summary     'creates a draft note'
description 'This command creates a new note under content/drafts/'

flag :h, :help,  'show help for this command' do |value, cmd|
  puts cmd.help
  exit 0
end

run do |opts, args, cmd|
  if args.length != 1
    puts "Error: usage: create-note [note title]"
    exit 1
  end
  title, = *args

  title_slug = title.downcase.gsub(/[^a-z0-9]/, '-')
  draft_path = File.join(File.dirname(__FILE__), '..', 'content', 'drafts', title_slug + '.md')
  if File.exists?(draft_path)
    puts "Refusing to overwrite an existing draft."
    exit 1
  end

  FileUtils.mkdir_p(File.dirname(draft_path))
  File.write(draft_path, <<-END)
---
kind: draft
title: "#{title}"
tags: []
---

Hi there!
  END

  puts "Draft created! Try http://localhost:3000/drafts/#{title_slug}/"
end
