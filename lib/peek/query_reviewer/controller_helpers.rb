module Peek
  module QueryReviewer
    module ControllerHelpers
      extend ActiveSupport::Concern

      included do
        before_filter :enable_query_reviewer, :if => :query_reviewer_enabled?
        helper_method :query_reviewer_enabled?
      end

      protected

      def enable_query_reviewer
        Peek::QueryReviewer.enable!
      end

      def query_reviewer_enabled?
        peek_enabled? && Peek::QueryReviewer.enabled?
      end
    end
  end
end
