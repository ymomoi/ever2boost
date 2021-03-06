require 'rexml/document'
require 'ever2boost/util'

module Ever2boost
  class EnexConverter
    class << self
      def convert(enex, output_dir, filename)
        puts 'converting...'
        en_notes = parse_plural_notes(enex, output_dir)
        notebook_list = [NoteList.new(title: filename)]
        JsonGenerator.output(notebook_list, output_dir)
        en_notes.each do |note|
          puts "converting #{note.title}"
          CsonGenerator.output(notebook_list.first.hash, note, output_dir)
        end
        puts Util.green_output("The notes are created at #{output_dir}")
      end

      # enex: String
      #   "<?xml>(.*)</en-export>"
      # return: Array
      #   include Note objects
      #   note.content = "<note>(.*)</note>"
      # comment:
      #   A .enex file include plural ntoes. Thus I need to handle separation into each note.
      def parse_plural_notes(enex, output_dir)
        REXML::Document.new(enex).elements['en-export'].map do |el|
          if el != "\n"
            xml_document = REXML::Document.new(el.to_s).elements
            created_at = xml_document['note/created'].text.sub(%r{^(\d{4})(\d{2})(\d{2})T(\d{2})(\d{2})(\d{2}).*$}, '\1-\2-\3T\4:\5:\6')
            updated_at = xml_document['note/updated'].text.sub(%r{^(\d{4})(\d{2})(\d{2})T(\d{2})(\d{2})(\d{2}).*$}, '\1-\2-\3T\4:\5:\6')
            content = xml_document['note/content/text()'].to_s.sub(/(<\?xml(.*?)\?>)?(.*?)<\!DOCTYPE(.*?)>/m, '')
            Note.new({
              title: xml_document['note/title'].text,
              content: "<div>#{content}</div>",
              created_at: created_at,
              updated_at: updated_at,
              output_dir: output_dir,
            })
          end
        end.compact.flatten
      end
    end
  end
end
