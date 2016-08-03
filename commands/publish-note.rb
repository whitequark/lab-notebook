usage       'publish-note [note title]'
aliases     :pn
summary     'publishes a draft note'
description 'This command moves a draft note from content/drafts/ to content/notes/'

flag :h, :help,  'show help for this command' do |value, cmd|
  puts cmd.help
  exit 0
end

run do |opts, args, cmd|
  if args.length != 1
    puts "Error: usage: publish-note [note title]"
    exit 1
  end
  title, = *args

  draft_slug  = title.downcase.gsub(/[^a-z0-9]/, '-')
  draft_path  = File.join(File.dirname(__FILE__), '..', 'content', 'drafts', draft_slug + '.md')
  public_slug  = Date.today.to_s + '-' + draft_slug
  public_path = File.join(File.dirname(__FILE__), '..', 'content', 'notes', public_slug + '.md')
  if !File.exists?(draft_path)
    puts "Draft note with this title not found."
    exit 1
  end
  if File.exists?(public_path)
    puts "Refusing to overwrite an existing published note."
    exit 1
  end

  note = File.read(draft_path)
  note.gsub!('kind: draft', "kind: article\ncreated_at: #{Time.now}")
  File.write(public_path, note)
  File.unlink(draft_path)

  puts "Draft published! Try http://localhost:3000/notes/#{Date.today}/#{draft_slug}/"
end
