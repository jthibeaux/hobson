class Hobson::Project::TestRun

  def enqueue!
    Resque.enqueue(Hobson::BuildTestRun, project.name, id)
    enqueued_build!
  end

  # checkout the given sha
  # discover the tests that are needed to run
  # add a list of tests to the TestRun data
  # schedule N RunTests resque jobs for Y jobs (balancing is done in this step)
  def build!
    started_building!
    number_of_jobs = Resque.workers.length
    # TEMP while testing
    # number_of_jobs = 2

    logger.info "checking out #{sha}"
    workspace.checkout! sha

    logger.info "detecting tests"
    tests.detect!

    logger.info "balancing tests"
    tests.balance_for! number_of_jobs

    logger.info "enqueuing #{number_of_jobs} jobs to run #{tests.length} tests"
    (0..(number_of_jobs-1)).zip(tests_groups).map{|index, tests| Job.new(self, index).enqueue! }

    enqueued_jobs! # done
  end

end
