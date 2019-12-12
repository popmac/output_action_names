class OutputActionNames
  def self.run
    require 'fileutils'
    require 'csv'
    require 'active_support'
    require 'active_support/inflector'

    # 対象となるcontrollerのファイルを取得(ディレクトリ自体やconcernsを除外)
    controller_files = Dir.glob('app/controllers/**/*').sort
    target_controller_files = controller_files.grep(/.*_controller\.rb/)

    # controllerのクラス名を取得
    class_names = target_controller_files.map do |file|
      file
        .sub(/^app\/controllers\//, '')
        .sub(/\.rb/, '')
        .camelize
    end

    # 以下のような構造にする
    # [['MembersController', 'index'], ['MembersController', 'new']]
    class_name_and_action_array = [['Controller', 'Action']]
    class_names.each do |class_name|
      actions = eval("#{class_name}.instance_methods(false).sort")

      actions.each do |action|
        class_name_and_action_array << [class_name, action.to_s]
      end
    end

    # CSVで出力
    # ['MembersController', 'index']をfに入れていることで、スプレッドシートにインポートする時にカンマ区切りになって便利
    CSV.open('tmp/output.csv', 'w') do |f|
      class_name_and_action_array.each do |a|
        f << a
      end
    end

    puts 'CSVファイルが tmp/output.csv に出力されました'
  end
end
