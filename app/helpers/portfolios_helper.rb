module PortfoliosHelper
  # ====================================================================
  # Public Functions
  # ====================================================================

  def star_reports(learners, course_role, course)
    reports = []
    reports.push(user_stars(current_user, course)) if course_role == 'learner'
    reports.push average_stars(learners, course)
    reports
  end

  def toggle_star_reports(learners, course)
    reports = []
    learners.each do |learner|
      reports.push user_stars(learner, course)
    end
    reports
  end

  def achievement_reports(learners, course_role, course_id, lessons)
    reports = []
    reports.push(user_achievement(current_user, course_id, lessons)) if course_role == 'learner'
    reports.push average_achievement(learners, course_id, lessons)
    reports
  end

  def format_sticky_date(sticky_date)
    return l(sticky_date, format: :default) if sticky_date
  end

  def toggle_achievement_reports(learners, course_id, lessons)
    reports = []
    learners.each do |learner|
      reports.push user_achievement(learner, course_id, lessons)
    end
    reports
  end

  def goal_reports(course, lessons, learners, course_role)
    reports = []
    goals = course.goals
    return no_learner_reports(goals) if learners.size.zero?

    open_lessons = Lesson.select_open lessons
    eval_lessons = Lesson.select_evaluator open_lessons
    course_outcomes = course.outcomes.select(&:score)
    user_outcomes = course_outcomes.select { |co| co.manager_id == session[:id] }

    average_reports = average_goal(goals, open_lessons, eval_lessons, course_outcomes, course.learners.size)
    user_reports = user_goal(goals, open_lessons, eval_lessons, user_outcomes) if course_role == 'learner'

    goals.each_with_index do |goal, i|
      reports[i] = goal_allocation(goal, open_lessons, eval_lessons)
      reports[i][:full_name] = current_user.full_name
      reports[i][:average_self_achievement] = ratio(average_reports[i][:average_self_achievement], reports[i][:self_allocation], 0)
      reports[i][:average_eval_achievement] = ratio(average_reports[i][:average_eval_achievement], reports[i][:eval_allocation], 0)
      if course_role == 'learner'
        reports[i][:self_achievement] = ratio(user_reports[i][:self_achievement], reports[i][:self_allocation], 0)
        reports[i].merge!(eval_achievement: ratio(user_reports[i][:eval_achievement], reports[i][:eval_allocation], 0))
      end
    end
    reports
  end

  def objective_reports(lesson, learners, course_role)
    reports = []
    objectives = lesson.content.objectives
    return no_learner_reports(objectives) if learners.size.zero?

    outcomes = lesson.outcomes.select(&:report_candidate?)
    user_outcomes = outcomes.select { |oc| oc.manager_id == session[:id] }
    user_outcome = user_outcomes[0] if user_outcomes.size == 1

    average_reports = average_objective(objectives, outcomes)
    user_reports = user_objective(objectives, user_outcome) if course_role == 'learner'

    objectives.each_with_index do |obj, i|
      reports[i] = { title: obj.title, self_allocation: obj.allocation, eval_allocation: obj.allocation }
      reports[i][:full_name] = current_user.full_name
      reports[i][:average_self_achievement] = ratio(average_reports[i][:average_self_achievement], obj.allocation * outcomes.size, 0)
      reports[i][:average_eval_achievement] = ratio(average_reports[i][:average_eval_achievement], obj.allocation * outcomes.size, 0)

      if course_role == 'learner'
        reports[i][:self_achievement] = ratio(user_reports[i][:self_achievement], obj.allocation, 0)
        reports[i].merge!(eval_achievement: ratio(user_reports[i][:eval_achievement], obj.allocation, 0))
      end
    end
    reports
  end

  def average_objective(objectives, outcomes)
    achievements = []
    objectives.each do |_objective|
      achievements.push(average_self_achievement: 0, average_eval_achievement: 0)
    end

    outcomes.each do |oc|
      oc.outcomes_objectives.each_with_index do |oo, i|
        achievements[i][:average_self_achievement] += oo.self_achievement if oo.self_achievement
        achievements[i][:average_eval_achievement] += oo.eval_achievement if oo.eval_achievement
      end
    end
    achievements
  end

  def user_objective(objectives, outcome)
    achievements = []
    objectives.each do |_objective|
      achievements.push(self_achievement: 0, eval_achievement: 0)
    end

    return achievements unless outcome
    outcome.outcomes_objectives.each_with_index do |oo, i|
      achievements[i][:self_achievement] = oo.self_achievement if oo.self_achievement
      achievements[i][:eval_achievement] = oo.eval_achievement if oo.eval_achievement
    end
    achievements
  end

  def no_learner_reports(elements)
    reports = []
    elements.each do |element|
      reports.push(title: element.title, self_allocation: 0, eval_allocation: 0)
    end
    reports
  end

  def signin_reports(learners)
    reports = []
    reports.push average_signin(learners)
    reports.push user_signin(current_user)
    reports
  end

  def toggle_signin_reports(learners)
    reports = []
    learners.each do |learner|
      reports.push user_signin(learner)
    end
    reports
  end

  def manager_report?(course_role, learners)
    (course_role == 'manager') && !learners.empty?
  end

  # ====================================================================
  # Private Functions
  # ====================================================================

  private

  def user_stars(user, course)
    sticky_stars = Sticky.where("category = 'course' and course_id = ? and manager_id = ?", course.id, user.id).sum(:stars_count)
    note_stars = Note.where("status = 'course' and course_id = ? and manager_id = ?", course.id, user.id).sum(:stars_count)
    stars_rank = star_rank user.id, course
    star_hash user.full_name, sticky_stars, note_stars, stars_rank, 'info'
  end

  def star_hash(full_name, sticky_stars, note_stars, stars_rank, badge_class)
    report = {}
    report['full_name'] = full_name
    report['sticky_stars'] = sticky_stars
    report['note_stars'] = note_stars
    report['stars_rank'] = stars_rank
    report['badge_class'] = badge_class
    report
  end

  def star_rank(user_id, course)
    stickies = Sticky.where("category = 'course' and course_id = ?", course.id).group(:manager_id).sum(:stars_count)
    notes = Note.where("status = 'course' and course_id = ?", course.id).group(:manager_id).sum(:stars_count)

    user_stars = {}
    stickies.each do |key, value|
      stars_count = value
      if notes[key]
        stars_count += notes[key]
        notes.delete(key)
      end
      user_stars.store(key, stars_count)
    end
    user_stars.merge! notes
    user_stars.delete_if { |_key, value| value < 2 }

    # delete course managers and assistants from hot_users
    course.managers.each do |manager|
      user_stars.delete_if { |key, _value| key == manager.id }
    end
    course.assistants.each do |assistant|
      user_stars.delete_if { |key, _value| key == assistant.id }
    end

    user_stars_array = user_stars.to_a.sort { |a, b| b[1] <=> a[1] }
    user_stars_array.each_with_index do |e, i|
      return (i + 1) if e[0] == user_id
    end
    user_stars_array.size + 1
  end

  def average_stars(learners, course)
    stickies = Sticky.where("category = 'course' and course_id = ?", course.id).group(:manager_id).sum(:stars_count)
    notes = Note.where("status = 'course' and course_id = ?", course.id).group(:manager_id).sum(:stars_count)

    # delete course managers and assistants from hot_users
    course.managers.each do |manager|
      stickies.delete_if { |key, _value| key == manager.id }
      notes.delete_if { |key, _value| key == manager.id }
    end
    course.assistants.each do |assistant|
      stickies.delete_if { |key, _value| key == assistant.id }
      notes.delete_if { |key, _value| key == assistant.id }
    end

    sticky_stars = 0
    stickies.each { |_key, value| sticky_stars += value }
    note_stars = 0
    notes.each { |_key, value| note_stars += value }

    sticky_stars = average sticky_stars, learners.size, 0
    note_stars = average note_stars, learners.size, 0
    star_hash '学生の平均', sticky_stars, note_stars, -1, 'success'
  end

  def average_achievement(learners, course_id, lessons)
    open_lessons = Lesson.select_open lessons
    eval_lessons = Lesson.select_evaluator open_lessons
    if learners.size.zero? || open_lessons.size.zero?
      achievement_hash '学生の平均', '', '', '', '', 0, 0, 'success'
    else
      self_lesson = 0
      self_achievement = 0
      eval_achievement = 0
      lesson_score = 0
      learners.each do |learner|
        report = user_achievement(learner, course_id, lessons)
        self_lesson += report['self_lesson']
        self_achievement += report[:self_achievement]
        unless eval_lessons.empty?
          eval_achievement += report[:eval_achievement]
          lesson_score += report['lesson_score']
        end
      end
      self_lesson = average self_lesson, learners.size, 0
      self_achievement = average self_achievement, learners.size, 0
      eval_achievement = average eval_achievement, learners.size, 0
      lesson_score = average lesson_score, learners.size, 0
      achievement_hash '学生の平均', self_lesson, self_achievement, eval_achievement, lesson_score, open_lessons.size, eval_lessons.size, 'success'
    end
  end

  def user_achievement(user, course_id, lessons)
    open_lessons = Lesson.select_open lessons
    eval_lessons = Lesson.select_evaluator open_lessons
    return achievement_hash(user.full_name, '', '', '', '', 0, 0, 'info') if open_lessons.size.zero?

    self_lesson = 0
    lesson_score = 0
    self_achievement = 0
    eval_achievement = 0

    outcomes = Outcome.where(manager_id: user.id, course_id: course_id)
    outcomes.each do |oc|
      # next if !oc.selected?(open_lessons) || (oc.status == 'draft')
      # outcome record has automaticaly made with nil 'checked' value when learner sees assignment page
      next if !oc.selected?(open_lessons) || oc.checked.nil?

      self_lesson += 1
      lesson_score += oc.score if oc.score && (oc.status != 'self_submit')

      outcome_opjectives = OutcomesObjective.where(outcome_id: oc.id)
      outcome_opjectives.each do |oo|
        self_achievement += oo.self_achievement if oo.self_achievement
        eval_achievement += oo.eval_achievement if oo.eval_achievement
      end
    end

    self_lesson = ratio self_lesson, open_lessons.size, 0
    self_achievement = ratio self_achievement, open_lessons.size * 10, 0
    return achievement_hash(user.full_name, self_lesson, self_achievement, '', '', open_lessons.size, 0, 'info') if eval_lessons.size.zero?

    eval_achievement = ratio eval_achievement, eval_lessons.size * 10, 0
    achievement_hash user.full_name, self_lesson, self_achievement, eval_achievement, lesson_score, open_lessons.size, eval_lessons.size, 'info'
  end

  def achievement_hash(full_name, self_lesson, self_achievement, eval_achievement, lesson_score, self_lesson_size, eval_lesson_size, bar_class)
    report = {}
    report['full_name'] = full_name
    report['self_lesson'] = self_lesson
    report[:self_achievement] = self_achievement
    report[:eval_achievement] = eval_achievement
    report['lesson_score'] = lesson_score
    report['self_lesson_size'] = self_lesson_size
    report['eval_lesson_size'] = eval_lesson_size
    report['bar_class'] = bar_class
    report
  end

  def average_goal(goals, open_lessons, _eval_lessons, outcomes, learner_size)
    achievements = []
    goal_objectives = []

    goals.each do |goal|
      achievements.push(average_self_achievement: 0, average_eval_achievement: 0)
      goal_objectives.push goal.objectives
    end

    outcomes.each do |oc|
      next if !oc.selected?(open_lessons) || (oc.status == 'draft')
      oc.outcomes_objectives.each do |oo|
        index = goal_index(goal_objectives, oo.objective_id)
        next unless index
        achievements[index][:average_self_achievement] += oo.self_achievement if oo.self_achievement
        achievements[index][:average_eval_achievement] += oo.eval_achievement if oo.eval_achievement
      end
    end
    goals.size.times do |i|
      achievements[i][:average_self_achievement] = average(achievements[i][:average_self_achievement], learner_size, 0)
      achievements[i][:average_eval_achievement] = average(achievements[i][:average_eval_achievement], learner_size, 0)
    end

    achievements
  end

  def user_goal(goals, open_lessons, _eval_lessons, outcomes)
    achievements = []
    goal_objectives = []

    goals.each do |goal|
      achievements.push(self_achievement: 0, eval_achievement: 0)
      goal_objectives.push goal.objectives
    end

    outcomes.each do |oc|
      # next if !oc.selected?(open_lessons) || (oc.status == 'draft')
      # outcome record has automaticaly made with nil 'checked' value when learner sees assignment page
      next if !oc.selected?(open_lessons) || oc.checked.nil?
      oc.outcomes_objectives.each do |oo|
        index = goal_index(goal_objectives, oo.objective_id)
        next unless index
        achievements[index][:self_achievement] += oo.self_achievement if oo.self_achievement
        achievements[index][:eval_achievement] += oo.eval_achievement if oo.eval_achievement
      end
    end
    achievements
  end

  def goal_index(goal_objectives, obj_id)
    goal_objectives.each_with_index do |obj, i|
      return i if obj.select { |o| o.id == obj_id }.size == 1
    end
    nil
  end

  def goal_allocation(goal, open_lessons, eval_lessons)
    allocation = {}
    allocation[:title] = goal.title
    allocation[:self_allocation] = 0
    allocation[:eval_allocation] = 0

    goal.objectives.each do |obj|
      allocation[:self_allocation] += obj.allocation if obj.selected?(open_lessons)
      allocation[:eval_allocation] += obj.allocation if obj.selected?(eval_lessons)
    end
    allocation
  end

  def average_signin(learners)
    if learners.size.zero?
      access_num_week1 = '---'
      access_num_week2 = '---'
    else
      access_num_week1 = 0
      access_num_week2 = 0
      learners.each do |learner|
        report = user_signin learner
        access_num_week1 += report['access_num_week1']
        access_num_week2 += report['access_num_week2']
      end
      access_num_week1 = average access_num_week1, learners.size, 1
      access_num_week2 = average access_num_week2, learners.size, 1

      average ratio, learners.size, 1

      # access = 0
      # ratio = 0.0
      # learners.each do |learner|
      # 	user_accesses = Signin.where(user_id: learner.id)
      # 	access += user_accesses.size
      # 	ratio += out_organization_ratio user_accesses
      # end
      # access = average access, learners.size, 1
      # ratio = average ratio, learners.size, 1
    end
    signin_hash '', '学生の平均', '---', access_num_week1, access_num_week2
  end

  def user_signin(user)
    to_day = 1.day.ago
    from_day = 7.days.ago
    access_num_week1 = Signin.where(updated_at: from_day..to_day).or(Signin.where(user_id: user.id))
    to_day = 8.days.ago
    from_day = 14.days.ago
    access_num_week2 = Signin.where(updated_at: from_day..to_day).or(Signin.where(user_id: user.id))

    signin_hash user.signin_name, user.full_name, user.last_signin_at, access_num_week1.size, access_num_week2.size
  end

  def signin_hash(signin_name, full_name, last_signin_at, access_num_week1, access_num_week2)
    report = {}
    report['signin_name'] = signin_name
    report['full_name'] = full_name
    report['last_signin_at'] = last_signin_at
    report['access_num_week1'] = access_num_week1
    report['access_num_week2'] = access_num_week2
    report
  end

  # def out_organization_ratio accesses
  #    out_organization_accesses = accesses.select{|a| !a.inside}
  #    if accesses.size == 0
  #            out_organization_ratio = 0
  #    else
  #            out_organization_ratio = (out_organization_accesses.size*100)/accesses.size
  #    end
  #    return out_organization_ratio
  # end
end
