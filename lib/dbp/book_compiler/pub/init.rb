require 'pathname'
require 'rake'
require 'rake/file_utils'
require 'dbp'
require 'dbp/book_compiler/util/cli'

module DBP
  module BookCompiler
    module Pub
      class Init
        include BookCompiler::CLI
        include FileUtils

        TEMPLATES_DIR = DBP.templates_dir
        COVER_DEFAULT_SOURCE = TEMPLATES_DIR / 'cover.jpg'
        YAML_SOURCE = TEMPLATES_DIR / 'publication.yaml'
        MINIMAL_TEMPLATE = 'minimal'

        def initialize(command = nil)
          super command, 'init'
        end

        def run
          parse_command_line do |operands|
            @book_dir = operands.shift&.instance_eval { |d| Pathname(d) }
          end

          create_publication_dir
          create_yaml
          copy_template if @template
          copy_cover if @cover
          extract_mss if @mss
        end

        def create_publication_dir
          return if publication_dir.directory?
          publication_dir.mkpath
          puts 'Created directory', "   #{publication_dir}"
        end

        def extract_mss
          sh 'scriv2tex', mss_source.to_s, publication_dir.to_s
          puts 'Extracted manuscript', "   from #{mss_source}", "   into #{publication_dir}/manuscript"
        end

        def create_yaml
          return puts "Already present, left unchanged: #{yaml_dest}" if yaml_dest.file?
          FileUtils.cp YAML_SOURCE.to_s, yaml_dest.to_s
          puts 'Created file', "   #{yaml_dest}"
        end

        def copy_cover
          cover_dest.dirname.mkpath
          FileUtils.cp cover_source.to_s, cover_dest.to_s
          puts 'Copied cover image', "   from #{cover_source}", "   to #{cover_dest}"
        end

        def copy_template
          [MINIMAL_TEMPLATE, template_name].uniq.each do |template_name|
            template_dir = template_dir(template_name)
            FileUtils.cp_r "#{template_dir}/.", publication_dir.to_s
            puts "Copied #{template_name} template files", "   from #{template_dir}", "   to #{publication_dir}"
          end
        end

        def list_templates
          TEMPLATES_DIR.each_child.select(&:directory?).each { |e| puts "   #{e.basename}" }
        end

        def declare_options(parser)
          parser.banner << ' [BOOK_DIR]'

          parser.on('--cover [IMAGE_FILE]', Pathname, 'copy the ebook cover image') do |image_file|
            @cover = true
            @cover_source = image_file
          end

          parser.on('--mss [SCRIVENER_FILE]', Pathname, 'extract the mss from the Scrivener file') do |scrivener_file|
            @mss = true
            @mss_source = scrivener_file
          end

          parser.on('--template [NAME]', 'copy files from the template') do |name|
            @template = true
            @template_name = name
          end

          parser.on('--source DIR', Pathname, 'look in DIR for book mss and cover files') do |dir|
            @source_dir = dir
          end

          parser.on('--force', 'write into existing publication directory') do |force|
            @force = force
          end

          parser.on('--list', 'list available templates and exit') do |_|
            list_templates
            exit
          end
        end

        def check_options(errors)
          check_publication_dir(errors)
          check_cover_source(errors) if @cover
          check_mss_source(errors) if @mss
          check_template(errors) if @template
          check_yaml_dest(errors)
        end

        def check_cover_source(errors)
          return errors << "No such image file: #{cover_source}" unless cover_source.exist?
          errors << "Invalid image file: #{cover_source}" unless cover_source.file?
        end

        def check_mss_source(errors)
          return errors << "No such scrivener file: #{mss_source}" unless mss_source.exist?
          scrivx = mss_source / mss_source.basename.sub_ext('.scrivx')
          errors << "Invalid scrivener file: #{mss_source}" unless scrivx.file?
        end

        def check_publication_dir(errors)
          return unless publication_dir.exist?
          return errors << "Invalid publication directory: #{publication_dir}" unless publication_dir.directory?
          return if @force
          errors << "Use --force to write into existing directory: #{publication_dir}" if publication_dir.directory?
        end

        def check_source_dir(errors)
          return errors << "No such source directory: #{source_dir}" unless source_dir.exist?
          errors << "Invalid source directory: #{source_dir}" unless source_dir.directory?
        end

        def check_template(errors)
          errors << "No such template: #{template_name}" unless template_dir(template_name).directory?
        end

        def check_yaml_dest(errors)
          return unless yaml_dest.exist?
          errors << "Existing publication.yaml file invalid: #{yaml_dest}" unless yaml_dest.file?
        end

        def book_dir
          @book_dir ||= Pathname.pwd
        end

        def cover_dest
          @cover_dest ||= publication_dir / 'epub/publication/cover.jpg'
        end

        def cover_source
          @cover_source ||= source_dir_cover || COVER_DEFAULT_SOURCE
        end

        def mss_source
          @mss_source ||= source_dir_mss
        end

        def publication_dir
          @publication_dir ||= book_dir / 'publication'
        end

        def slug
          @slug ||= source_dir.basename
        end

        def source_dir
          @source_dir ||= book_dir
        end

        def source_dir_cover
          [source_dir / 'covers' /"#{slug}-cover-2400.jpg"].select(&:file?).first
        end

        def source_dir_mss
          source_dir / 'mss' / slug.sub_ext('.scriv')
        end

        def template_dir(template_name)
          TEMPLATES_DIR / template_name
        end

        def template_name
          @template_name ||= MINIMAL_TEMPLATE
        end

        def yaml_dest
          @yaml_dest ||= publication_dir / 'publication.yaml'
        end
      end
    end
  end
end
