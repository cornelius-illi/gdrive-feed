class WorkingSession < Activity
  def self.count(monitored_resource, monitored_period=nil, resource_ids=nil)
    return if monitored_resource.blank?

    where = ["WHERE resources.monitored_resource_id=? AND revisions.working_session_id IS NULL AND revisions.collaboration = 0 "]
    where.push monitored_resource.id

    if !resource_ids.blank? && resource_ids.is_a?(Array)
      where.first << " AND resources.id IN (#{resource_ids.join(",")}) "
    end

    unless monitored_period.blank?
      where.first << "AND revisions.modified_date >= ? AND revisions.modified_date <= ?"
      where.push monitored_period.start_date
      where.push monitored_period.end_date
    end

    where_sanitized = ActiveRecord::Base.send(:sanitize_sql_array, where)

    query = "SELECT COUNT(revisions.id) as count FROM resources JOIN revisions ON revisions.resource_id=resources.id #{where_sanitized}"
    result_set = ActiveRecord::Base.connection.exec_query(query)

    return result_set.first['count']

  end
end