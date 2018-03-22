# ERPmine - ERP for service industry
# Copyright (C) 2011-2018  Adhi software pvt ltd
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

class DayViewRenderer < SheetViewRenderer
	def getDaysPerSheet
		1
	end
	
	def showWorkTimeHeader
		false
	end
	
	def showTEStatus
		false
	end
	
	def showSpentOnInRow
		true
	end
	
	def getSheetType
		'I'
	end
	
	def getSheetEntries(cond, modelClass, givenValues)
		sqlStr = "select i.id as issue_id, i.subject as issue_name, i.project_id, i.assigned_to_id, 
			p.name as project_name, ap.id as account_project_id, ap.parent_id, ap.parent_type,
			te.id as time_entry_id, te.id, COALESCE(te.spent_on,'#{givenValues[:selected_date]}') as spent_on , COALESCE(te.hours,0) as hours, te.activity_id, te.comments, te.spent_on_time, 
			te.spent_for_id, te.spent_for_type, te.spent_id, te.spent_type from issues i 
			inner join projects p on (p.id = i.project_id and project_id in (#{givenValues[:project_id]}) #{self.issue_join_cond})
			inner join custom_values cv on (i.id = cv.customized_id and cv.customized_type = 'Issue' and cv.custom_field_id = #{givenValues[:issue_cf_id]} and cv.value = '#{givenValues[:user_id]}') OR i.assigned_to_id = #{givenValues[:user_id]}
			left outer join wk_account_projects ap on (ap.project_id = p.id)
			left outer join (select t.*, sf.spent_on_time, sf.spent_for_id, sf.spent_for_type, sf.spent_id, sf.spent_type  from time_entries t 
			inner join wk_spent_fors sf on (t.id = sf.spent_id and sf.spent_type = 'TimeEntry' and t.spent_on = '#{givenValues[:selected_date]}')) te on te.issue_id = i.id and te.user_id = #{givenValues[:user_id]}
			and te.spent_for_type = ap.parent_type and te.spent_for_id = ap.parent_id" 
			#time_entries te on te.spent_on = '#{@selectedDate}' and te.issue_id = i.id and te.user_id = #{@user.id} 
			#left outer join wk_spent_fors sf on sf.spent_type = 'TimeEntry' and sf.spent_for_type = ap.parent_type and sf.spent_for_id = ap.parent_id
		#sqlStr = sqlStr + " Where "
		modelClass.find_by_sql(sqlStr)
	end
	
	def getEntrySpentFor(entry)
		parentId = nil
		parentType = nil
		spentOnTime = Time.now
		if entry.spent_for.blank? && !entry.hours.blank? && entry.id.blank?
			parentId = entry.parent_id
			parentType = entry.parent_type
			spentOnTime = entry.spent_on_time
		elsif !entry.spent_for.blank?
			parentId = entry.spent_for.spent_for_id 
			parentType = entry.spent_for.spent_for_type
			spentOnTime = entry.spent_for.spent_on_time
		end
		{:parent_id => parentId, :parent_type => parentType, :spent_on_time => spentOnTime}
	end
	
	def getStartOfSheet(startDate)
		startDate.wday
	end
	
	def useSelectedDtAsStart
		true
	end
end
