# coding: utf-8

require 'optparse'

module Todo
  class Command
    module Options
      def self.parse!(argv)
        options = {}

        

        #not subcommand argv
        command_parser = create_command_parser
        sub_command_parsers = create_sub_command_parsers(options)

        begin
          command_parser.order!(argv)
          options[:command]=argv.shift
          sub_command_parsers[options[:command]].parse!(argv)

          if %(update delte).include?(options[:command])
            raise ArgumentError,"'#{options[:command]}' id not found." if argv.empty?
            options[:id] = Integer(argv.first)
          end
        rescue OptionParser::MissingArgument,OptionParser::InvalidOption,ArgumentError => e
          abort e.message
        end
        
        options
      end

      private


      def self.create_sub_command_parsers(options)
        #undefined key raise error
        sub_command_parsers = Hash.new do |key,val|
          raise ArgumentError,"'#{val}' is not todo sub command."
        end

        #sub command argvs
        sub_command_parsers['create'] = OptionParser.new do |opt|
          opt.banner = "Usage: create <arg>"
          opt.on("-n VAL","--name=VAL","task name"){ |v| options[:name] = v}
          opt.on("-c VAL","--content=VAL","task content"){ |v| options[:content] = v}
          opt.on_tail('-h','--help','Show this message'){ |v| help_sub_command(opt)}
        end

        sub_command_parsers['list'] = OptionParser.new do |opt|
          opt.banner = 'Usage: list [args]'
          opt.on("-s VAL","--status=VAL",'search status'){ |v| options[:search] = v}
          opt.on_tail('-h','--help','Show this message'){ |v| help_sub_command(opt)}
        end

        sub_command_parsers['update'] = OptionParser.new do |opt|
          opt.banner = "Usage: update id <args>"
          opt.on("-n VAL", "--name=VAL","update name"){|v|option[:name]=v}
          opt.on("-c VAL", "--content=VAL","update content"){|v|option[:content]=v}
          opt.on("-s VAL", "--status=VAL","update status"){|v|option[:status]=v}
          opt.on_tail('-h','--help','Show this message'){|v| help_sub_command(opt)}
        end

        sub_command_parsers['delete'] = OptionParser.new do |opt|
          opt.banner = 'Usage: delete id'
          opt.on_tail('-h','--help','Show this message'){ |v| help_sub_command(opt)}
        end
        sub_command_parsers
      end

      def self.create_command_parser
        OptionParser.new do |opt|
          sub_command_help = [
            {name:'create -n name -c content',               summary:'Create Todo Task'},
            {name:'update id -n name -c content -s status',  summary:'Update Todo Task'},
            {name:'list -s status',                          summary:'List Todo Tasks'},
            {name:'delte id',                                summary:'Delete Todo Task'}
          ]
          opt.banner = "Usage: #{opt.program_name} [-h|--help][-v|--version] <command> [<args>]"
          opt.separator ''
          opt.separator "#{opt.program_name} Available Commands:"

          sub_command_help.each do |command|
            opt.separator [opt.summary_indent,command[:name].ljust(40),command[:summary]].join(' ')
          end

          opt.on_head('-h','--help','Show this message') do |v|
            puts opt.help
            exit
          end

          opt.on_head('-v','--version','Show program version') do |v|
            opt.version = Todo::VERSION
            puts opt.ver
            exit
          end
        end
      end

      def self.help_sub_command(parser)
        puts parser.help
        exit
      end
    end
  end
end