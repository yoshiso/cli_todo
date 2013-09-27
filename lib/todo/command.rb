# -*- encoding: utf-8 -*-

module Todo
  
  # CommandLine Based execution
  # @author yoshiso
  class Command

    def self.run(argv)
      new(argv).execute
    end

    def initialize(argv)
      @argv = argv
    end

    def execute
      options = Options.parse!(@argv)
      sub_command = options.delete(:command)

      DB.prepare

      tasks = case sub_command
        when 'create'
          create_task(options[:name],options[:content])
        when 'delete'
          delete_task(options[:id])
        when 'update'
          update_task(options.delete(:id),options)
        when 'list'
          find_tasks(options[:status])
        end
      display_tasks tasks
    rescue => e
      abort "Error: #{e.message}"
    end

    def create_task(name,content)
      # Default value on creating task is NOT_YET
      Task.create!(name: name, content: content).reload
    end

    def delete_task(id)
      task = Task.find(id)
      task.destroy
    end

    def update_task(id,attributes)
      if status_name = attributes[:status]
        attributes[:status] = Task::STATUS.fetch(status_name.upcase)
      end

      task = Task.find(id)
      task.update_attributes! attributes
      task.reload
    end

    def find_tasks(status_name)
      all_tasks = Task.order('created_at DESC')
      if status_name
        status = Task::STATUS.fetch(status_name.upcase)
        all_tasks.status_is(status)
      else
        all_tasks
      end
    end

    def display_tasks(tasks)
      header = display_format('ID','Name','Content','Status')
      puts header
      puts '-'*header.size
      Array(tasks).each do |task|
        puts display_format(task.id,task.name,task.content,task.status_name)
      end
    end

    def display_format(id,name,content,status)
      name_length = 20-full_width_count(name)
      content_length = 40-full_width_count(content)
      [id.to_s.rjust(4),name.ljust(name_length),content.ljust(content_length),status.ljust(8)].join(' | ')
    end

    def full_width_count(string)
      string.each_char.select{|char| !(/[ -~。ー｀]/.match(char))}.count
    end
  end

end