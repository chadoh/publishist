# This goes here and not in spec_helper because cucumber needs it, too
Delayed::Worker.delay_jobs = !Rails.env.test?
