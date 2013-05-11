module Peek
  module QueryReviewer
    class Railtie < ::Rails::Engine
      isolate_namespace Peek::QueryReviewer

      initializer 'peek.query_reviewer.include_controller_helpers' do
        config.to_prepare do
          Peek::QueryReviewer.setup
        end
      end
    end
  end
end
