module TimeTracker
  module TimeEntryPatch
    
    def self.included(base)
      base.class_eval do
        unloadable # Send unloadable so it will not be unloaded in development
        
        include InstanceMethods

        attr_accessor :spent_from_time, :spent_to_time
        safe_attributes :spent_from, :spent_to, :spent_from_time, :spent_to_time

        after_save :update_issue
        
        after_destroy :update_issue_history

        before_validation :set_spent_from_to
        before_validation :merge_entries
      end
    end
    
    module InstanceMethods
      def update_issue
        self.issue.status = IssueStatus.in_progress
        self.issue.save
      end
      
      def update_issue_history
        self.issue.check_history_entries
      end

      def hours=(h)
        write_attribute :hours, (h.is_a?(String) ? (h.to_hours || h) : h)
        self.spent_to = self.spent_from.advance(:hours=>hours) if self.spent_from && hours
      end

      def spent_on=(date)
        super
        if spent_on.is_a?(Time)
          self.spent_on = spent_on.to_date
        end
        self.tyear = spent_on ? spent_on.year : nil
        self.tmonth = spent_on ? spent_on.month : nil
        self.tweek = spent_on ? Date.civil(spent_on.year, spent_on.month, spent_on.day).cweek : nil

        self.spent_from = date
        self.spent_to = self.spent_from.advance(:hours=>hours) if self.spent_from && hours
      end

      # Merge adjacent time entries on new
      def merge_entries
        # Find a time entry that could be adjacent
        t = nil
        begin
          t = TimeEntry.find(:last, :conditions=>['id <> :id  AND project_id=:project_id AND user_id=:user_id AND issue_id=:issue_id AND
                (comments=:comments OR (comments is null and :comments is null)) AND activity_id=:activity_id AND spent_on=:spent_on AND
                (spent_to BETWEEN :s1 AND :e1  OR :start1 BETWEEN SUBTIME(spent_from,MAKETIME(0,2,0)) AND ADDTIME(spent_to,MAKETIME(0,2,0)))',
              {:id=>self.id || 0, :project_id=>self.project_id, :user_id=>self.user_id, :issue_id=>self.issue_id,
              :comments=>self.comments, :activity_id=>self.activity_id, :spent_on=>self.spent_from.to_date,
              :s1=>self.spent_from-2.minutes, :e1=>self.spent_to+2.minutes,
              :start1=>self.spent_from}])
          return unless t
          self.spent_from = t.spent_from if t.spent_from < self.spent_from
          self.spent_to = t.spent_to if t.spent_to > self.spent_to
          # no longer need that entry
          t.destroy
        end while t
      end

      def set_spent_from_to
        if (spent_from && spent_to)
          if spent_from_time && spent_to_time
            self.spent_from = self.spent_from.strftime("%Y-%m-%d") + ' ' + @spent_from_time
            self.spent_to = self.spent_to.strftime("%Y-%m-%d") + ' ' + @spent_to_time
          end

          self.hours = (spent_to - spent_from)/60.0/60.0 if spent_to - spent_from > 0
          self.spent_on = self.spent_from
        end
      end
      
    end
  end
end